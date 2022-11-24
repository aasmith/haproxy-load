echo "hello client"

sudo dpbench/scripts/set-irq.sh ens5 16

echo "sleeping before starting test"
sleep 5

curl -q -vsS "server:8000/?s=1000"

echo "running test..."

ulimit -n 100000
(taskset -c 1 dpbench/bin/h1load -e -ll -P -t 1 -s 30 -d 120 -R 1000 -c 128 http://server:8000/ > results/ref.data) &

taskset -c 2-47 dpbench/bin/h1load -e -ll -P -t 46 -s 30 -d 120 -c 1196 http://proxy:8000/ | tee results/client.data


dpbench/tools/clients/h1load/scripts/split-report.sh -r results/client.data
dpbench/tools/clients/h1load/scripts/split-report.sh -r results/ref.data
dpbench/tools/clients/h1load/source/scripts/graph-pct.sh -o results/percentiles.png results/client.data-pctl results/ref.data-pctl:direct
dpbench/tools/clients/h1load/source/scripts/graph-rps-lat-ref-con_split.sh \
  -o results/rps.png \
  -r results/ref.data-load \
     results/client.data-load

cat /etc/*-release > results/DETAILS
uname -a >> results/DETAILS
curl http://169.254.169.254/latest/meta-data/instance-type >> results/DETAILS
echo >> results/DETAILS
curl http://169.254.169.254/latest/meta-data/ami-id >> results/DETAILS

# Usage: ./h1load [option]* URL
#
# The following arguments are supported :
#   -d <time>     test duration in seconds (0)
#   -c <conn>     concurrent connections (1)
#   -n <reqs>     maximum total requests (-1)
#   -r <reqs>     number of requests per connection (-1)
#   -s <time>     soft start: time in sec to reach 100% load
#   -t <threads>  number of threads to create (1)
#   -w <time>     I/O timeout in milliseconds (-1)
#   -T <time>     think time in ms after a response (0)
#   -R <rate>     limite to this many request attempts per second (0)
#   -H "foo:bar"  adds this header name and value
#   -O extra/payl overhead: #extra bytes per payload size
#   -l            enable long output format; double for raw values
#   -A            ignore 1st req for resp time measurements
#   -P            report ttfb/ttlb percentiles at the end
#   -e            stop upon first connection error
#   -F            merge send() with connect's ACK
#   -I            use HEAD instead of GET
#   -h            display this help
#   -v            increase verbosity
