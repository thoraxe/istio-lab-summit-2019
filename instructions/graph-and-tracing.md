# Service Mesh Visualizations and Tracing

In this exercise you'll look at some of the out-of-the-box tools that
Istio provides for visualizing the service mesh, querying for telemetry, and
monitoring/visualizing the traffic. This is very useful for debugging and improving
existing apps without having to echange them.

## What you will learn

* How to access various consoles (OpenShift Web Console, tracing, monitoring, visualization)
* How to use these to improve your app performance and architecture

## Access OpenShift Web Console

OpenShift also provides a feature rich Web Console that provides a friendly graphical interface for
interacting with the platform. Open the [OpenShift Web Console]({{OPENSHIFT_MASTER}}/console){:target="_blank"} .

Accept the self-signed certificate warning, and you'll arrive at the login screen. Login with:

* **Username**: `admin`
* **Password**: `admin`

![OpenShift Login]({% image_path login.png %})

Once logged in, click on the `istio-system` project on the right:

![Console project]({% image_path projects.png %})

> NOTE: If you do not see the `istio-system` project, you may need to click on `View All`!

Make a note of the `grafana`, `jaeger-query`, `prometheus` and `servicegraph` console URLs for your respective environment.  The following screenshot shows how to find them via OpenShift web console:

![OpenShift Web Console]({% image_path lab2_console_urls.png %})

## Visualize the network

The Servicegraph service is an example service that provides endpoints for generating and visualizing a graph of services within a mesh. It exposes the following endpoints:

