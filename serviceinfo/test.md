# 阿里测试环境基础服务信息

- MongoDB复制集
  
  - 版本: v3.6
  
  - DNS: mongo-test-1,mongo-test-2,mongo-test-3

  - 数据库名称: siss

  - 连接帐号/密码: admin/siss.admin.mongo
  
- MySQL主从集群
  
  - 版本: v5.7
  
  - DNS(主): mysql-test
  
  - DNS(从): mysql-test-ro

  - 数据库名称: siss
  
  - 连接帐号/密码: siss/siss.root.mysql

- RabbitMQ集群
  
  - 版本: v3.6
  
  - DNS: rabbit-test

  - 连接帐号/密码: guest/guest
  
- Elastcisearch集群
  
  - 版本: 5.6
  
  - DNS: es-test

- Kafka集群
  
  - 版本: 2.12

  - DNS: kafka-test

未提供帐号信息的,表示可以直连,通过防火墙进行安全管控