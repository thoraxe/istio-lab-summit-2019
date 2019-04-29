#!/bin/bash

function curl_gateway(){
  j=0
  while [ $j -lt 50 ]; do
    curl http://${INGRESS_GATEWAY}/
    j=$[$j+1]
  done
}

i=0
while [ $i -lt 20 ]; do
 curl_gateway &
 i=$[$i+1]
done

