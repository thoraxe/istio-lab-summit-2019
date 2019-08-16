export INGRESS_GATEWAY=$(oc get route -n istio-system istio-ingressgateway -o 'jsonpath={.spec.host}')

echo "A load generating script is running in the next step. Ctrl+C to stop"

while :; do curl http://${INGRESS_GATEWAY} &> /dev/null ; done
