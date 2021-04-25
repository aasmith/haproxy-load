#!/bin/bash

killall haproxy 2> /dev/null

sudo dpbench/scripts/set-irq.sh ens5 1
sudo dpbench/scripts/set-irq.sh eth0 1

ulimit -n 100000
taskset -c 0-1 haproxy-dev/haproxy -D -f methods/simple-maxconn/proxy.cfg

echo "proxy: running"
