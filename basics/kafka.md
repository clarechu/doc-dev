# 使用SpringBoot 整合 消息中间件Kafka

## 简介

Kafka is a distributed,partitioned,replicated commit logservice。它提供了类似于JMS的特性，但是在设计实现上完全不同，此外它并不是JMS规范的实现。kafka对消息保存时根据Topic进行归类，发送消息者成为Producer,消息接受者成为Consumer,此外kafka集群有多个kafka实例组成，每个实例(server)成为broker。无论是kafka集群，还是producer和consumer都依赖于zookeeper来保证系统可用性集群保存一些meta信息。

![kafka-img](http://kafka.apache.org/images/kafka_diagram.png)

## 使用场景

## Kafka主要特点

1. 同时为发布和订阅提供高吞吐量。据了解，Kafka每秒可以生产约25万消息（50 MB），每秒处理55万消息（110 MB）。
2. 可进行持久化操作。将消息持久化到磁盘，因此可用于批量消费，例如ETL，以及实时应用程序。通过将数据持久化到硬盘以及replication防止数据丢失。
3. 分布式系统，易于向外扩展。所有的producer、broker和consumer都会有多个，均为分布式的。无需停机即可扩展机器。
4. 消息被处理的状态是在consumer端维护，而不是由server端维护。当失败时能自动平衡。
5. 支持online和offline的场景。

## SpringBoot 集成Kafka

添加kafka starter依赖

```xml
        <dependency>
            <groupId>cn.com.siss</groupId>
            <artifactId>spring-boot-starter-kafka</artifactId>
            <version>${starters.version}</version>
        </dependency>
```

添加kafka配置文件

```yaml
spring:
  profiles:
    include:
      - kafka
```

发送消息 注册`kafkaTemplate` `kafkaTemplate.send("message", "hello-world")`

```java
    @Autowired
    private KafkaTemplate kafkaTemplate;

    @RequestMapping(value = "/sendKafka", method = RequestMethod.GET)
    public Object sendKafka(){
        System.out.println("sendKafka");
        ListenableFuture result = kafkaTemplate.send("message", "hello-world");
        return result;
    }
```

消息接受者

```java
@Component
@Slf4j
public class Hellokafka {

    @KafkaListener(topics = {"message"})
    public void getMessage(ConsumerRecord<?, ?> record) {
        Optional<?> kafkaMessage = Optional.ofNullable(record.value());
        if (kafkaMessage.isPresent()) {

            Object message = kafkaMessage.get();

            log.info("----------------- record =" + record);
            log.info("------------------ message =" + message);
        }
    }
}
```

效果如下

```
sendKafka
2019-02-28 17:20:07.013  INFO 10477 --- [nio-8081-exec-1] o.a.k.clients.producer.ProducerConfig    : ProducerConfig values:
2019-02-28 17:20:07.020  INFO 10477 --- [nio-8081-exec-1] o.a.k.clients.producer.ProducerConfig    : ProducerConfig values:
2019-02-28 17:20:07.020  INFO 10477 --- [nio-8081-exec-1] o.a.kafka.common.utils.AppInfoParser     : Kafka version : 0.10.0.1
2019-02-28 17:20:07.020  INFO 10477 --- [nio-8081-exec-1] o.a.kafka.common.utils.AppInfoParser     : Kafka commitId : a7a17cdec9eaa6c5
2019-02-28 17:20:07.398  INFO 10477 --- [afka-listener-1] cn.com.siss.web.kafka.Hellokafka         : ----------------- record =ConsumerRecord(topic = message, partition = 0, offset = 85, CreateTime = 1551345607273, checksum = 3403921507, serialized key size = -1, serialized value size = 11, key = null, value = hello-world)
2019-02-28 17:20:07.398  INFO 10477 --- [afka-listener-1] cn.com.siss.web.kafka.Hellokafka         : ------------------ message =hello-world
2019-02-28 17:20:07.434  WARN 10477 --- [nio-8081-exec-2] .w.s.m.s.DefaultHandlerExceptionResolver : Failed to write HTTP message: org.springframework.http.converter.HttpMessageNotWritableException: Could not write JSON: No serializer found for class org.apache.kafka.clients.producer.ProducerRecord and no properties discovered to create BeanSerializer (to avoid exception, disable SerializationFeature.FAIL_ON_EMPTY_BEANS); nested exception is com.fasterxml.jackson.databind.JsonMappingException: No serializer found for class org.apache.kafka.clients.producer.ProducerRecord and no properties discovered to create BeanSerializer (to avoid exception, disable SerializationFeature.FAIL_ON_EMPTY_BEANS) (through reference chain: org.springframework.kafka.support.SendResult["producerRecord"])
```