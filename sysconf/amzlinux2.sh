#!/bin/bash

sudo systemctl stop irqbalance
sudo systemctl stop crond

sudo yum groupinstall -y 'Development Tools'
sudo yum install -y openssl-devel tree

git clone http://git.haproxy.org/git/haproxy-2.2.git/

pushd haproxy-2.2
make clean && make TARGET=linux-glibc USE_OPENSSL=1 USE_ZLIB=1 USE_PCRE=1
./haproxy -vv
popd

git clone https://github.com/dpbench/dpbench
pushd dpbench
git submodule init && git submodule update
./tools/build-all.sh
ls -l bin
popd



cat > test.cfg <<EOF
foo
EOF
