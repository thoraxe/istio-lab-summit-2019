
# Rate Limiting

In this step we will use Istio's Quota Management feature to apply
a rate limit on the `ratings` service.

## What you will learn

* How to selectively apply quotas to services to limit their access based on various rules

## Quotas in Istio
Quota Management enables services to allocate and free quota on a
based on rules called _dimensions_. Quotas are used as a relatively
simple resource management tool to provide some fairness between
service consumers when contending for limited resources.
Rate limits are examples of quotas, and are handled by the
[Istio Mixer](https://istio.io/docs/concepts/policy-and-control/mixer.html){:target="_blank"}.

## Apply Quota Rules

First, add a rate limit handler:

~~~bash
oc create -f ${ISTIO_LAB_HOME}/src/istiofiles/recommendation_rate_limit_handler.yml
~~~

Then, add the actual quota rule which will reference the handler when deciding whether to allow traffic:

~~~bash
oc create -f ${ISTIO_LAB_HOME}/src/istiofiles/rate_limit_rule.yml
~~~

This configuration specifies a default 1 qps (query per second) rate limit. Traffic reaching
the `recommendation:v2` service from the `preference` service is subject to a 1qps rate limit.

Take a look at the new rule:

~~~bash
oc get memquota handler -n istio-system -o yaml
~~~

In particular, notice the _dimension_ that causes the rate limit to be applied:

~~~yaml
- dimensions:
    destination: recommendation
    destinationVersion: v2
    source: preference
  maxAmount: 1
  validDuration: 1s
validDuration: 1s
~~~

You can also conditionally rate limit based on other dimensions, such as:

* Source and Destination project names (e.g. to limit developer projects from overloading the production services during testing)
* Login names (e.g. to limit certain customers or classes of customers)
* Source/Destination hostnames, IP addresses, DNS domains, HTTP Request header values, protocols
* API paths
* [Several other attributes](https://istio.io/docs/reference/config/mixer/attribute-vocabulary.html){:target="_blank"}

## Attempt to access app

With the quota in place for `recommendation:v2` let's hit it as fast as we can and observe the `429 Too Many Requests` HTTP
error generated as a result of the quota:

~~~bash
for i in $(seq 20); do
  curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
done
~~~

The first or second attempt to access `recommendation:v2` will succeed:

`customer => preference => recommendation v2 from '5445bf797-zmvdq': 635`

But the next one (which occurs less than 1 second later) will fail:

`customer => 503 preference => 429 RESOURCE_EXHAUSTED:Quota is exhausted for: requestcount`

This is because our quota only allows 1 request per second to succceed. After 1 second elapses,
the next call to `v2` will succeed but then start failing again. So you will only get one successful
call to `v2` every second. Rate limiting in action!

## Cleanup

Remove the rate limit:

~~~bash
oc delete -f ${ISTIO_LAB_HOME}/src/istiofiles/rate_limit_rule.yml
oc delete -f ${ISTIO_LAB_HOME}/src/istiofiles/recommendation_rate_limit_handler.yml
~~~

# References

* [Red Hat OpenShift](https://openshift.com){:target="_blank"}
* [Learn Istio on OpenShift](https://learn.openshift.com/servicemesh){:target="_blank"}
* [Istio Homepage](https://istio.io){:target="_blank"}
