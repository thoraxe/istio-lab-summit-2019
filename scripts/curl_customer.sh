alias oc=oc4
export INGRESS_GATEWAY=$(oc get route -n istio-system istio-ingressgateway -o 'jsonpath={.spec.host}')
while :; do curl http://${INGRESS_GATEWAY} ; done
