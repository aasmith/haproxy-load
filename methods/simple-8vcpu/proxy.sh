#!/bin/bash

killall haproxy 2> /dev/null
sudo sysctl net.ipv4.tcp_fin_timeout=30

sudo dpbench/scripts/set-irq.sh ens5 2
sudo dpbench/scripts/set-irq.sh eth0 2

ulimit -n 200000
taskset -c 1-5 haproxy-2.3/haproxy -D -f methods/simple-8vcpu/proxy.cfg

echo "running proxy"
