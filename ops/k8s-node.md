# 阿里K8S节点初始化

## 修改默认DNS

```bash
cd /etc/sysconfig/network-scripts
# 增加默认搜索域为siss.aliyun,并配置DNS为内部的DNS
echo -e  "DOMAIN=siss.aliyun\nDNS1=172.18.171.109\nDNS2=172.18.171.113" >> ifcfg-eth0
# 重启网络
systemctl restart network
```

## 安装监控组件Zabbix Agent

```bash
rpm -ivh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
yum install zabbix-agent -y
```

### 替换默认配置

```bash
# 替换默认的日志文件轮替
sed -i 's/LogFileSize=0/LogFileSize=1/g' /etc/zabbix/zabbix_agentd.conf
# 替换默认的127.0.0.1
sed -i 's/127.0.0.1/zabbix.siss.aliyun/g' /etc/zabbix/zabbix_agentd.conf
# 替换Hostname
sed -i "s/Hostname=Zabbix server/Hostname=$(hostname)/g" /etc/zabbix/zabbix_agentd.conf
# 替换HostMeta
sed -i 's/# HostMetadata=/HostMetadata=linux/g' /etc/zabbix/zabbix_agentd.conf
# 启动服务
systemctl restart zabbix-agent&&systemctl enable zabbix-agent
```

## 系统日志远端收集

修改系统的rsyslog，将本地日志发送至远端

```bash
# vim /etc/rsyslog.conf
...
# 添加至文件最后
*.*    @graylog.siss.aliyun:514;RSYSLOG_SyslogProtocol23Format

# 重启服务
systemctl restart rsyslog
```