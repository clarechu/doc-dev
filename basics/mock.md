# 面向测试驱动开发（TDD）

## 简介

首先讲讲三个开发模式分别代表什么意思？

* TDD：测试驱动开发（Test-Driven Development）
测试驱动开发是敏捷开发中的一项核心实践和技术，也是一种设计方法论。TDD的原理是在开发功能代码之前，先编写单元测试用例代码，测试代码确定需要编写什么产品代码。TDD的基本思路就是通过测试来推动整个开发的进行，但测试驱动开发并不只是单纯的测试工作，而是把需求分析，设计，质量控制量化的过程。TDD首先考虑使用需求（对象、功能、过程、接口等），主要是编写测试用例框架对功能的过程和接口进行设计，而测试框架可以持续进行验证。

* BDD：行为驱动开发（Behavior Driven Development）
行为驱动开发是一种敏捷软件开发的技术，它鼓励软件项目中的开发者、QA和非技术人员或商业参与者之间的协作。主要是从用户的需求出发，强调系统行为。BDD最初是由Dan North在2003年命名，它包括验收测试和客户测试驱动等的极限编程的实践，作为对测试驱动开发的回应。

* ATDD：验收测试驱动开发（Acceptance Test Driven Development）
 ATDD 只是开发人员的职责，通过单元测试用例来驱动功能代码的实现。在准备实施一个功能或特性之前，首先团队需要定义出期望的质量标准和验收细则，以明确而且达成共识的验收测试计划（包含一系列测试场景）来驱动开发人员的TDD实践和测试人员的测试脚本开发。面向开发人员，强调如何实现系统以及如何检验。

使用BDD和ATDD可以解决需求和开发脱节的问题，首先他们都是从用户的需求出发，保证程序实现效果与用户需求一致。
这个过程可以使用基于BDD的自动化测试工具Cucumber。

## 如何集成Spring Boot使用 Mokito 来完成敏捷开发

现在我使用一个我们常用的`mvc`框架，当我们操作调用`mapper`层来操作数据库的时候，是不是需要调用数据库，这样不是真正的mock测试 依赖过于复杂, 这个时候我们就要考虑使用`Mokito` 来mock一个方法。

service层

```java
@Service
public class PersonService {

    @Autowired
    private PersonDao personDao;

    public boolean update(int id, String name) {
        Person person = personDao.getPerson(id);
        if (person == null) {
            return false;
        }
        Person personUpdate = new Person();
        personUpdate.setId(person.getId());
        personUpdate.setName(name);
        return personDao.update(personUpdate);
    }

    public boolean getData(int id) throws Exception {
        Person person = personDao.getPerson(id);
        if (person == null) {
            new Exception("报错了！！！");
        }
        return true;
    }
}

```

dao层

```java
public interface PersonDao {
    Person getPerson(int id);

    boolean update(Person person);

}
```

实体类Person

```java
@Data
public class Person {
    private int id;
    private String name;
}
```

现在就是我们来测试我们的service层

```java
//这句表示该测试类运行的时候会先加载spring框架所需的相关类库并将所有有注解的类进行自动依赖注入。
@RunWith(SpringRunner.class) 
public class DemoTestApplicationTests {

    /*在测试类中，我们需要在被测类对象声明的时候加上@InjectMocks，这个注解从名字
    也很好理解，就是将所有的mock类注入到这个对象实例中，注意这里对APMInfoService的创建必须要通过new来初始
    化，不能像@Autowired那样靠spring自动注入依赖类，因为这里APMInfoService内部依赖的类都是Mock的对象，必
    须要显式创建类实例Mockito才能注入成功。这样你就会发现在下面测试方法调用的时候被测类就不会再是null了。
    */

  @InjectMocks
  private PersonService personService = new PersonService();


  @Mock
  private PersonDao personDao;

  @Before
  public void beforeUpdate(){
      Person person = new Person();
      person.setId(1);
      person.setName("chulei");
      when(personDao.getPerson(1)).thenReturn(person);
      //when().thenThrow(Exception.class);
      when(personDao.update(person)).thenReturn(true);
  }

  @Test
  public void update() {
     Boolean flag = personService.update(1, "chulei");
      Assert.assertEquals(flag, true);
      verify(personDao).getPerson(1);
  }

}
```

测试controller类

```java

@WebAppConfiguration
@Transactional //支持数据回滚，避免测试数据污染环境
@RunWith(SpringRunner.class)
@SpringBootTest
public class DemoTestApplicationTests {
  @Autowired
  private WebApplicationContext wac;

  private MockMvc mockMvc;

    @Before
    public void setup() {
        mockMvc = MockMvcBuilders.webAppContextSetup(wac).build();
    }

  @Test
    public void sub() throws Exception {

          String result = mockMvc.perform(
                  get("/api/order")
                          .param("pageNum", "1")
                          .param("pageSize", "10")
                          .param("status", "1")
                          .contentType(MediaType.APPLICATION_JSON_UTF8))
                  .andExpect(status().isOk())
                  .andExpect(jsonPath("$.code").value(10000))
                  .andReturn().getResponse().getContentAsString();
  }


}  
```