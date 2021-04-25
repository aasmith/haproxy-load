killall httpterm 2> /dev/null

ulimit -n 100000
# for i in {2..47}; do taskset -c 2-47 httpterm -D -L :8000;done
taskset -c 0 dpbench/bin/httpterm -D -L :8000

echo "running server!"
