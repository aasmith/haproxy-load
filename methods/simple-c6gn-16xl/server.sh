killall httpterm 2> /dev/null

sudo dpbench/scripts/set-irq.sh ens5 16

ulimit -n 100000

for i in {2..47}; do taskset -c 2-47 dpbench/bin/httpterm -D -L :8000;done

echo "running server!"
