# 操作系统标准化

## 使用内部DNS服务器

```bash
echo "nameserver 172.18.171.112" >> /etc/resolv.conf
# 另外需要将网卡配置加上本地DNS配置，防止重启丢失DNS
```


## 内核参数调整

```bash
vim /etc/sysctl.d/110-siss.conf

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
```

## 数据卷使用LVM，并独立挂载

```bash
# 查看系统所有磁盘
fdisk -l

#假设空白磁盘为/dev/xvdc,建立PV/VG/LV
pvcreate /dev/xvdc  && vgcreate data /dev/xvdc
lvcreate -n data -l 100%VG data && mkfs.xfs /dev/data/data

mkidr /data
echo "/dev/data/data  /data  xfs  defaults 1 1" >> /etc/fstab
mount -a
```

## 基础包安装

```bash
  curl https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo > docker-ce.repo
  rpm -ivh https://mirrors.aliyun.com/zabbix/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
  yum install docker-ce vmstatus  zabbix-agent  -y
```

## Docker默认参数修改
```bash
vim /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opt": {
    "max-file": "10",
    "max-size": "10M"
  },
  "data-root": "/data/docker"
}
```

## 文件资源限制修改

```bash
vim /etc/security/limits.conf
* soft nofile 65536
* hard nofile 65536
* soft nproc  65536
* soft nproc  65536
```

## 系统日志收集与调整

- 限制默认`journald`产生的日志大小，防止撑爆磁盘
  
```bash
vim /etc/systemd/journald.conf
SystemMaxUse=50M
RuntimeMaxUse=50M
SystemMaxFiles=10
RuntimeMaxFiles=10
```

- 默认`rsyslog`日志发送到统一日志收集器(`graylog2`)

```bash
vim /etc/rsyslog.conf
# graylog.siss.io为GrayLog服务器地址
*.*    @graylog.siss.io:514;RSYSLOG_SyslogProtocol23Format
systemctl restart rsyslog
```

## Ansible公钥预存放

## 脚本下载
[centos7_init.sh](./pkg/centos7_init.sh)