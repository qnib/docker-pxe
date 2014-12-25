#!/bin/bash

## Check if eth0 already exists
ADDR=eth1
ip addr show ${ADDR} > /dev/null
EC=$?
if [ ${EC} -eq 1 ];then
    echo "## Wait for pipework to attach device 'eth1'"
    pipework --wait
fi

function wait_ps {
    if [ $(ps -ef|grep -v grep|grep ${1}) ];then
        sleep 5
        wait_ps ${1}
    fi
}
dnsmasq --no-daemon --pid-file=/var/run/dnsmasq.pid &
sleep 5
wait_ps dnsmasq

