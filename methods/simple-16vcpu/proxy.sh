#!/bin/bash

killall haproxy 2> /dev/null

ulimit -n 1000000

sudo dpbench/scripts/set-irq.sh ens5 4
sudo dpbench/scripts/set-irq.sh eth0 4

taskset -c 1-11 haproxy-2.3/haproxy -D -f methods/simple-16vcpu/proxy.cfg

echo "running proxy"
