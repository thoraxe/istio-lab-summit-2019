# Fault Injection

This exercise shows how to inject faults and test the resiliency of your application. Istio provides a set of failure
recovery features that can be taken advantage of by the services in an application. Features include:

* Timeouts
* Bounded retries with timeout budgets and variable jitter between retries
* Limits on number of concurrent connections and requests to upstream services
* Active (periodic) health checks on each member of the load balancing pool
* Fine-grained circuit breakers (passive health checks) – applied per instance in the load balancing pool

Together, these features enable the service mesh to tolerate failing nodes and prevent localized failures
from cascading instability to other nodes.

## What you will learn

You will apply some chaos engineering by throwing in some HTTP errors and network delays. Understanding failure
scenarios is a critical aspect of microservices architecture (aka distributed computing)

## HTTP Error 503

By default, recommendation v1 and v2 are being randomly load-balanced as that is the default behavior in Kubernetes/OpenShift

You can inject 503’s, for approximately 50% of the requests:

~~~bash
oc create -f ${ISTIO_LAB_HOME}/src/istiofiles/route-rule-recommendation-503.yml -n ${ISTIO_LAB_PROJECT}
~~~

After a few seconds, access the service 10 times:

~~~bash
for i in $(seq 10); do
  curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
done
~~~

You should see about half the time a failure `customer => 503 preference => 503 fault filter abort`.

Remove the fault injector:

~~~bash
oc delete routerule/recommendation-503 -n ${ISTIO_LAB_PROJECT}
~~~

## Delay

The most insidious of possible distributed computing faults is not a "down" service but a service that is
responding slowly, potentially causing a cascading failure in your network of services.

Inject a delay:

~~~bash
oc create -f ${ISTIO_LAB_HOME}/src/istiofiles/route-rule-recommendation-delay.yml -n ${ISTIO_LAB_PROJECT}
~~~

Then hit the customer endpoint repeatedly:

~~~bash
while true; do
  curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
done
~~~

You will notice many requests to the customer endpoint now have a delay (the rule injects a 7 second delay half the time when
the `recommendation` service is called).

You can also see this in Jaeger by opening
the Jaeger console once again (see above for how to access the URL).
Select `recommendation` from the **Service** drop-down and click **Find Traces**.
Some traces are fast, but some traces will show the delay:

![Delay]({% image_path delay.png %})

Remove the delay:

~~~bash
oc delete routerule/recommendation-delay -n ${ISTIO_LAB_PROJECT}
~~~

## Retry

Here we can force Istio to retry failed service calls so that the application doesn't have to deal with retrying.

We will use Istio and return HTTP Error 503 about 50% of the time. Send all users to `v2` which will throw out some 503’s:

~~~bash
oc create -f ${ISTIO_LAB_HOME}/src/istiofiles/route-rule-recommendation-v2_503.yml -n ${ISTIO_LAB_PROJECT}
~~~

Now, if you hit the customer endpoint several times, you should see some 503’s:

~~~bash
for i in $(seq 20); do
  curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
done
~~~

Now add the retry rule to make Istio retry when a 503 is received:

~~~bash
oc create -f ${ISTIO_LAB_HOME}/src/istiofiles/route-rule-recommendation-v2_retry.yml -n ${ISTIO_LAB_PROJECT}
~~~

After a few seconds, things will settle down and the calls should succeed 100% of the time as Istio will retry whenever
a 503 is received:

~~~bash
for i in $(seq 20); do
  curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
done
~~~

> You may need to wait up to 30 seconds for the retry rule to take effect. Just run the above command again if you see
any `503`'s. You should eventually not see any.

Cleanup the retries and injected faults:

~~~bash
oc delete routerule/recommendation-v2-retry routerule/recommendation-v2-503  -n ${ISTIO_LAB_PROJECT}
~~~

# References

* [Red Hat OpenShift](https://openshift.com){:target="_blank"}
* [Learn Istio on OpenShift](https://learn.openshift.com/servicemesh){:target="_blank"}
* [Istio Homepage](https://istio.io){:target="_blank"}
