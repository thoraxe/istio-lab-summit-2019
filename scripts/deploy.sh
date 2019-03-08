#!/usr/bin/env bash
#
# Deploy services to OpenShift/Istio
# Assumes you are oc-login'd and istio is installed and istioctl available at $ISTIO_HOME
#
MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MYHOME=${MYDIR}/..

# istio binaries
ISTIO_VERSION=0.6.0
ISTIO_HOME=${HOME}/istio-${ISTIO_VERSION}

# name of project in which we are working
PROJECT=${PROJECT:-istio-lab}

oc new-project ${PROJECT} || exit 1
oc adm policy add-scc-to-user privileged -z default -n ${PROJECT}

# deploy customer service
oc apply -f <(${ISTIO_HOME}/bin/istioctl kube-inject -f ${MYHOME}/src/customer/src/main/kubernetes/Deployment.yml) -n ${PROJECT}
oc create -f ${MYHOME}/src/customer/src/main/kubernetes/Service.yml -n ${PROJECT}
oc expose svc/customer

# deploy preferences service
oc apply -f <(${ISTIO_HOME}/bin/istioctl kube-inject -f ${MYHOME}/src/preference/src/main/kubernetes/Deployment.yml) -n ${PROJECT}
oc create -f ${MYHOME}/src/preference/src/main/kubernetes/Service.yml -n ${PROJECT}

# deploy recommendation:v1
oc apply -f <(${ISTIO_HOME}/bin/istioctl kube-inject -f ${MYHOME}/src/recommendation/src/main/kubernetes/Deployment.yml) -n ${PROJECT}
oc create -f ${MYHOME}/src/recommendation/src/main/kubernetes/Service.yml -n ${PROJECT}

# deploy recommendation:v2
oc apply -f <(${ISTIO_HOME}/bin/istioctl kube-inject -f ${MYHOME}/src/recommendation/src/main/kubernetes/Deployment-v2.yml) -n ${PROJECT}

echo "Customer access url"
echo "-------------------"
echo "http://$(oc get route customer -n ${PROJECT} --template='{{ .spec.host }}')"

# during lab, replace recommendation:v2 with the delayed version for testing
# oc patch deployment/recommendation-v2 -p '{"spec": { "template": { "spec": { "containers": [ { "name": "recommendation", "image": "istio-lab/recommendation:v2d"} ] }}}}'

# during lab, go back to v2 without delay
# oc patch deployment/recommendation-v2 -p '{"spec": { "template": { "spec": { "containers": [ { "name": "recommendation", "image": "istio-lab/recommendation:v2"} ] }}}}'

# move all users to v1
# oc create -f ${MYHOME}/src/istiofiles/route-rule-recommendation-v1.yml -n ${PROJECT}

# split 50/50
# oc delete routerule --all
# oc create -f ${MYHOME}/src/istiofiles/route-rule-recommendation-v1_and_v2_50_50.yml -n ${PROJECT}

# cleanup
# oc delete routerule --all







