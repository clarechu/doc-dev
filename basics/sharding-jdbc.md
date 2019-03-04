# Sharding-JDBC 的使用

## 简介

![](https://avatars2.githubusercontent.com/u/38046546?s=200&v=4)

Sharding-JDBC是当当应用框架ddframe中，从关系型数据库模块dd-rdb中分离出来的数据库水平分片框架，实现透明化数据库分库分表访问。Sharding-JDBC是继dubbox和elastic-job之后，ddframe系列开源的第3个项目。
Sharding-JDBC直接封装JDBC协议，可以理解为增强版的JDBC驱动，旧代码迁移成本几乎为零。
Sharding-JDBC定位为轻量级java框架，使用客户端直连数据库，以jar包形式提供服务，无proxy代理层，无需额外部署，无其他依赖，DBA也无需改变原有的运维方式。

主要包括以下特点：

可适用于任何基于java的ORM框架，如：JPA, Hibernate, Mybatis, Spring JDBC Template或直接使用JDBC。
可基于任何第三方的数据库连接池，如：DBCP, C3P0, BoneCP, Druid等。

理论上可支持任意实现JDBC规范的数据库。虽然目前仅支持MySQL，但已有支持Oracle，SQLServer等数据库的计划。
分片策略灵活，可支持等号，between，in等多维度分片，也可支持多分片键。

SQL解析功能完善，支持聚合，分组，排序，limit，or等查询，并支持Binding Table以及笛卡尔积表查询。
性能高。单库查询QPS为原生JDBC的99.8%；双库查询QPS比单库增加94%。

## Sharding-JDBC结合SpringBoot

注意

1、代码中类似"ds0..1.torder0..1.torder{0..1}"成为行表达式，形如"expression或expression或->{ expression }"。该表达式可用于配置数据节点和配置分片算法。

${begin..end}表示范围区间，即表示从begin到end个

${[unit1, unit2, unit_x]}表示枚举值

2、orderTableRuleConfig.setActualDataNodes("ds0..1.torder0..1.torder{0..1}");

这里表示的是使用行表达式配置数据节点即数据库分别是ds0、ds1,表分别是t_order0、t_order1。

该表达的等价组合是：ds0.t_order0, ds0.t_order1, ds1.t_order0, ds1.t_order1。

3、orderTableRuleConfig.setTableShardingStrategyConfig(new InlineShardingStrategyConfiguration("order_id", "t_order${order_id % 2}"));

这里表示的是使用行表达式配置分片算法。该行表示针对t_order表中的元素按照order_id模2将不同的元素放进不同的表中。

比如order_id=5，5%2=1，则放入t_order1中

order_id=6, 6%2=0, 则放入t_order0中

4、除此以外还要一些类似"逻辑表"这样的概念，可以到官方文档自行查询。

工具类DataRespository(该类来源sharding-sphere-example项目)