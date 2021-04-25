#!/bin/bash

# Final steps to unload conntrack

while ! service iptables status; do
  sleep 1
done

service docker stop
service iptables stop
chkconfig iptables off
chkconfig ip6tables off

for m in $(lsmod | egrep '^(nf|xt|x|ipt)_' | awk '{print $1}'); do modprobe -r $m; done

# All conntrack-related modules should be unloaded by now.
lsmod

# Disables HTT. Based on
# https://aws.amazon.com/blogs/compute/disabling-intel-hyper-threading-technology-on-amazon-linux/

cpucount=$(cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list | wc -l)

sed -i '/^kernel/ s/$/ maxcpus='"$((cpucount / 2))"'/' /boot/grub/grub.conf

for cpunum in $(cat /sys/devices/system/cpu/cpu*/topology/thread_siblings_list | cut -s -d, -f2- | tr ',' '\n' | sort -un)
do
	echo 0 > /sys/devices/system/cpu/cpu$cpunum/online
done

# Disable conntrack. Verify with `sysctl net.netfilter.nf_conntrack_count` (it should fail)
cat << EOF >> /etc/sysconfig/docker
OPTIONS="--iptables=false --ip-masq=false"
EOF

########

modprobe tcp_bbr
modprobe sch_fq
sysctl -w net.ipv4.tcp_congestion_control=bbr

cat << EOF >> /etc/sysconfig/modules/tcpcong.modules
#!/bin/bash
/sbin/modprobe tcp_bbr >/dev/null 2>&1
/sbin/modprobe sch_fq >/dev/null 2>&1
EOF

chmod 755 /etc/sysconfig/modules/tcpcong.modules

echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.d/00-tcpcong.conf

#########

cat << EOF >> /etc/sysctl.conf
fs.file-max = 5000000
net.core.netdev_max_backlog = 400000
net.core.optmem_max = 10000000
net.core.rmem_default = 10000000
net.core.rmem_max = 10000000
net.core.somaxconn = 100000
net.core.wmem_default = 10000000
net.core.wmem_max = 10000000
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_max_syn_backlog = 12000
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_mem = 30000000 30000000 30000000
net.ipv4.tcp_rmem = 30000000 30000000 30000000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_wmem = 30000000 30000000 30000000
EOF

sysctl -p

cat << EOF >> /etc/security/limits.conf
* soft nofile 200000
* hard nofile 200000
EOF

### irq pinning
yum remove -y irqbalance

# Set all IRQs to use core 1 (0x02)
for i in /proc/irq/*/smp_affinity; do echo 2 > $i; done

# Disable conntrack on future boots

cat << EOF >> /etc/modprobe.d/blacklist.conf
blacklist nf_conntrack
blacklist nf_conntrack_netlink
blacklist xt_conntrack
blacklist nf_nat
EOF

cat << EOF >> /etc/modprobe.d/nf_conntrack.conf
install nf_conntrack /bin/true
EOF

cat << EOF >> /etc/modprobe.d/nf_conntrack_netlink.conf
install nf_conntrack_netlink /bin/true
EOF

cat << EOF >> /etc/modprobe.d/xt_conntrack.conf
install xt_conntrack /bin/true
EOF

cat << EOF >> /etc/modprobe.d/nf_nat.conf
install nf_nat /bin/true
EOF

cat << EOF >> /etc/ecs/ecs.config
ECS_ENABLE_TASK_IAM_ROLE=false
ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=false
EOF

# This is a TODO XXX HACK :sadpanda:
# Remove and link iptable's control binary to a binary that always returns true.
# This is done because some applications have inextricable dependencies on
# iptables. Having them call iptables will either fail, or re-enable conntrack,
# depending on their level of evil. (Yes this hack is evil too)

rm /sbin/iptables
ln -s /bin/true /sbin/iptables

service docker start
start ecs


wall complete
touch /tmp/complete-base

# TODO exclude iptables package so it doesnt get upgraded with a nice working binary
# https://www.cyberciti.biz/faq/rhel-fedora-centos-linux-yum-disable-certain-packages-from-being-installed/
