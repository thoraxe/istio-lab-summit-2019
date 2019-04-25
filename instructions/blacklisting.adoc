# Access Control - Blacklisting

In this lab we will learn how to **Blacklist** a service i.e. to make one service inaccessible to other service(s) within the service mesh.

## What you will learn

How to do [access control with Istio](https://istio.io/docs/tasks/security/secure-access-control.html){:target="_blank"}.

## Step 1

Lets create the rule to define the **Blacklisting**,  this rule will prevent the _preference_ service inaccessible to _customer_ service 

~~~sh
oc create -f $ISTIO_LAB_HOME/src/istiofiles/acl-blacklist.yml -n $ISTIO_LAB_PROJECT
~~~
## Step 2

Lets test the **Blacklist** rules:

~~~sh
curl "http://customer-${ISTIO_LAB_PROJECT}.{{APPS_SUFFIX}}"
~~~

When we tried to access the customer service, it will return `HTTP 403` forbidden error as the customer service cant access the preference service.   

The output will look something like:

~~~sh
customer => 403 PERMISSION_DENIED:denycustomerhandler.denier.istio-lab:Not allowed
~~~

## Step 3

Let's rollback the **Blacklist** rules:

~~~sh
oc delete -f $ISTIO_LAB_HOME/src/istiofiles/acl-blacklist.yml -n $ISTIO_LAB_PROJECT
~~~

# Congratulations

Congratulations you have successfully learnt how to define Access Control via **Blacklisting** inside a Istio service mesh.

# References

* [Red Hat OpenShift](https://openshift.com){:target="_blank"}
* [Learn Istio on OpenShift](https://learn.openshift.com/servicemesh){:target="_blank"}
* [Istio Homepage](https://istio.io){:target="_blank"}
