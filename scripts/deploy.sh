#!/usr/bin/env bash
#
# Deploy services to OpenShift/Istio
# Assumes you are oc-login'd and istio is installed and istioctl available at $ISTIO_HOME
#
MYHOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd -P)"
DEPLOYMENT_DIR="${MYHOME}/src/deployments"

# name of project in which we are working
PROJECT=${PROJECT:-tutorial}

oc new-project ${PROJECT} || exit 1
oc adm policy add-scc-to-user privileged -z default -n ${PROJECT}

# deploy customer
oc create -f ${DEPLOYMENT_DIR}/customer.yaml

# deploy preferences
oc create -f ${DEPLOYMENT_DIR}/preference.yaml

# deploy recommendation
oc create -f ${DEPLOYMENT_DIR}/recommendation.yaml

# deploy gateway
oc create -f ${DEPLOYMENT_DIR}/gateway.yaml
