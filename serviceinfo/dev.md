# 本地开发环境基础服务信息

- MongoDB复制集
  
  - 版本: v3.6
  
  - DNS: mongo-dev-1,mongo-dev-2,mongo-dev-3

  - 数据库名称: siss

  - 连接帐号/密码: admin/siss.admin.mongo
  
- MySQL主从集群
  
  - 版本: v5.7
  
  - DNS(主): mysql-dev
  
  - DNS(从): mysql-dev-ro

  - 数据库名称: siss
  
  - 连接帐号/密码: siss/siss.root.mysql

- RabbitMQ集群
  
  - 版本: v3.6
  
  - DNS: rabbit-dev

  - 连接帐号/密码: guest/siss.rabbit.dev
  
- Elastcisearch集群
  
  - 版本: 5.6
  
  - DNS: es-dev

- Kafka集群
  
  - 版本: 2.12

  - DNS: kafka-dev

- Redis哨兵模式集群
  
  - 版本: 4

  - DNS: redis-dev-1/redis-dev-2/redis-dev-3
  - Pass:  redis.123
  
以上信息未提供用户名与密码的,表示可以直连.目前以上环境只允许公司内网环境(128.0.0.0/16)连接.