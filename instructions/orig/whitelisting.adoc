# Access Control - Whitelisting

In this lab we will learn how to **Whitelist** i.e. to control the service to service access within
the service mesh.

## What you will learn

How to do [access control with Istio](https://istio.io/docs/tasks/security/secure-access-control.html){:target="_blank"}.

## Step 1

Create the **Whitelist** rules, this rule makes the `preference` services accessible only from the `recommendation` service
(effectively making the `customer` service unable to call the `preference` service and breaking our
usual `customer -> preference -> recommendation` chain):

~~~sh
oc create -f $ISTIO_LAB_HOME/src/istiofiles/acl-whitelist.yml -n $ISTIO_LAB_PROJECT
~~~

## Step 2

Lets now test the **Whitelisting** by calling the `customer` service:

~~~sh
curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
~~~

Invoking the above curl command should result in:

~~~console
customer => 404 NOT_FOUND:preferencewhitelist.listchecker.istio-lab:customer is not whitelisted
~~~

Trying to access the `recommendation` service from the `customer` service returns `HTTP 404`, as preference service is accessible only from the recommendation service.

> NOTE: It may take a few seconds before the whitelist is in effect. If you do not get the above `404` error,
keep trying! There is a time lag between the time Istio configuration changes are made and when they come into
effect. This time delay [can be tuned](https://github.com/istio/istio/issues/1485){:target="_blank"} to make a tradeoff between configuration change responsiveness and CPU
usage needed to discover and act on the configuration change.

## Step 3

Lets rollback the changes that were done for this **Whitelisting** lab:

~~~sh
oc delete -f $ISTIO_LAB_HOME/src/istiofiles/acl-whitelist.yml -n $ISTIO_LAB_PROJECT
~~~

And verify the services work again as expected:

~~~sh
curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
customer => preference => recommendation v1 from '5b67985cb9-bwhj7': 235
~~~

# Congratulations

Congratulations you have successfully learned how to define Access Control via **Whitelisting** inside a Istio service mesh

# References

* [Red Hat OpenShift](https://openshift.com){:target="_blank"}
* [Learn Istio on OpenShift](https://learn.openshift.com/servicemesh){:target="_blank"}
* [Istio Homepage](https://istio.io){:target="_blank"}
