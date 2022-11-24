#!/bin/bash

killall haproxy 2> /dev/null

sudo dpbench/scripts/set-irq.sh ens5 16

ulimit -n 100000
taskset -c 2-47 haproxy-dev/haproxy -D -f methods/simple-c6gn-16xl/proxy.cfg

echo "running proxy"
