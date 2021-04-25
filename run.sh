export PATH=$PATH:.

ssh ubuntu@$(lookup server) bash server.sh
ssh ubuntu@$(lookup proxy) bash proxy.sh cfgname

echo testing...

curl -q -v $(lookup server):8000/?s=100



# load generator -- connects to proxy

ulimit -n 100000
taskset -c 1 dpbench/bin/h1load -e -ll -P -t 46 -s 30 -d 120 -c 1150 http://proxy:8000/ | tee cli-run.dat

# reference client -- connects directly to server

ulimit -n 100000
taskset -c 1 dpbench/bin/h1load -e -ll -P -t 1 -s 30 -d 120 -R 1000 -c 128 http://server:8000/ | tee cli-ref.dat
