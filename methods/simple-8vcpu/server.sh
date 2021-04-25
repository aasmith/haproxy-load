killall httpterm 2> /dev/null
sudo sysctl net.ipv4.tcp_fin_timeout=30

sudo dpbench/scripts/set-irq.sh ens5 2
sudo dpbench/scripts/set-irq.sh eth0 2

ulimit -n 200000

for i in {1..5}; do taskset -c 1-5 dpbench/bin/httpterm -D -L :8000;done
for i in {1..5}; do taskset -c 1-5 dpbench/bin/httpterm -D -L :8001;done
for i in {1..5}; do taskset -c 1-5 dpbench/bin/httpterm -D -L :8002;done
for i in {1..5}; do taskset -c 1-5 dpbench/bin/httpterm -D -L :8003;done
for i in {1..5}; do taskset -c 1-5 dpbench/bin/httpterm -D -L :8004;done

echo "running server!"
