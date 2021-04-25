killall httpterm 2> /dev/null

ulimit -n 1000000

sudo dpbench/scripts/set-irq.sh ens5 4
sudo dpbench/scripts/set-irq.sh eth0 4


taskset -c 1  dpbench/bin/httpterm -D -L :8000
taskset -c 2  dpbench/bin/httpterm -D -L :8001
taskset -c 3  dpbench/bin/httpterm -D -L :8002
taskset -c 4  dpbench/bin/httpterm -D -L :8003
taskset -c 5  dpbench/bin/httpterm -D -L :8004
taskset -c 6  dpbench/bin/httpterm -D -L :8005
taskset -c 7  dpbench/bin/httpterm -D -L :8006
taskset -c 8  dpbench/bin/httpterm -D -L :8007
taskset -c 9  dpbench/bin/httpterm -D -L :8008
taskset -c 10 dpbench/bin/httpterm -D -L :8009
taskset -c 11 dpbench/bin/httpterm -D -L :8010

echo "running server!"
