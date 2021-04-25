haproxy-load
------------

A tool for generating repeatable load tests of haproxy configurations.

Requirements
------------

Four machines, running Linux (centos, Amazon Linux etc.) ideally on the same
network segment. In AWS parlance, this would be the same AZ within a region.

 * Proxy: the instance running haproxy.
 * Server: target for backend connections from haproxy.
 * Client: generates HTTP requests into the proxy frontend.
 * Logspout: a UDP collector for haproxy log messages.

A local clone of h1load (git clone https://github.com/wtarreau/h1load.git)
A recent version of gnuplot (brew install gnuplot)
A way to provision compute. Putting some terraform in the `compute` dir would
be good.

Getting Started
---------------

Provide the IPs of the four instances:

```
$ cat instances
10.10.10.1   proxy    # ubuntu
10.10.10.2   server   # amazonlinux2
10.10.10.3   client   # amazonlinux2
10.10.10.4   logspout # amazonlinux2
```

If you used terraform to provision your compute, this list can be generated 
using `tf2instances.rb`.

```
# set up each machine with OS settings, download compile tools, etc.
setup syscfg
setup init

# push app configs to each machine
setup appcfg

# run tests, using the "simple" method
# download & process data of the last run
setup science simple

# or as two steps...
setup try simple
setup analyze simple

# <make app config edits>
vi stuff

# push app config changes
setup appcfg

# run tests again
...



pushcfg

run cfgs
run init
run run

# observe action

# get perf file from h1load, gnuplot it

# tweak configs

run cfgs
run run
```

What happens
------------

Sets up each machine to serve a specific role:

 server:   absorbs load using httpterm
 client:   generates load using h1load
 proxy:    handles load using haproxy
 logspout: accepts logs from haproxy



Resources
---------

https://www.haproxy.com/blog/haproxy-forwards-over-2-million-http-requests-per-second-on-a-single-aws-arm-instance/
