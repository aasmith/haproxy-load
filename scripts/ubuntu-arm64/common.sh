# Run on every instance, regardless of role

sudo systemctl stop irqbalance
sudo systemctl stop snapd
sudo systemctl stop cron


# find timer-based services to stop:
# sudo systemctl list-timers
sudo systemctl stop logrotate.timer man-db.timer e2scrub_all.timer motd-news.timer apt-daily-upgrade.timer apt-daily.timer fwupd-refresh.timer systemd-tmpfiles-clean.timer fstrim.timer

sudo systemctl stop -q man-db apt-daily

####

## attempt to follow https://access.redhat.com/sites/default/files/attachments/201501-perf-brief-low-latency-tuning-rhel7-v1.1.pdf
#
sudo DEBIAN_FRONTEND=noninteractive apt-get update  -qq > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tuned "linux-tools-$(uname -r)" -qq > /dev/null
#
#sudo modprobe -r ebtable_nat ebtables
#sudo modprobe -r ipt_SYNPROXY nf_synproxy_core xt_CT nf_conntrack_ftp \
#            nf_conntrack_tftp nf_conntrack_irc nf_nat_tftp ipt_MASQUERADE \
#            iptable_nat nf_nat nf_nat \
#             xt_state xt_conntrack iptable_raw \
#            nf_conntrack iptable_filter iptable_raw iptable_mangle \
#            ipt_REJECT xt_CHECKSUM ip_tables nf_defrag_ipv4 ip6table_filter \
#            ip6_tables nf_defrag_ipv6 ip6t_REJECT xt_LOG xt_multiport \
#            nf_conntrack ip_tables x_tables
#

# This reduces tail latency by a factor of 6x (@p99.9 6ms -> 0.8ms)
sudo tuned-adm profile network-latency

####


echo "Updating and installing packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libssl-dev libpcre2-dev zlib1g-dev gcc-10  -qq > /dev/null

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
