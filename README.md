# Red Hat Summit 2019: 
# Red Hat OpenShift Service Mesh in Action

## Purpose

As microservices-based applications become more prevalent, both the number of
and complexity of their interactions increases. Up until now much of the burden
of managing these complex microservices interactions has been placed on the
application developer, with different or non-existent support for microservice
concepts depending on language and framework.

The service mesh concept pushes this responsibility to the infrastructure, with
features for traffic management, distributed tracing and observability, policy
enforcement, and service/identity security, freeing the developer to focus on
business value. In this hands-on session you will learn how to apply some of
these features to a simple polyglot microservices application running on top of
OpenShift using Istio, an open platform to connect, manage, and secure
microservices.

## Background

Istio is an open platform to connect, manage, and secure microservices. Istio
provides an easy way to create a network of deployed services with load
balancing, service-to-service authentication, monitoring, and more, without
requiring any changes in application code. OpenShift can automatically inject a
special sidecar proxy throughout your environment to enable Istio management for
your application. This proxy intercepts all network communication between your
microservices microservices, and is configured and managed using Istio’s control
plane functionality -- not your application code!

Kiali is an observability console designed to provide operational insight
into the behavior and performance of the service mesh as a whole.

Jaeger is a utility for capturing distributed tracing information of requests
as they travel throughout the mesh.

Prometheus and Grafana are used to capture metrics about the performance and
behavior of the mesh.

These components combined together are the Red Hat OpenShift Service Mesh.

# Using this lab content elsewhere
While this lab content was designed against the environment provided at the
Red Hat Summit, the content can be used and deployed in virtually any
OpenShift environment. It does, however, assume an OpenShift 4 environment.

## Deploy the Lab Guide
You can deploy the lab guide as a container image. There are two steps.
First, you need to gather information about your environment. Then, you can
launch the lab guide using that information.

### Gathering Environment Information
Deploying the lab guide will take two steps. First, you will need to get
information about your cluster. Second, you will deploy the lab guide using
the information you found so that proper URLs and references are
automatically displayed in the guide.

### Required Information
Most of the information can be found in the output of the installer.

1. Export the API URL endpoint to an environment variable:

    ```bash
    export API_URL=https://api......:6443
    ```

2. Export the master/console URL to an environment variable:

    ```bash
    export MASTER_URL=https://console-openshift-console.....
    ```

3. Export the `kubeadmin` password as an environment variable:

    ```bash
    export KUBEADMIN_PASSWORD=xxx
    ```

    If you don't have the `kubeadmin` password but you do have a user that has access to the OpenShift 4 cluster, just be sure to log in with that user instead of `kubeadmin` where instructed in the lab guide.

4. Export the routing subdomain as an environment variable. When you
  installed your cluster you specified a domain to use, and OpenShift built a
  routing subdomain that looks like `apps.clusterID.domain`. For example,
  `apps.mycluster.company.com`. Export this:

    ```bash
    export ROUTE_SUBDOMAIN=apps.mycluster.company.com
    ```

5. This lab guide was built for an internal Red Hat system, so there are two
  additional things you will need to export. Please export them exactly as
  follows:

    ```bash
    export GUID=xxxx
    export BASTION_FQDN=foo.bar.com
    ```

### Deploy the Lab Guide
Now that you have exported the various required variables, you can deploy the
lab guide into your cluster. The following assumes you are logged in already
as `kubeadmin` and on a system with the `oc` client installed:

```bash
oc new-app https://raw.githubusercontent.com/openshift-labs/workshop-dashboard/3.7.1/templates/production.json -n labguide \
      --param APPLICATION_NAME=istio \
      --param TERMINAL_IMAGE=quay.io/openshiftlabs/workshop-dashboard:3.7.1 \
      --param GATEWAY_ENVVARS="TERMINAL_TAB=split" \
      --param DOWNLOAD_URL=https://raw.githubusercontent.com/thoraxe/istio-lab-summit-2019/dev/instructions/ \
      --param WORKSHOP_FILE=_rhsummit18.yml \
      --param WORKSHOP_ENVVARS=" \
API_URL=$API_URL \
MASTER_URL=$MASTER_URL \
KUBEADMIN_PASSWORD=$KUBEADMIN_PASSWORD \
BASTION_FQDN=$BASTION_FQDN \
GUID=$GUID \
ROUTE_SUBDOMAIN=$ROUTE_SUBDOMAIN \
SMCP_PROJECT_NAME=defaultsmcpprojectname \
PERUSER_ISTIO_TUTORIAL_PROJECTNAME=defaultperuseristiotutorialprojectname"
```

## Deploying the App
In the `/src/deployments` folder of this repository are several YAML files. You will want to create a project called `istio-tutorial` and then `create` all of these YAML files. For example:

```bash
oc new-project istio-tutorial
oc create -n istio-tutorial -f https://raw.githubusercontent.com/thoraxe/istio-lab-summit-2019/master/src/deployments/curl.yaml
oc create -n istio-tutorial -f https://raw.githubusercontent.com/thoraxe/istio-lab-summit-2019/master/src/deployments/customer.yaml
oc create -n istio-tutorial -f https://raw.githubusercontent.com/thoraxe/istio-lab-summit-2019/master/src/deployments/gateway.yaml
oc create -n istio-tutorial -f https://raw.githubusercontent.com/thoraxe/istio-lab-summit-2019/master/src/deployments/preference.yaml
oc create -n istio-tutorial -f https://raw.githubusercontent.com/thoraxe/istio-lab-summit-2019/master/src/deployments/recommendation.yaml
```

## Doing the Labs
Your lab guide should deploy in a few moments. To find its url, execute:

```bash
oc get route admin -n labguide
```

You should be able to visit that URL and see the lab guide. From here you can
follow the instructions in the lab guide.

## Notes and Warnings
Remember, this experience is designed for a provisioning system internal to
Red Hat. Your lab guide will be mostly accurate, but slightly off.

* You aren't likely using `lab-user`
* You will probably not need to actively use your `GUID`
* You will see lots of output that references your `GUID` or other slightly off
  things
* Your `MachineSets` are different depending on the EC2 region you chose

But, generally, everything should work. Just don't be alarmed if something
looks mostly different than the lab guide.

## Removing Application
```bash
oc delete all,serviceaccounts,rolebindings,configmaps -l app=istio -n labguide
```