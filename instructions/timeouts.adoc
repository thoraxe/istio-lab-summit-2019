# Timeout

In this Lab you wil lean how to induce timeout for a service as part of Istio Service Mesh.
With timeout set the service mesh will return failure if it does not get response within **N** seconds.


## What you will learn

How to handle timeout with services that are deployed in Istio Service Mesh.

## Step 1

At this point, no other route rules should be in effect. Run `oc get routerules` and `oc delete routerule --all` if there are some.

## Step 2

Change the configuration of `recommendation:v2` service to use the container image `recommendation:v2d` which has a built-in delay of 3 seconds.

~~~sh
oc patch deployment recommendation-v2 -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"recommendation\",\"image\":\"${ISTIO_LAB_PROJECT}/recommendation:v2d\"}]}}}}"
~~~

Then test that the 3 second delay works as expected:

~~~
while true ; do time curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}" ; sleep .1 ; done
~~~
The output should show access to `recommendation:v1` is immediate (`real 0m0.042s`) and the
access to `recommendation:v2` takes about 3 seconds (`real 0m3.038s`):

~~~
customer => preference => recommendation v1 from '5b67985cb9-bwhj7': 203

real	0m0.042s
user	0m0.004s
sys	0m0.010s
customer => preference => recommendation v2 from '6ccff46b59-7gjfm': 14

real	0m3.038s
user	0m0.005s
sys	0m0.011s
~~~

## Step 3

Apply the istio timeout rule:

~~~sh
oc create -f $ISTIO_LAB_HOME/src/istiofiles/route-rule-recommendation-timeout.yml -n $ISTIO_LAB_PROJECT
~~~

This will cause istio to only wait 1 second before timing out and returning `HTTP 503`. Since the `recommendation:v2` service
now has a 3 second delay, this should cause Istio to immediately timeout after 1s and return a `503` error for access to
`recommendation:v2`.

## Step 4

Verify if timeout is happening as expected

~~~bash
while true ; do time curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}" ; sleep .1 ; done
~~~

Output should be:

~~~
customer => 503 preference => 504 upstream request timeout

real	0m1.043s
user	0m0.006s
sys	0m0.006s
customer => 503 preference => 504 upstream request timeout

real	0m1.035s
user	0m0.005s
sys	0m0.008s
customer => 503 preference => 504 upstream request timeout

real	0m1.035s
user	0m0.006s
sys	0m0.007s
~~~

You will see it return "504 upstream request timeout" after waiting about 1 second (`real 0m1.035s`) for each attempt

## Cleanup 

Let's now clean up the timeout istio rule and revert back to the non-delayed `recommendation-v2`:

~~~sh
oc delete routerule --all -n $ISTIO_LAB_PROJECT
oc patch deployment recommendation-v2 -p "{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"recommendation\",\"image\":\"${ISTIO_LAB_PROJECT}/recommendation:v2\"}]}}}}"
~~~

# Congratulations

Congratulations you have successfully learned how to create and apply an Istio Timeout Route Rule.

# References

* [Istio Homepage](https://istio.io){:target="_blank"}
* [Red Hat OpenShift](https://openshift.com){:target="_blank"}
* [Learn Istio on OpenShift](https://learn.openshift.com/servicemesh){:target="_blank"}
