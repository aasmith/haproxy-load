#!/bin/bash

sudo systemctl stop irqbalance
sudo systemctl stop snapd
sudo systemctl stop cron

sudo apt-get update
sudo apt-get install -y build-essential libssl-dev libpcre2-dev zlib1g-dev gcc-10

git clone http://git.haproxy.org/git/haproxy-2.3.git/

pushd haproxy-2.3
make clean && make TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE2=1 CC=/usr/bin/gcc-10
./haproxy -vv
popd

git clone https://github.com/dpbench/dpbench
pushd dpbench
git submodule init && git submodule update
bash ./tools/build-all.sh
ls -l bin
popd

cat > test.cfg <<EOF
defaults
   mode http
   timeout client 60s
   timeout server 60s
   timeout connect 1s
    
listen px
   bind :8000
   balance random
   server s1 server:8001
EOF

sudo tee -a /etc/hosts >> /dev/null << EOF
10.53.75.107  client  
10.53.74.0    logspout
10.53.87.158  proxy   
10.53.80.224  server  
EOF

taskset -c 0 haproxy-2.3/haproxy -D -f test.cfg

