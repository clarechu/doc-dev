# 日志记录及GELF的集成

## 前言

`Spring Boot`默认日志 Logback：
默认情况下，Spring Boot会用Logback来记录日志，并用INFO级别输出到控制台。在运行应用程序和其他例子时，你应该已经看到很多INFO级别的日志了， 但是我们的服务是部署在容器中的如果只是单纯的写文件是满足不了需求的，现在我们需要借助gelf来持久化日志。

## 使用

添加依赖

```xml
            <dependency>
                <groupId>cn.com.siss</groupId>
                <artifactId>spring-boot-starter-logging</artifactId>
                <version>${starters.version}</version>
            </dependency>
```

添加日志的名称

```yaml
引入配置文件
spring:
  profiles:
    include:
      - logging

# logging name 指的是项目名称 application

logging:
  name: application
```

日志输出地址：

[GELF地址](http://128.0.255.104:9000/search)

```yaml
username: admin
password: admin
```