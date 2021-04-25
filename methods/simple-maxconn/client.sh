sudo dpbench/scripts/set-irq.sh ens5 1
sudo dpbench/scripts/set-irq.sh eth0 1

echo "client: sleeping before starting test"
sleep 5

curl -q -vsS "server:8000/?s=1000"
sleep 1

echo "client: running test..."

ulimit -n 100000
(taskset -c 1 dpbench/bin/h1load -e -ll -P -t 1 -s 30 -d 120 -R 1000 -c 128 http://server:8000/ > results/ref.data) &

taskset -c 0-1 dpbench/bin/h1load -e -ll -P -t 1 -s 30 -d 120 -c 10000 http://proxy:8000/ | tee results/client.data



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
