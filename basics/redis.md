# Redis的使用

## 简介

Redis 是完全开源免费的，遵守BSD协议，是一个高性能的key-value数据库。

Redis 与其他 key - value 缓存产品有以下三个特点：

* Redis支持数据的持久化，可以将内存中的数据保存在磁盘中，重启的时候可以再次加载进行使用。
* Redis不仅仅支持简单的key-value类型的数据，同时还提供list，set，zset，hash等数据结构的存储。
* Redis支持数据的备份，即master-slave模式的数据备份。

![redis](https://upload.wikimedia.org/wikipedia/en/thumb/6/6b/Redis_Logo.svg/1200px-Redis_Logo.svg.png)

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

单节点redis

```yaml
spring:
  profiles:
    include:
      - redis
app:
  redis:
    host: redis-dev-3 # redis 服务端ip地址
    password: redis.123 # redis 登录密码
```


哨兵模式

```yaml
app:
  redis:
    password: redis.123
    nodes: redis-dev-1:26379,redis-dev-2:26379,redis-dev-3:26379
spring:
  profiles:
    include:
      - redis-sentry

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

### 使用Redis注解方式插入缓存

开启注释方式的redis

```java
@SpringBootApplication
@EnableCaching
public class SpringBootStarterRedisApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringBootStarterRedisApplication.class, args);
    }

}
```

```
cacheNames = "product"   //缓存名

key = "固定值" 或  key = "#sellerid"(可变化的值)  //redis缓存中的key

condition = "#sellerid.length > 10"   //里面填写表达式，true表示进行缓存，false表示不进行缓存

unless = "#result.getCode() != 0"   //和以上相反，当为false时进行缓存，否则不进行缓存
```


使用注解的方式更新缓存

```java
@Cacheable(value="user", key="'users_'+#id")
public User redis(Long id){
    User user = new User();
    user.setUsername("hlhdidi");
    user.setPassword("123");
    user.setUid(1);
    user.setId(1L);
    System.out.println("log4j2坏啦?");
    return user;
}
```

@CacheEvict 删除缓存  

allEntries = false  清空product里面的所有制

allEntries = true  默认值，删除key对应的值

```java
@CacheEvict(value="thisredis", key="'users_'+#id",condition="#id!=1")
public void delUser(Integer id) {
    // 删除user
    System.out.println("user删除");
}
```

@CachePut

每次执行都会执行方法，无论缓存里是否有值，同时使用新的返回值的替换缓存中的值。这里不同于@Cacheable：@Cacheable如果缓存没有值，从则执行方法并缓存数据，如果缓存有值，则从缓存中获取值

@CacheConfig

@CacheConfig: 类级别的注解：如果我们在此注解中定义cacheNames，则此类中的所有方法上 @Cacheable的cacheNames默认都是此值。当然@Cacheable也可以重定义cacheNames的值
