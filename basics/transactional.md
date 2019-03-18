# SpringBoot 事务的管理

我们在开发企业应用时，对于业务人员的一个操作实际是对数据读写的多步操作的结合。由于数据操作在顺序执行的过程中，任何一步操作都有可能发生异常，异常会导致后续操作无法完成，此时由于业务逻辑并未正确的完成，之前成功操作数据的并不可靠，需要在这种情况下进行回退。

事务的作用就是为了保证用户的每一个操作都是可靠的，事务中的每一步操作都必须成功执行，只要有发生异常就回退到事务开始未进行操作的状态。

事务管理是Spring框架中最为常用的功能之一，我们在使用Spring Boot开发应用时，大部分情况下也都需要使用事务。

在业务层使用 @Transactional 开启事务，执行数据库操作后抛出异常。具体代码如下：

```java
    @Transactional
    public void addMoney() throws Exception {
        //先增加余额
        accountMapper.addMoney();
        //然后遇到故障
        throw new RuntimeException("发生异常了..");
    }
```

数据库层就很简单了，我们通过注解来实现账户数据的查询，具体如下：

```java
package com.hehe.mapper;

@Mapper
public interface AccountMapper {

    @Select("select * from account where account_id=1")
    Account getAccount();

    @Update("update account set balance = balance+100 where account_id=1")
    void addMoney();
}
```

