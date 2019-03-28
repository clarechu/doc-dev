# 针对 数据的校验

## Hibernate Validator 简介

* 平时项目中，难免需要对参数 进行一些参数正确性的校验，这些校验出现在业务代码中，让我们的业务代码显得臃肿，而且，频繁的编写这类参数校验代码很无聊。鉴于此，觉得 Hibernate Validator 框架刚好解决了这些问题，可以很优雅的方式实现参数的校验，让业务代码 和 校验逻辑 分开,不再编写重复的校验逻辑。

* Hibernate Validator 是 Bean Validation 的参考实现 . Hibernate Validator 提供了 JSR 303 规范中所有内置 constraint 的实现，除此之外还有一些附加的 constraint。
Bean Validation 为 JavaBean 验证定义了相应的元数据模型和API。缺省的元数据是 Java Annotations，通过使用 XML 可以对原有的元数据信息进行覆盖和扩展。Bean Validation 是一个运行时的数据验证框架，在验证之后验证的错误信息会被马上返回。

## Hibernate Validator 的作用

1. 验证逻辑与业务逻辑之间进行了分离，降低了程序耦合度；
2. 统一且规范的验证方式，无需你再次编写重复的验证代码；
3. 你将更专注于你的业务，将这些繁琐的事情统统丢在一边。

## spring boot 结合hibernate来进行数据校验

项目中，主要用于接口api 的入参校验和 封装工具类 在代码中校验两种使用方式。

引入jar包

```xml
        <dependency>
            <groupId>cn.com.siss</groupId>
            <artifactId>spring-boot-starter-validate</artifactId>
        </dependency>
```

使用 方法 ValidationUtils.validate(itemInfo);

```java

@RestController
public class DemoController {

    @RequestMapping(value = "demo", method = RequestMethod.GET)
    public void demo(@RequestBody ItemInfo itemInfo) throws DataException {
        ValidationUtils.validate(itemInfo);
    }

}

```

常用注解有以下几种形式：

|注解|支持的数据类型|作用|Hibernate元数据影响|
|:---:|:---:|:---:|:---:|:---:|
|@AssertFalse|Boolean, boolean|检查带注释的元素是否为  false|没有|
|@AssertTrue|Boolean, boolean|检查带注释的元素是否为  true|没有|
|@DecimalMax|BigDecimal，  BigInteger，  String，  byte，  short，  int，  long 和原始类型的相应的包装。另外由HV支持：任何子类型  Number。|被标注的值必须不大于约束中指定的最大值. 这个约束的参数是一个通过BigDecimal定义的最大值的字符串表示.|没有|
|@DecimalMin|BigDecimal，  BigInteger，  String，  byte，  short，  int，  long 和原始类型的相应的包装。另外由HV支持：任何子类型  Number。|被标注的值必须不小于约束中指定的最小值. 这个约束的参数是一个通过BigDecimal定义的最小值的字符串表示.|没有|
|@Digits（integer =，fraction =）|BigDecimal，  BigInteger，  String，  byte，  short，  int，  long 和原始类型的相应的包装。另外由HV支持：任何子类型  Number。|检查带注释的值是否是具有最多  integer 数字和  fraction 小数位的数字。	|对应的数据库表字段会被设置精度(precision)和准度(scale).|
|@Future|java.util.Date，  java.util.Calendar; 另外由HV支持，如果  Joda Time  日期/时间API在类路径上：任何ReadablePartial 和和的  实现  ReadableInstant。|检查给定的日期是否比现在晚.|没有|
|@Max|BigDecimal，  BigInteger，  byte，  short，  int，  long 和原始类型的相应的包装。另外由HV支持:(  String 评估由String表示的数值），任何子类型  Number|检查该值是否小于或等于约束条件中指定的最大值.|会给对应的数据库表字段添加一个check的约束条件.|
|@Min|BigDecimal，  BigInteger，  byte，  short，  int，  long 和原始类型的相应的包装。另外由HV支持:(  String 评估由String表示的数值），任何子类型  Number|检查该值是否大于或等于约束条件中规定的最小值.|会给对应的数据库表字段添加一个check的约束条件.|
|@NotNull|没有限制|检测该值 不能为空|对应的表字段不允许为null.|
|@Null|没有限制|为空||
|@Past|java.util.Date，  java.util.Calendar; 另外由HV支持，如果  Joda Time  日期/时间API在类路径上：任何ReadablePartial 和和的  实现  ReadableInstant。|检查标注对象中的值表示的日期比当前早.|没有|
|@Pattern(regex=, flag=)|String|检查该字符串是否能够在match指定的情况下被regex定义的正则表达式匹配.|没有|
|@Size(min=, max=)|检查该值在min max之间|对应的数据库表字段的长度会被设置成约束中定义的最大值.|没有|
|@Valid|任何非基本类型|递归的对关联对象进行校验, 如果关联对象是个集合或者数组, 那么对其中的元素进行递归校验,如果是一个map,则对其中的值部分进行校验.|没有|