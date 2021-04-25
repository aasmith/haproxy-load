killall httpterm 2> /dev/null

sudo dpbench/scripts/set-irq.sh ens5 1
sudo dpbench/scripts/set-irq.sh eth0 1

ulimit -n 100000
for i in {0..1}; do taskset -c 0-1 dpbench/bin/httpterm -D -L :8000;done

echo "server: running"
