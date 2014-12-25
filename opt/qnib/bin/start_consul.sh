#!/bin/bash

## Check if eth0 already exists
ADDR=eth1
ip addr show ${ADDR} > /dev/null
EC=$?
if [ ${EC} -eq 1 ];then
    echo "## Wait for pipework to attach device 'eth1'"
    pipework --wait
fi

/opt/consul/consul agent -server -bootstrap-expect 1 -data-dir /tmp/consul/ -ui-dir /opt/consul/dist/ -config-dir=/etc/consul.d/ -client=0.0.0.0 

