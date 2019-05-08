export INGRESS_GATEWAY=$(oc4 get route -n istio-system istio-ingressgateway -o 'jsonpath={.spec.host}')
while :; do curl http://${INGRESS_GATEWAY} ; done
