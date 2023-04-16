**大家好，我是不才陈某~**

XSS 漏洞到底是什么？在前端Form表单的输入框中，用户没有正常输入，而是输入了一段代码：`</input><img src=1 onerror=alert1>` 这个正常保存没有问题。问题出在了列表查询的时候，上面的代码就生效了，由于图片的地址乱写的，所以这个alert就起作用了来看图。

![](https://www.java-family.cn/BlogImage/20221027211329.png)

那根据这个原理，实际上如果没有做任何的限制，有心人就可以为所欲为了。可以在里面嵌入一些关键代码，把你的信息拿走。确实是个很严重的问题。

## 解决思路

既然是因为输入框中输入了不该输入的东西，那自然就萌生一些想法：

- **校验输入内容**，不允许用户输入特殊字符，特殊标签
- **允许用户输入**，但是保存的时候将特殊的字符直接替换为空串
- **允许用户输入**，将特殊字符转译保存。

第一种方法，特殊字符过滤。既然要过滤特殊字符，那就得自己把所有的特殊字符列出来进行匹配，比较麻烦，而且要定义好什么才是特殊字符？况且用户本身不知道什么是特殊字符。突如其来的报错，会让用户有点摸不着头脑，不是很友好。

第二种方法，特殊字符替换为空串。未免有点太暴力。万一真的需要输入一点特殊的字符，保存完查出来发现少了好多东西，人家以为我们的BUG呢。也不是很好的办法。

第三种办法，特殊字符转译。这个办法不但用户数据不丢失，而且浏览器也不会执行代码。比较符合预期。

那办法确定了，怎么做呢？前端来做还是后端来做？想了想还是要后端来做。毕竟使用切面或者Filter可以一劳永逸。

## 心路历程

经过抄袭，我发现了一些问题，也渐渐的有了一些理解。下面再说几句废话：

查到的预防XSS攻击的，大多数的流程是：

- 拦截请求
- 重新包装请求
- 重写`HttpServletRequest`中的获取参数的方法
- 将获得的参数进行XSS处理
- 拦截器放行

于是我就逮住一个抄了一下。抄袭完毕例行测试，发现我用`@RequestBody`接受的参数，并不能过滤掉特殊字符。怎么肥四？大家明明都这么写。为什么我的不好使？

这个时候突然一个想法萌生。SpringMVC在处理`@RequestBody`类型的参数的时候，是不是使用的我重写的这些方法呢？（`getQueryString()`、`getParameter(String name)`、`getParameterValues(String name)`、`getParameterMap()`）。打了个日志，发现还真不是这些方法。

于是搜索了一下Springboot拦截器获取`@RequestBody`参数，碰到了这篇文章。首先的新发现是Spring MVC 在获取`@RequestBody`参数的时候使用的是`getInputStream()`方法。嗯？（斜眼笑）那我是不是可以重写这个方法获取到输入流的字符串，然后直接处理一下？

说干就干，一顿操作。进行测试。发现直接JSON 转换的报错了。脑裂。估计是获得的字符串在转换的时候把不该转的东西转译了，导致不能序列化了。眼看就要成功了，一测回到解放前。

该怎么办呢？其实思路是没错的，就是在获取到流之后进行处理。但是错就错在处理的位置。果然处理的时间点很重要。（就像伴侣一样，某人出现的时间点很重要）。那既然不能在现在处理，那就等他序列化完毕之后再处理就好了。那怎么办呢？难道要写一个AOP 拦截到所有的请求？用JAVA反射处理？

> > 正在迷茫的时候，看到了一篇文章，知识增加了。原来可以在序列化和反序列化的时候进行处理。

## 最终实现

看一下最终的代码实现（有些导入的包被我删了）

### 重新包装Request的代码

```java
/**
 * 重新包装一下Request。重写一些获取参数的方法，将每个参数都进行过滤
 */
public class XSSHttpServletRequestWrapper extends HttpServletRequestWrapper {
    private static final Logger logger = LoggerFactory.getLogger(XSSHttpServletRequestWrapper.class);

    private HttpServletRequest request;
    /**
     * 请求体 RequestBody
     */
    private String reqBody;

    /**
     * Constructs a request object wrapping the given request.
     *
     * @param request The request to wrap
     * @throws IllegalArgumentException if the request is null
     */
    public XSSHttpServletRequestWrapper(HttpServletRequest request) {
        super(request);
        logger.info("---xss XSSHttpServletRequestWrapper created-----");
        this.request = request;
        reqBody = getBodyString();
    }


    @Override
    public String getQueryString() {
        return StringEscapeUtils.escapeHtml4(super.getQueryString());
    }

    /**
     * The default behavior of this method is to return getParameter(String
     * name) on the wrapped request object.
     *
     * @param name
     */
    @Override
    public String getParameter(String name) {
        logger.info("---xss XSSHttpServletRequestWrapper work  getParameter-----");
        String parameter = request.getParameter(name);
        if (StringUtil.isNotBlank(parameter)) {
            logger.info("----filter before--name:{}--value:{}----", name, parameter);
            parameter = StringEscapeUtils.escapeHtml4(parameter);
            logger.info("----filter after--name:{}--value:{}----", name, parameter);
        }
        return parameter;
    }

    /**
     * The default behavior of this method is to return
     * getParameterValues(String name) on the wrapped request object.
     *
     * @param name
     */
    @Override
    public String[] getParameterValues(String name) {
        logger.info("---xss XSSHttpServletRequestWrapper work  getParameterValues-----");
        String[] parameterValues = request.getParameterValues(name);
        if (!CollectionUtil.isEmpty(parameterValues)) {
         // 经 “@Belief_7” 指正 这种方式不能更改parameterValues里面的值，要换成下面👇的写法
            //for (String value : parameterValues) {
            //    logger.info("----filter before--name:{}--value:{}----", name, value);
            //    value = StringEscapeUtils.escapeHtml4(value);
            //    logger.info("----filter after--name:{}--value:{}----", name, value);
            // }
            for (int i = 0; i < parameterValues.length; i++) 
         { 
             parameterValues[i] = StringEscapeUtils.escapeHtml4(parameterValues[i]); 
         } 
        }
        return parameterValues;
    }

    /**
     * The default behavior of this method is to return getParameterMap() on the
     * wrapped request object.
     */
    @Override
    public Map<String, String[]> getParameterMap() {
        logger.info("---xss XSSHttpServletRequestWrapper work  getParameterMap-----");
        Map<String, String[]> map = request.getParameterMap();
        if (map != null && !map.isEmpty()) {
            for (String[] value : map.values()) {
                /*循环所有的value*/
                for (String str : value) {
                    logger.info("----filter before--value:{}----", str, str);
                    str = StringEscapeUtils.escapeHtml4(str);
                    logger.info("----filter after--value:{}----", str, str);
                }
            }
        }
        return map;
    }

    /*重写输入流的方法，因为使用RequestBody的情况下是不会走上面的方法的*/
    /**
     * The default behavior of this method is to return getReader() on the
     * wrapped request object.
     */
    @Override
    public BufferedReader getReader() throws IOException {
        logger.info("---xss XSSHttpServletRequestWrapper work  getReader-----");
        return new BufferedReader(new InputStreamReader(getInputStream()));
    }

    /**
     * The default behavior of this method is to return getInputStream() on the
     * wrapped request object.
     */
    @Override
    public ServletInputStream getInputStream() throws IOException {
        logger.info("---xss XSSHttpServletRequestWrapper work  getInputStream-----");
        /*创建字节数组输入流*/
        final ByteArrayInputStream bais = new ByteArrayInputStream(reqBody.getBytes(StandardCharsets.UTF_8));
        return new ServletInputStream() {
            @Override
            public boolean isFinished() {
                return false;
            }

            @Override
            public boolean isReady() {
                return false;
            }

            @Override
            public void setReadListener(ReadListener listener) {
            }

            @Override
            public int read() throws IOException {
                return bais.read();
            }
        };
    }


    /**
     * 获取请求体
     *
     * @return 请求体
     */
    private String getBodyString() {
        StringBuilder builder = new StringBuilder();
        InputStream inputStream = null;
        BufferedReader reader = null;

        try {
            inputStream = request.getInputStream();

            reader = new BufferedReader(new InputStreamReader(inputStream));

            String line;

            while ((line = reader.readLine()) != null) {
                builder.append(line);
            }
        } catch (IOException e) {
            logger.error("-----get Body String Error:{}----", e.getMessage(), e);
        } finally {
            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (IOException e) {
                    logger.error("-----get Body String Error:{}----", e.getMessage(), e);
                }
            }
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    logger.error("-----get Body String Error:{}----", e.getMessage(), e);
                }
            }
        }
        return builder.toString();
    }
}
```

### 定义过滤器

```java
/**
 * Filter 过滤器，拦截请求转换为新的请求
 */
public class XssFilter implements Filter {
    private static final Logger logger = LoggerFactory.getLogger(XssFilter.class);

    /**
     * 初始化方法
     */
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        logger.info("----xss filter start-----");
    }
    /**
     * 过滤方法
     */
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        ServletRequest wrapper = null;
        if (request instanceof HttpServletRequest) {
            HttpServletRequest servletRequest = (HttpServletRequest) request;
            wrapper = new XSSHttpServletRequestWrapper(servletRequest);
        }

        if (null == wrapper) {
            chain.doFilter(request, response);
        } else {
            chain.doFilter(wrapper, response);
        }
    }
}
```

### 注册过滤器

注册过滤器我了解到的有两种方式。 我用的下面的这种

一种通过`@WebFilter`注解的方式来配置，但这种启动类上要加`@ServletComponentScan` 注解来指定扫描路径

另外一种就是以Bean 的方式来注入（不知道放哪里，就把Bean放到启动类里面）

```java
/**
 * XSS 的Filter注入
 * 用来处理getParameter的参数
 * @return
 */
@Bean
public FilterRegistrationBean xssFilterRegistrationBean(){
    FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean();
    filterRegistrationBean.setFilter(new XssFilter());
    filterRegistrationBean.setOrder(1);
    filterRegistrationBean.setDispatcherTypes(DispatcherType.REQUEST);
    filterRegistrationBean.setEnabled(true);
    filterRegistrationBean.addUrlPatterns("/*");
    return filterRegistrationBean;
}
```

上面配的是使用`request.getParameter()`的时候生效的,但是当我使用`@RequestBody`来接收参数的时候是不行的，所以还得有下面的代码：

### 处理请求中的JSON数据

```java
/**
 * 反序列化，用来处理请求中的JSON数据
 * 处理RequestBody方式接收的参数
 */
public class XssJacksonDeserializer extends JsonDeserializer<String> {

    @Override
    public String deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
        return StringEscapeUtils.escapeHtml4(jp.getText());
    }
}
```

### 处理返回值的JSON数据

```java
/**
 * 处理向前端发送的JSON数据，将数据进行转译后发送
 */
public class XssJacksonSerializer extends JsonSerializer<String> {
    @Override
    public void serialize(String value, JsonGenerator jgen, SerializerProvider provider) throws IOException {
        jgen.writeString(StringEscapeUtils.escapeHtml4(value));
    }
}
```

### 注册、配置自定义的序列化方法

```java
@Override
public void extendMessageConverters(List<HttpMessageConverter<?>> converters) {
 Jackson2ObjectMapperBuilder builder = new Jackson2ObjectMapperBuilder();
 ObjectMapper mapper = builder.build();
 /*注入自定义的序列化工具，将RequestBody的参数进行转译后传输*/
    SimpleModule simpleModule = new SimpleModule();
    // XSS序列化
    simpleModule.addSerializer(String.class, new XssJacksonSerializer());
    simpleModule.addDeserializer(String.class, new XssJacksonDeserializer());
    mapper.registerModule(simpleModule);
    converters.add(new MappingJackson2HttpMessageConverter(mapper));
}
```

### 测试

所有东西都配置完了，接下来进行愉快的测试阶段了。

我依然在输入框中输入这段代码`</input><img src=1 onerror=alert1>`并进行保存。来看一下数据库中的保存结果：

![](https://www.java-family.cn/BlogImage/20221027211353.png)

可以看到数据库中保存的数据，已经经过转译了。那查询一下列表是什么样的呢？

![](https://www.java-family.cn/BlogImage/20221027211403.png)

可以看到两条数据，上面的是我们经过转译的，正常的展示出来了。而下面的是没经过转译的，直接空白，并且给我弹了个窗。

## 总结

- 就是注意要分情况处理。
- 拦截器处理一部分，并注意拦截器的注册方式
- Jackson的方式处理另一部分，也是注意配置方式

## 补充

代码经过验证后，发现了一个问题。今天来补充一下。问题是这样的：

如果使用`@RequestBody`的形式接受参数，也就是需要使用自定义的序列化方式。然而有时候，我们的业务需要传递一些JSON串到后端，如`{\"username\":\"zx\",\"pwd\":\"123\"}`（注意这是个字符串）。但是因为我不管三七二十一直接暴力转译，导致里面的双引号以及其他符号都被转译了。那么当我们拿到这个字符串之后，再自己反序列化的时候就会出错了。

为了解决这个问题，我在自定义的序列化方法中判断了一下这个字段的值是否是JSON形式，如果是JSON形式，那就不做处理，直接返回，以保证能够顺利反序列化。判断是否是JSON的方式，我选择最简单的，判断首尾是否是`{ } [ ]`的组合。代码如下：

```java
public class XssJacksonDeserializer extends JsonDeserializer<String> {

    @Override
    public String deserialize(JsonParser jp, DeserializationContext ctxt) throws IOException, JsonProcessingException {
        // 判断一下 值是不是JSON的格式，如果是JSON的话，那就不处理了。
        /*判断JSON，可以用JSON.parse但是所有字段都Parse一下，未免有点太费性能，所以粗浅的认为，不是以{ 或者[ 开头的文本都不是JSON*/
        if (isJson(jp.getText())) {
            return jp.getText();
        }
        return StringEscapeUtils.escapeHtml4(jp.getText());
    }


    /**
     * 判断字符串是不是JSON
     *
     * @param str
     * @return
     */
    private boolean isJson(String str) {
        boolean result = false;
        if (StringUtil.isNotBlank(str)) {
            str = str.trim();
            if (str.startsWith("{") && str.endsWith("}")) {
                result = true;
            } else if (str.startsWith("[") && str.endsWith("]")) {
                result = true;
            }
        }
        return result;
    }
}
```

但是经过这样的改动之后，可能又没那么安全了。所以还是要看自己的取舍了。

---
欢迎加入陈某的知识星球，一起学习打卡，交流技术。加入方式，扫描下方二维码：

![](https://www.java-family.cn/BlogImage/20221013191230.png)

已在知识星球中更新如下几个专栏，详情[戳链接了解](](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&chksm=fcf7550fcb80dc1945cfd871ad5c939dcd3e66b3013b91590edbf523fbf016b61f2a93fe20a0&token=1892293211&lang=zh_CN#rd))：

1. **《我要进大厂》**：汇总了大厂面试考点系列、系统架构设计、实战总结调优....
2. **《亿级数据分库分表实战》**：**文章+视频**的形式分享亿级数据的分库分表实战
3. **《DDD微服务落地实战》**：从DDD入门到实战进阶
4. **《Java全栈源码系列》**：Java全栈体系的源码解析，包括Spring、SpringMVC、Spring Boot、Spring Cloud 各种中间件、Sharding-JDBC、Mycat、Tomcat....
5. **《精尽Spring Cloud Alibaba系列》**：Spring Cloud Alibaba各个中间件的使用以及源码深究，完整的案例源码分享，涉及Spring Cloud 的各个组件源码介绍
6. **《精尽Spring Boot 系列》**：整理了Spring Boot 入门到源码级别的文章
7. **《精尽Spring系列》**：迭代了47+篇文章，入门到源码级别的介绍，完整的案例源码
8. **《精尽Spring Security 系列》**：Spring Security从入门到实战，包括JWT、单点登录....
6. Java后端相关技术的源码讲解、全栈学习路线图

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，已经写了**3个专栏**，整理成**PDF**，获取方式如下：

1. [《Spring Cloud 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=2042874937312346114#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Cloud 进阶** 获取！
2. [《Spring Boot 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1532834475389288449#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Spring Boot进阶** 获取！
3. [《Mybatis 进阶》](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU3MDAzNDg1MA==&action=getalbum&album_id=1500819225232343046#wechat_redirect)PDF：关注公众号：【**码猿技术专栏**】回复关键词 **Mybatis 进阶** 获取！

如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！