* `/graph` which provides a JSON serialization of the servicegraph
* `/dotgraph` which provides a dot serialization of the servicegraph
* `/force` which provides a [D3.js](https://d3js.org/){:target="_blank"}-based dynamic representation of the servicegraph
* `/dotviz` which provides a static representation of the servicegraph

## Examine Service Graph

Open the [Service Graph](http://servicegraph-istio-system.{{APPS_SUFFIX}}/force/forcegraph.html?time_horizon=5m&filter_empty=true){:target="_blank"} visualization.

It should look like:

![Force graph]({% image_path forcegraph.png %})

This shows you a graph of the services and how they are connected, with some basic access metrics like
how many requests per second each service receives.

As you add and remove services over time in your projects, you can use this to verify the connections between services and provides
a high-level telemetry showing the rate at which services are accessed.

## Generating application load

To get a better idea of the power of metrics, let's setup an endless loop that will continually access
the application and generate load. We'll open up a separate terminal just for this purpose. Execute this command:

~~~bash
while true; do
  curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
  sleep .5
done
~~~

> NOTE: After opening a new terminal window you will need to connect to your lab machine before issuing the
above commands. Refer to the [Introduction](intro.md#opening-more-terminals){:target="_blank"} section for details on opening new terminals.

This command will endlessly access the application and report the HTTP status result in a separate terminal window.

With this application load running, metrics will become much more interesting in the next few steps.

## Querying Metrics with Prometheus

[Prometheus](https://prometheus.io/){:target="_blank"} exposes an endpoint serving generated metric values. The Prometheus
add-on is a Prometheus server that comes pre-configured to scrape Mixer endpoints
to collect the exposed metrics. It provides a mechanism for persistent storage
and querying of Istio metrics. Istio also allows you to specify custom metrics which
can be seen inside of the Prometheus dashboard.

First, add a custom metric:

~~~bash
oc create -f ${ISTIO_LAB_HOME}/src/istiofiles/recommendation_requestcount.yml -n istio-system
~~~

Open the [Prometheus Console](http://prometheus-istio-system.{{APPS_SUFFIX}}){:target="_blank"} in your Web Browser.

In the “Expression” input box at the top of the web page, enter the text:
`round(increase(istio_recommendation_request_count{destination=~"recommendation.*" }[60m]))`

Then, click the **Execute** button, and then the **Graph** tab. You should see the graph of the number of accesses to
the `recommendation` service (you may need to adjust the interval to `5m` (5 minutes) as seen in the screenshot)

![Prometheus console]({% image_path prom.png %})

Other expressions to try:

* Total count of all requests to `v2` of the `recommendation` service: `istio_request_count{destination_service=~"recommendation.*", destination_version="v2"}`
* Rate of requests over the past 5 minutes to all `preference` services: `rate(istio_request_count{destination_service=~"preference.*", response_code="200"}[5m])`

There are many, many different queries you can perform to extract the data you need. Consult the
[Prometheus documentation](https://prometheus.io/docs){:target="_blank"} for more detail.

## Visualizing Metrics with Grafana

As the number of services and interactions grows in your application, this style of metrics may be a bit
overwhelming. [Grafana](https://grafana.com/){:target="_blank"} provides a visual representation of many available Prometheus
metrics extracted from the Istio data plane and can be used to quickly spot problems and take action.

Open the [Grafana Console](http://grafana-istio-system.{{APPS_SUFFIX}}/dashboard/db/istio-dashboard){:target="_blank"}. It should look like:

![Grafana graph]({% image_path grafana.png %})

The Grafana Dashboard for Istio consists of three main sections:

1. **A Global Summary View.** This section provides high-level summary of HTTP requests flowing through the service mesh.
1. **A Mesh Summary View.** This section provides slightly more detail than the Global Summary View, allowing per-service filtering and selection.
1. **Individual Services View.** This section provides metrics about requests and responses for each individual service within the mesh (HTTP and TCP).

Scroll down to the see the stats for the `customer`, `preference` and `recommendation` services:

![Grafana graph]({% image_path grafana-svcs.png %})

These graph shows which other services are accessing each service. You can see that
the `preference` service is calling the `recommendation:v1` and `recommendation:v2` service
equally, since the default routing is _round-robin_.

For more on how to create, configure, and edit dashboards, please see the [Grafana documentation](http://docs.grafana.org/){:target="_blank"}.

As a developer, you can get quite a bit of information from these metrics without doing anything to the application
itself. Let's use our new tools in the next section to see the real power of Istio to diagnose and fix issues in
applications and make them more resilient and robust.

## Tracing service calls using Jaeger OpenTracing

At the highest level, a trace tells the story of a transaction or workflow as
it propagates through a (potentially distributed) system. A trace is a directed
acyclic graph (DAG) of _spans_: named, timed operations representing a
contiguous segment of work in that trace.

Distributed tracing speeds up troubleshooting by allowing developers to quickly understand
how different services contribute to the overall end-user perceived latency. In addition,
it can be a valuable tool to diagnose and troubleshoot distributed applications.

Tracing in Istio requires you to pass a set of headers to outbound requests. It can be done manually
or by using the OpenTracing framework instrumentations such as [opentracing-spring-cloud](https://github.com/opentracing-contrib/java-spring-cloud){:target="_blank"}. Framework instrumentation
automatically propagates tracing headers and also creates in-process spans to better understand what is
happening inside the application.

There are different ways to configure the tracer. The _Customer_ Java service in this lab is using [tracerresolver](https://github.com/jaegertracing/jaeger-client-java/tree/master/jaeger-tracerresolver){:target="_blank"}
which does not require any code changes and the whole configuration is defined in environmental variables whose names
begin with `JAEGER_`. Run this command to execute the `env` command inside the running container to see them:

~~~bash
oc rsh -c customer $(oc get pods --selector app=customer -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}') env | grep JAEGER_
~~~

Whereas the _Preference_ Java service is instantiating the tracer bean directly in its Spring configuration class
in `$ISTIO_LAB_HOME/src/preference/src/main/java/com/redhat/developer/demos/preference/PreferencesApplication.java`.

First, open the [Jaeger Console](https://jaeger-query-istio-system.{{APPS_SUFFIX}}){:target="_blank"}.

Next, select _customer_ in the **Service** drop-down, and then click **Find traces**. You should see a list of recent
traces:

![Jaeger traces]({% image_path jaeger-traces.png %})

Click on one of them to display detailed info, showing the access from `customer` -> `preference` -> `recommendation` and the
time each call took:

![Jaeger traces]({% image_path trace.png %})

This can be useful in identifying critical paths and bottlenecks in your apps, and make architectural
improvements to increase performance or fix timing or other issues in your code.

## Cleanup

Stop the endless `curl` loop with `CTRL-C` in the running terminal (or just close the window).

# References

* [Red Hat OpenShift](https://openshift.com){:target="_blank"}
* [Learn Istio on OpenShift](https://learn.openshift.com/servicemesh){:target="_blank"}
* [Istio Homepage](https://istio.io){:target="_blank"}
