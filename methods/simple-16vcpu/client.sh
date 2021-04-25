echo "hello client"

killall h1load 2> /dev/null
killall wrk 2> /dev/null

ulimit -n 1000000

sudo dpbench/scripts/set-irq.sh ens5 4
sudo dpbench/scripts/set-irq.sh eth0 4

echo "sleeping before starting test"
sleep 5

curl -q -vsS "server:8000/?s=1000"

echo "running test..."

(taskset -c 0 dpbench/bin/h1load -e -ll -P -t 1 -s 30 -d 120 -R 1000 -c 10 "http://server:8000/?t=500" > results/ref.data) &

taskset -c 1-11  dpbench/bin/h1load -e -ll -P -t 11 -s 60 -d 120 -c 15000 -R 15000 "http://proxy:8000/?t=500"



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
