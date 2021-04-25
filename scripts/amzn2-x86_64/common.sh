# Run on every instance, regardless of role

sudo systemctl stop irqbalance
sudo systemctl stop crond

echo "Updating and installing packages..."
sudo yum update -y
sudo yum groupinstall -y 'Development Tools'
sudo yum install -y openssl-devel tuned perf gcc10 openssl-devel zlib-devel pcre2-devel


/usr/bin/gcc10-gcc --version

sudo tee "/etc/security/limits.d/more.conf" > /dev/null <<'EOF'
# <domain> <type> <item>  <value>
    *       soft  nofile  1000000
    *       hard  nofile  1000000
EOF


# This reduces tail latency by a factor of 6x (@p99.9 6ms -> 0.8ms)
sudo tuned-adm profile network-latency

# Common tools

echo "Installing common tools..."

git clone https://github.com/dpbench/dpbench
pushd dpbench
git submodule init && git submodule update && git submodule foreach git pull origin master
bash ./tools/build-all.sh
ls -l bin
popd

mkdir configs
mkdir results

# from uniproxy.sh

#sudo sysctl net.ipv4.tcp_max_syn_backlog=65535
#sudo sysctl net.core.rmem_max=8388607
#sudo sysctl net.core.wmem_max=8388607
#sudo sysctl net.ipv4.tcp_rmem="4096 8388607 8388607"
#sudo sysctl net.ipv4.tcp_wmem="4096 8388607 8388607"
#sudo sysctl net.core.somaxconn=65535
#sudo sysctl net.ipv4.tcp_autocorking=0
#
#sudo sysctl fs.file-max=5000000
#sudo sysctl net.core.netdev_max_backlog=400000
#sudo sysctl net.core.optmem_max=10000000
#sudo sysctl net.core.rmem_default=10000000
#sudo sysctl net.core.rmem_max=10000000
#sudo sysctl net.core.somaxconn=100000
#sudo sysctl net.core.wmem_default=10000000
#sudo sysctl net.core.wmem_max=10000000
#sudo sysctl net.ipv4.conf.all.rp_filter=1
#sudo sysctl net.ipv4.conf.default.rp_filter=1
#sudo sysctl net.ipv4.ip_local_port_range="1024 65535"
#sudo sysctl net.ipv4.tcp_ecn=0
#sudo sysctl net.ipv4.tcp_max_syn_backlog=12000
#sudo sysctl net.ipv4.tcp_max_tw_buckets=2000000
#sudo sysctl net.ipv4.tcp_mem="30000000 30000000 30000000"
#sudo sysctl net.ipv4.tcp_rmem="30000000 30000000 30000000"
#sudo sysctl net.ipv4.tcp_sack=1
#sudo sysctl net.ipv4.tcp_syncookies=0
#sudo sysctl net.ipv4.tcp_timestamps=1
#sudo sysctl net.ipv4.tcp_wmem="30000000 30000000 30000000"
#
#
#
#sudo modprobe tcp_bbr
#sudo modprobe sch_fq
#sudo sysctl -w net.ipv4.tcp_congestion_control=bbr
