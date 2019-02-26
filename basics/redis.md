# Redis的使用

## 简介

Redis 是完全开源免费的，遵守BSD协议，是一个高性能的key-value数据库。

Redis 与其他 key - value 缓存产品有以下三个特点：

* Redis支持数据的持久化，可以将内存中的数据保存在磁盘中，重启的时候可以再次加载进行使用。
* Redis不仅仅支持简单的key-value类型的数据，同时还提供list，set，zset，hash等数据结构的存储。
* Redis支持数据的备份，即master-slave模式的数据备份。

## Redis 优势

* 性能极高 – Redis能读的速度是110000次/s,写的速度是81000次/s 。
* 丰富的数据类型 – Redis支持二进制案例的 Strings, Lists, Hashes, Sets 及 Ordered Sets 数据类型操作。
* 原子 – Redis的所有操作都是原子性的，意思就是要么成功执行要么失败完全不执行。单个操作是原子性的。多个操作也支持事务，即原子性，通过MULTI和EXEC指令包起来。
* 丰富的特性 – Redis还支持 publish/subscribe, 通知, key 过期等等特性。

## Redis的使用

本章介绍如何使用`SpringBoot` 对redis的操作。

添加redis的 starter 修改pom.xml

```xml
        <dependency>
            <groupId>cn.com.siss</groupId>
            <artifactId>spring-boot-starter-redis</artifactId>
            <version>${starters.version}</version>
        </dependency>
```

添加`application.yml`的配置文件

```java
app:
  redis:
    host: 172.16.0.2 # redis 服务端ip地址
    password: 123456 # redis 登录密码
```

添加string类型 首先通过注解`@Autowired` 注入redisTemplate.
RedisTemplateUtil.set(redisTemplate, "p", "{\"a\": \"b\"}", 3600L);
第二个参数为`key` 第三个为`value` 最后一位为失效时间`expireTime`

```java
@RestController
public class HelloWorld {

    @Autowired
    private RedisTemplate redisTemplate;

    @RequestMapping(value = "/set/redis", method = RequestMethod.GET)
    public Boolean setRedis(){
        System.out.println("controller set method");
        boolean a = RedisTemplateUtil.set(redisTemplate, "p", "{\"a\": \"b\"}", 3600L);
        return a;
    }
}

```

修改数据库 redis默认有16个数据库 通过jedis来切换数据库，例如：

```java
        JedisConnectionFactory jedisConnectionFactory = (JedisConnectionFactory) redisTemplate.getConnectionFactory();
        jedisConnectionFactory.setDatabase(2);
```

插入hash

```java
    @Test
    public void checkoutSetHmKey() {
        HashOperations<String, Object, Object> hash = redisTemplate.opsForHash();
        Map<String, String> map = new HashMap<>();
        map.put("a", "b");
        hash.putAll("124242114234214123412", map);
        RedisTemplateUtil.hmSet(redisTemplate, "s", "a", "b");
    }
```