#!/bin/bash

killall haproxy 2> /dev/null

ulimit -n 100000
taskset -c 0 haproxy-2.3/haproxy -D -f methods/simple/proxy.cfg
