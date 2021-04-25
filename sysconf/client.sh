#!/bin/sh

apt-get update
apt-get install -y build-essential git libssl-dev

git clone https://github.com/wtarreau/h1load

cd h1load
make
./h1load -h

