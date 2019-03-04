# MongoDB的使用

![mongo](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQa7f6h94s8xpLwtgV4EoP0CPF2bYz1SW2M5ABcrArTZl1pEbpQMw)

## 简介

MongoDB（来自于英文单词“Humongous”，中文含义为“庞大”）是可以应用于各种规模的企业、各个行业以及各类应用程序的开源数据库。作为一个适用于敏捷开发的数据库，MongoDB的数据模式可以随着应用程序的发展而灵活地更新。与此同时，它也为开发人员 提供了传统数据库的功能：二级索引，完整的查询系统以及严格一致性等等。 MongoDB能够使企业更加具有敏捷性和可扩展性，各种规模的企业都可以通过使用MongoDB来创建新的应用，提高与客户之间的工作效率，加快产品上市时间，以及降低企业成本。

MongoDB是专为可扩展性，高性能和高可用性而设计的数据库。它可以从单服务器部署扩展到大型、复杂的多数据中心架构。利用内存计算的优势，MongoDB能够提供高性能的数据读写操作。 MongoDB的本地复制和自动故障转移功能使您的应用程序具有企业级的可靠性和操作灵活性。

1、High performance - 对数据库高并发读写的需求web2.0 网站要根据用户个性化信息来实时生成动态页面和提供动态信息，所以基本上无法使用动态页面静态化技术，因此数据库并发负载非常高，往往要达到每秒上万次读写请求。

　　关系型数据库应付上万次 SQL 查询还勉强顶得住，但是应付上万次 SQL 写数据请求，硬盘IO 就已经无法承受了，其实对于普通的 BBS 网站，往往也存在对高并发写请求的需求。

2、Huge Storage - 对海量数据的高效率存储和访问的需求

对于大型的 SNS 网站，每天用户产生海量的用户动态信息，以国外的 Friend feed 为例，一个月就达到了 2.5 亿条用户动态，对于关系数据库来说，在一张 2.5 亿条记录的表里面进行
SQL 查询，效率是极其低下乃至不可忍受的。再例如大型 web 网站的用户登录系统，例如腾讯，盛大，动辄数以亿计的帐号，关系数据库也很难应付。

3、High Scalability && High Availability - 对数据库的高可扩展性和高可用性的需求

　　在基于 web 的架构当中，数据库是最难进行横向扩展的，当一个应用系统的用户量和访问量与日俱增的时候，你的数据库却没有办法像 web server 和 app server 那样简单的通过添加更多的硬件和服务节点来扩展性能和负载能力。对于很多需要提供 24 小时不间断服务的网站来说，对数据库系统进行升级和扩展是非常痛苦的事情，往往需要停机维护和数据迁移，可是停机维护随之带来的就是公司收入的减少。在上面提到的“三高”需求面前，关系数据库遇到了难以克服的障碍，而对于 web2.0 网站来说，关系数据库的很多主要特性却往往无用武之地，例如：

1、数据库事务一致性需求 、数据库事务一致性需求

很多 web 实时系统并不要求严格的数据库事务，对读一致性的要求很低，有些场合对写一致性要求也不高。因此数据库事务管理成了数据库高负载下一个沉重的负担。

2、数据库的写实时性和读实时性需求 、数据库的写实时性和读实时性需求

对关系数据库来说，插入一条数据之后立刻查询，是肯定可以读出来这条数据的，但是对于很多 web 应用来说，并不要求这么高的实时性。

3、对复杂的SQL查询，特别是多表关联查询的需求 特别是多表关联查询的需求

任何大数据量的 web 系统，都非常忌讳多个大表的关联查询，以及复杂的数据分析类型的复杂 SQL 报表查询，特别是 SNS 类型的网站，从需求以及产品设计角度，就避免了这种情
况的产生。往往更多的只是单表的主键查询，以及单表的简单条件分页查询，SQL 的功能被极大的弱化了。

## MongoDB的使用

添加依赖

```xml
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-mongodb</artifactId>
		</dependency>
```

注入添加依赖

```yaml
spring:
  data:
    mongodb:
      uri: mongodb://siss:dev.5566@39.108.210.229:27017/demo

      #mongodb://username:password@host:port/dbName
```

```java
@Data
public class User {
    private String id;
    private String username;
    private String password;
    private String registerTime;
    private String phone;
    private String name;
    private String sex;
    private String age;
}
```

dao层依赖

```java
@Component
public class UserDaoImpl {

    @Autowired
    private MongoTemplate mongoTemplate;

    /**
     * 创建对象
     * @param user
     */
    public void saveUser(User user) {
        mongoTemplate.save(user);
    }

    /**
     * 根据用户名查询对象
     * @param userName
     * @return
     */
    public User findUserByUserName(String userName) {
        Query query=new Query(Criteria.where("id").is(userName));
        User user =  mongoTemplate.findOne(query , User.class);
        return user;
    }

    /**
     * 更新对象
     * @param user
     */
    public void updateUser(User user) {
        Query query=new Query(Criteria.where("id").is(user.getId()));
        Update update= new Update().set("userName", user.getName()).set("passWord", user.getPassword());
        //更新查询返回结果集的第一条
        mongoTemplate.updateFirst(query,update,User.class);
        //更新查询返回结果集的所有
        // mongoTemplate.updateMulti(query,update,User.class);
    }

    /**
     * 删除对象
     * @param id
     */
    public void deleteUserById(Long id) {
        Query query=new Query(Criteria.where("id").is(id));
        mongoTemplate.remove(query,User.class);
    }
}
```

controller调用

```java
@RestController
public class UserMongo {

    @Autowired
    private UserDaoImpl userDao;

    @RequestMapping(value = "mongo", method = RequestMethod.GET)
    public Object mongo() {

        User user = new User();
        user.setId("9");
        user.setAge("3");
        user.setName("demo");
        userDao.saveUser(user);
        return null;
    }

    @RequestMapping(value = "", method = RequestMethod.GET)
    public Object get() {
        User user = userDao.findUserByUserName("1");
        return user;
    }
}

```

## 实现效果

插入效果：

![mongo-insert](img/mongo-insert.png)

查询的结果

![mongo-select](img/mongo-select.png)