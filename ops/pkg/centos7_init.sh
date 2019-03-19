#!/bin/bash
# Init  CentOS7
export PATH

nameserver=$1
if [ -z $1];then
echo -e "Use $0 DNS_IP \n Like $0 172.16.110.1"
exit 2
fi

# Kernal args modifed
cat /etc/sysctl.d/110-siss.conf << EOF
# IPv4转发开启
net.ipv4.ip_forward = 1

# 开启TCP连接中TIME-WAIT sockets的快速回收
net.ipv4.tcp_tw_recycle = 1

# 开启TCP连接复用
net.ipv4.tcp_tw_reuse = 1

# 开启对于TCP时间戳的支持
net.ipv4.tcp_timestamps = 1

# 出现SYN等待队列溢出时启用cookie处理，防范少量的SYN攻击。
net.ipv4.tcp_syncookies = 1

# 本地发起连接的端口范围
net.ipv4.ip_local_port_range = 1024 65000

# 监听端口的最大队列长度
net.core.somaxconn = 16384

# 应用参数
sysctl -p /etc/sysct.d/110-siss.conf
EOF

sysctl -p /etc/sysctl.d/110-siss.conf

# Add Local DNS
echo "nameserver ${nameserver}" >> /etc/resolv.conf
echo "echo nameserver ${nameserver} >> /etc/resolv.conf" >> /etc/rc.Local
chmod +x /etc/rc.d/rc.local

# Init Disk
# Data Disk alone mount,Use LVM
disks=$(fdisk -l |awk -F "Disk" '/dev/{print $2}' |awk -F ":" '{print $1}'|grep -v "^$")
echo "${disks}" | while read line
do
  disk_uuid=$(blkid ${line})
  if [ -z ${disk_uuid} ];then
    pvcreate ${line} && vgcreate data ${line} && lvcreate -n data -l 100%VG data    
done
mkdir /data && mkfs.xfs /dev/data/data
echo "/dev/data/data /data  xfs  defaults  1 1 " >> /etc/fstab && mount -a

# Install Docker Packets
curl https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo > docker-ce.repo
rpm -ivh https://mirrors.aliyun.com/zabbix/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
sed -i 's/gpgcheck=1/gpgcheck=0/g' docker-ce.repo zabbix.repo
yum install docker-ce vmstatus  zabbix-agent -y
cat /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opt": {
    "max-file": "7",
    "max-size": "5M"
  },
  "data-root": "/data/docker"
}
EOF
systemctl enable docker && systemctl start docker

# Install Zabbix Monitor
sed -i 's/127.0.0.1/zabbix.siss.io/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/Hostname=Zabbix Server/#Hostname=Zabbix Server/g' /etc/zabbix/zabbix_agentd.conf
sed -i 's/#HostMetadata=/HostMetadata=linux/g' /etc/zabbix/zabbix_agentd.conf
systemctl enable zabbix_agent && systemctl restart zabbix_agent

# Limit journald Log file size
cat /etc/systemd/journald.conf << EOF
SystemMaxUse=50M
RuntimeMaxUse=50M
SystemMaxFiles=10
RuntimeMaxFiles=10
EOF
systemctl restart systemd-journald

# Modifyed limts.conf
cat /etc/security/limits.conf << EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc  65536
* soft nproc  65536
EOF

# Rsyslog Send syslog to Graylog
echo "*.*    @graylog.siss.io:514;RSYSLOG_SyslogProtocol23Format" >> /etc/rsyslog.conf
systemctl restart rsyslog