#!/bin/sh

export CURL_POD=$(oc4 get pods -n istio-tutorial -l app=curl | grep curl | awk '{ print $1}' )
export CUSTOMER_POD=$(oc4 get pods -n istio-tutorial -l app=customer | grep customer | awk '{ print $1}' )

while :; do 

echo "Executing curl in curl pod"
oc4 exec $CURL_POD curl http://preference:8080

echo "Executing curl in customer pod"
oc4 exec $CUSTOMER_POD -c customer curl http://preference:8080

done

