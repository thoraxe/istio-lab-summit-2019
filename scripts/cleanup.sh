#!/bin/bash
oc cluster down
mount | grep openshift | awk '{print $3}' | xargs umount
rm -rf /var/lib/origin/*
