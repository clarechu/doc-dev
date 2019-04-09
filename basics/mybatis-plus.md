# 结合Mybatis-Plus 使用读写分离

## 简介

Mybatis-Plus（简称MP）是一个 Mybatis 的增强工具，在 Mybatis 的基础上只做增强不做改变，为简化开发、提高效率而生。这是官方给的定义，关于mybatis-plus的更多介绍及特性，可以参考mybatis-plus官网。那么它是怎么增强的呢？其实就是它已经封装好了一些crud方法，我们不需要再写xml了，直接调用这些方法就行，就类似于JPA。

## Mybatis-Plus的使用

使用SpringBoot 集成Mybatis-Plus。

首先添加Mybatis-Plus依赖

```xml
        <dependency>
            <groupId>cn.com.siss</groupId>
            <artifactId>spring-boot-starter-mybatis-plus</artifactId>
            <version>${starters.version}</version>
        </dependency>

<!-- 有兴趣的也可以使用mybatis的自动生成代码工具 Mybatis Generator -->
            <plugin>
                <groupId>org.mybatis.generator</groupId>
                <artifactId>mybatis-generator-maven-plugin</artifactId>
                <version>1.3.5</version>
                <configuration>
                    <verbose>true</verbose>
                    <overwrite>true</overwrite>
                </configuration>
            </plugin>


        <resources>
            <resource>
                <directory>src/main/java</directory>
                <includes>
                    <include>**/*.xml</include>
                </includes>
            </resource>
            <!--指定资源的位置-->
            <resource>
                <directory>src/main/resources</directory>
            </resource>
        </resources>
```

扫描实体类（entity）和 数据库（mapper）包路径

```yml

spring:
  profiles:
    include:
      - mybatisplus-rws
mybatis:
  typeAliasesPackage: "cn.com.siss.web.entity"
  #checkConfig-location : false
  mapper-locations: "classpath:cn/com/siss/web/mapper/xml/*Mapper.xml"

```

在启动类加注解`@MapperScan("cn.com.siss.web.mapper*")` 扫描数据层。

```java
@SpringBootApplication
@MapperScan("cn.com.siss.web.mapper*")
public class DemoWebApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoWebApplication.class, args);
    }

}
```

添加数据库连接信息（name , username, password），例如：

```yaml
app:
  datasource:
    name: demo #数据库名称
    read:
      host: mysql-ro-local # 读 数据库的 host 默认为： mysql-ro-${spring.active.profile}
      port: 3306 # 读 数据库的 port 默认为： 3306
    write:
      host: mysql-local # 写 数据库的 host 默认为： mysql-${spring.active.profile}
      port: 3307 # 写 数据库的 port 默认为： 3306
    username: root
    password: gUa7c4GulFZluORvMIEdC5Jm6P7UMs0VfCHErThG2AUz/DOvb/e0dHkcBGmtmzyURYQXTxxQngjR4+ccYc/J1Q==
    druid:
      public-key: MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAJc1VMKK8to2/8IjwA/7QG8qASZl0PWGnZKgNruPAJxAmQQtEMvsFGu6uD3rTfCbFrD4CtNuNz0B3bX067oQZI0CAwEAAQ==
```

这里数据库密码需要加密，禁止使用明文密码：

下载durid.jar包 [druid.jar](http://central.maven.org/maven2/com/alibaba/druid/1.1.9/druid-1.1.9.jar)
下载成功后在当前目录执行

```bash
java -cp  druid-1.1.9.jar com.alibaba.druid.filter.config.ConfigTools yourpassword

privateKey:MIIBVQIBADANBgkqhkiG9w0BAQEFAASCAT8wggE7AgEAAkEAiVDuSXMyYybL6zxlGvOwAOuxTyWeOKCXWYv5+Kfwz2CE08+UczVi07GmMlUT5Z3RxpEuDKKqVYylAgpC7D8QwQIDAQABAkBRDwxLIYyKCVnxGCra+SVZtchqX1uCNBKEEuRSC9lUoNaAhSzUrS6uX9eqlGYaFB11iRUmO33PFX2tJe4ez3nRAiEA2ittzLPt9kbh8t3ZAysr5KUpG4m7Xclfij+pvMbrJU0CIQChIGg0CD2CUtdSwXMlv34VzVuWdNglNFZdSoWqJSiPRQIgL/hgmiPt7LrFL6uL7eBuNEYEdeOg6QxAD5vT7IgoZ/kCIQCBQ391ptq5z/4A3UOkmADuOsbsaKbzCg7zXxLm0lK8xQIhAL1hb6D4zkzDhMXBuWKXX1sf+yPXr5uqNOk7Qd1DyFzo
publicKey:MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAIlQ7klzMmMmy+s8ZRrzsADrsU8lnjigl1mL+fin8M9ghNPPlHM1YtOxpjJVE+Wd0caRLgyiqlWMpQIKQuw/EMECAwEAAQ==
password:IAsFFJu/MU7b3yXUp+v3AiGzxRxp3C/C6W2CXUPyrfH8V52CloF/JAoV4gNvEWUunQkBFYDX6KwgF+7KYJopjg==
```

把上面的`publicKey`和`password`分别粘贴到application.yml中

mapper.java

```java
import cn.com.siss.web.entity.TbDemo;

public interface TbDemoMapper {
    int insert(TbDemo record);

    int insertSelective(TbDemo record);

    TbDemo get(Integer id);
}
```

mapper.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="cn.com.siss.web.mapper.TbDemoMapper">
  <resultMap id="BaseResultMap" type="cn.com.siss.web.entity.TbDemo">
    <result column="id" jdbcType="INTEGER" property="id" />
    <result column="name" jdbcType="VARCHAR" property="name" />
  </resultMap>
  <insert id="insert" parameterType="cn.com.siss.web.entity.TbDemo">
    insert into tb_demo (id, name)
    values (#{id,jdbcType=INTEGER}, #{name,jdbcType=VARCHAR})
  </insert>
  <insert id="insertSelective" parameterType="cn.com.siss.web.entity.TbDemo">
    insert into tb_demo
    <trim prefix="(" suffix=")" suffixOverrides=",">
      <if test="id != null">
        id,
      </if>
      <if test="name != null">
        name,
      </if>
    </trim>
    <trim prefix="values (" suffix=")" suffixOverrides=",">
      <if test="id != null">
        #{id,jdbcType=INTEGER},
      </if>
      <if test="name != null">
        #{name,jdbcType=VARCHAR},
      </if>
    </trim>
  </insert>

  <select id="get" parameterType="integer" resultType="cn.com.siss.web.entity.TbDemo">
    select * from tb_demo where id = #{id}
  </select>
</mapper>
```

测试用例

```java
    @Autowired
    private TbDemoMapper tbDemoMapper;

    @Test
    public void get() {
        TbDemo tbDemo = tbDemoMapper.get(1);
        System.out.println(tbDemo.getName());
    }

    @Test
    public void insert() {
        TbDemo tbDemo = new TbDemo();
        tbDemo.setId(1);
        tbDemo.setName("aa");
        tbDemoMapper.insert(tbDemo);
    }
```