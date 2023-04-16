**大家好，我是不才陈某~**

## **1. XSS跨站脚本攻击**

### ① XSS漏洞介绍

跨站脚本攻击XSS是指攻击者往Web页面里插入恶意Script代码，当用户浏览该页之时，嵌入其中Web里面的Script代码会被解析执行，从而达到恶意攻击用户的目的。XSS攻击针对的是用户层面的攻击！

### ② XSS漏洞分类

**存储型XSS：** 存储型XSS，持久化，代码是存储在服务器中的，如在个人信息或发表文章等地方，插入代码，如果没有过滤或过滤不严，那么这些代码将储存到服务器中，用户访问该页面的时候触发代码执行。这种XSS比较危险，容易造成蠕虫，盗窃cookie

![](D:\BlogImage\对象池\50.png)

**反射型XSS：** 非持久化，需要欺骗用户自己去点击链接才能触发XSS代码（服务器中没有这样的页面和内容），一般容易出现在搜索页面

![](D:\BlogImage\对象池\51.png)

**DOM型XSS：** 不经过后端，DOM-XSS漏洞是基于文档对象模型(`Document Objeet Model`,DOM)的一种漏洞，DOM-XSS是通过url传入参数去控制触发的，其实也属于反射型XSS。

### ③ 防护建议

- 限制用户输入，表单数据规定值得类型，例如年龄只能是int，name为字母数字组合。
- 对数据进行html encode处理。
- 过滤或移除特殊的html标签。
- 过滤javascript事件的标签。

## 2. SQL注入攻击

### ① SQL注入漏洞介绍

SQL注入（SQLi）是一种注入攻击，可以执行恶意SQL语句。它通过将任意SQL代码插入数据库查询，使攻击者能够完全控制Web应用程序后面的数据库服务器。攻击者可以使用SQL注入漏洞绕过应用程序安全措施；可以绕过网页或Web应用程序的身份验证和授权，并检索整个SQL数据库的内容；还可以使用SQL注入来添加，修改和删除数据库中的记录

SQL注入漏洞可能会影响使用SQL数据库（如MySQL，Oracle，SQL Server或其他）的任何网站或Web应用程序。犯罪分子可能会利用它来未经授权访问用户的敏感数据：客户信息，个人数据，商业机密，知识产权等。SQL注入攻击是最古老，最流行，最危险的Web应用程序漏洞之一。

### ②防护建议

使用mybatis中`#{}`可以有效防止sql注入。

使用`#{}`时：

```xml
<select id="getBlogById" resultType="Blog" parameterType=”int”>
       select id,title,author,content
       from blog where id=#{id}
</select>
```

打印出执行的sql语句，会看到sql是这样的：

```sql
select id,title,author,content from blog where id = ?
```

不管输入什么参数，打印出的sql都是这样的。这是因为mybatis启用了预编译功能，在sql执行前，会先将上面的sql发送给数据库进行编译，执行时，直接使用编译好的sql，替换占位符“？”就可以了。因为sql注入只能对编译过程起作用，所以像#{}这样预编译成？的方式就很好地避免了sql注入的问题。

**mybatis是如何做到sql预编译的呢？**

其实在框架底层，是jdbc中的`PreparedStatement`类在起作用，`PreparedStatement`是我们很熟悉的Statement的子类，它的对象包含了编译好的sql语句。这种“准备好”的方式不仅能提高安全性，而且在多次执行一个sql时，能够提高效率，原因是sql已编译好，再次执行时无需再编译。

使用`${}`时

```xml
<select id="orderBlog" resultType="Blog" parameterType=”map”>
       select id,title,author,content
       from blog order by ${orderParam}
</select>
```

仔细观察，内联参数的格式由“`#{xxx}`”变为了`${xxx}`。如果我们给参数“`orderParam`”赋值为”id”,将sql打印出来，是这样的：

```sql
select id,title,author,contet from blog order by id
```

显然，这样是无法阻止sql注入的，参数会直接参与sql编译，从而不能避免注入攻击。但涉及到动态表名和列名时，只能使用“`${}`”这样的参数格式，所以，这样的参数需要我们在代码中手工进行处理来防止注入。

其实，这些都在Java面试库小程序上都有答案，如果你近期准备面试跳槽，建议在上面刷题，涵盖 2000+ 道 Java 面试题，几乎覆盖了所有主流技术面试题。

## 3. SpringBoot中如何防止XSS攻击和sql注入

对于Xss攻击和Sql注入，我们可以通过过滤器来搞定，可根据业务需要排除部分请求

### ① 创建Xss请求过滤类`XssHttpServletRequestWraper`

![](D:\BlogImage\对象池\52.png)

代码如下：

```java
public class XssHttpServletRequestWraper extends HttpServletRequestWrapper {

    Logger log = LoggerFactory.getLogger(this.getClass());


    public XssHttpServletRequestWraper() {
        super(null);
    }

    public XssHttpServletRequestWraper(HttpServletRequest httpservletrequest) {
        super(httpservletrequest);
    }

 //过滤springmvc中的 @RequestParam 注解中的参数
    public String[] getParameterValues(String s) {

        String str[] = super.getParameterValues(s);
        if (str == null) {
            return null;
        }
        int i = str.length;
        String as1[] = new String[i];
        for (int j = 0; j < i; j++) {
            //System.out.println("getParameterValues:"+str[j]);
            as1[j] = cleanXSS(cleanSQLInject(str[j]));
        }
        log.info("XssHttpServletRequestWraper净化后的请求为：==========" + as1);
        return as1;
    }

 //过滤request.getParameter的参数
    public String getParameter(String s) {
        String s1 = super.getParameter(s);
        if (s1 == null) {
            return null;
        } else {
            String s2 = cleanXSS(cleanSQLInject(s1));
            log.info("XssHttpServletRequestWraper净化后的请求为：==========" + s2);
            return s2;
        }
    }

 //过滤请求体 json 格式的
    @Override
    public ServletInputStream getInputStream() throws IOException {
        final ByteArrayInputStream bais = new ByteArrayInputStream(inputHandlers(super.getInputStream ()).getBytes ());

        return new ServletInputStream() {

            @Override
            public int read() throws IOException {
                return bais.read();
            }

            @Override
            public boolean isFinished() {
                return false;
            }

            @Override
            public boolean isReady() {
                return false;
            }

            @Override
            public void setReadListener(ReadListener readListener) { }
        };
    }

 
    public   String inputHandlers(ServletInputStream servletInputStream){
        StringBuilder sb = new StringBuilder();
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(servletInputStream, Charset.forName("UTF-8")));
            String line = "";
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (servletInputStream != null) {
                try {
                    servletInputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return  cleanXSS(sb.toString ());
    }

    public String cleanXSS(String src) {
        String temp = src;

        src = src.replaceAll("<", "＜").replaceAll(">", "＞");
        src = src.replaceAll("\\(", "（").replaceAll("\\)", "）");
        src = src.replaceAll("'", "＇");
        src = src.replaceAll(";", "；");
        //bgh 2018/05/30  新增
        /**-----------------------start--------------------------*/
        src = src.replaceAll("<", "& lt;").replaceAll(">", "& gt;");
        src = src.replaceAll("\\(", "& #40;").replaceAll("\\)", "& #41");
        src = src.replaceAll("eval\\((.*)\\)", "");
        src = src.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");
        src = src.replaceAll("script", "");
        src = src.replaceAll("link", "");
        src = src.replaceAll("frame", "");
        /**-----------------------end--------------------------*/
        Pattern pattern = Pattern.compile("(eval\\((.*)\\)|script)",
                Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(src);
        src = matcher.replaceAll("");

        pattern = Pattern.compile("[\\\"\\'][\\s]*javascript:(.*)[\\\"\\']",
                Pattern.CASE_INSENSITIVE);
        matcher = pattern.matcher(src);
        src = matcher.replaceAll("\"\"");

        // 增加脚本
        src = src.replaceAll("script", "").replaceAll(";", "")
                /*.replaceAll("\"", "").replaceAll("@", "")*/
                .replaceAll("0x0d", "").replaceAll("0x0a", "");

        if (!temp.equals(src)) {
            // System.out.println("输入信息存在xss攻击！");
            // System.out.println("原始输入信息-->" + temp);
            // System.out.println("处理后信息-->" + src);

            log.error("xss攻击检查：参数含有非法攻击字符，已禁止继续访问！！");
            log.error("原始输入信息-->" + temp);

            throw new CustomerException("xss攻击检查：参数含有非法攻击字符，已禁止继续访问！！");
        }
        return src;
    }

    //输出
    public void outputMsgByOutputStream(HttpServletResponse response, String msg) throws IOException {
        ServletOutputStream outputStream = response.getOutputStream(); //获取输出流
        response.setHeader("content-type", "text/html;charset=UTF-8"); //通过设置响应头控制浏览器以UTF-8的编码显示数据，如果不加这句话，那么浏览器显示的将是乱码
        byte[] dataByteArr = msg.getBytes("UTF-8");// 将字符转换成字节数组，指定以UTF-8编码进行转换
        outputStream.write(dataByteArr);// 使用OutputStream流向客户端输出字节数组
    }

    // 需要增加通配，过滤大小写组合
    public String cleanSQLInject(String src) {
        String lowSrc = src.toLowerCase();
        String temp = src;
        String lowSrcAfter = lowSrc.replaceAll("insert", "forbidI")
                .replaceAll("select", "forbidS")
                .replaceAll("update", "forbidU")
                .replaceAll("delete", "forbidD").replaceAll("and", "forbidA")
                .replaceAll("or", "forbidO");

        if (!lowSrcAfter.equals(lowSrc)) {
            log.error("sql注入检查：输入信息存在SQL攻击！");
            log.error("原始输入信息-->" + temp);
            log.error("处理后信息-->" + lowSrc);
            throw new CustomerException("sql注入检查：参数含有非法攻击字符，已禁止继续访问！！");

        }
        return src;
    }

}
```

### ② 把请求过滤类`XssHttpServletRequestWraper`添加到Filter中，注入容器

```java
@Component
public class XssFilter implements Filter {

    Logger log  = LoggerFactory.getLogger(this.getClass());

    // 忽略权限检查的url地址
    private final String[] excludeUrls = new String[]{
            "null"
    };

    public void doFilter(ServletRequest arg0, ServletResponse arg1, FilterChain arg2)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) arg0;
        HttpServletResponse response = (HttpServletResponse) arg1;

        String pathInfo = req.getPathInfo() == null ? "" : req.getPathInfo();
        //获取请求url的后两层
        String url = req.getServletPath() + pathInfo;
        //获取请求你ip后的全部路径
        String uri = req.getRequestURI();
        //注入xss过滤器实例
        XssHttpServletRequestWraper reqW = new XssHttpServletRequestWraper(req);

        //过滤掉不需要的Xss校验的地址
        for (String str : excludeUrls) {
            if (uri.indexOf(str) >= 0) {
                arg2.doFilter(arg0, response);
                return;
            }
        }
        //过滤
        arg2.doFilter(reqW, response);
    }
    public void destroy() {
    }
    public void init(FilterConfig filterconfig1) throws ServletException {
    }
}
```

上述代码已经可以完成 请求参数、JSON请求体 的过滤，但对于json请求体还有其他的方式实现，有兴趣的请看下面的扩展！

扩展：还可以重写spring中的`MappingJackson2HttpMessageConverter`来过滤Json请求体

因为请求体在进出Contoroller时，会经过`MappingJackson2HttpMessageConverter`的一个转换，把请求体转换成我们需要的json格式，所以可以在这里边做一些修改！

```java
@Configuration
public class MyConfiguration {

    @Bean
    public MappingJackson2HttpMessageConverter mappingJackson2HttpMessageConverter(){
        //自定义转换器
        MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();


        //转换器日期格式设置
        ObjectMapper objectMapper = new ObjectMapper();
        SimpleDateFormat smt = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        objectMapper.setDateFormat(smt);
        converter.setObjectMapper(objectMapper);

        //转换器添加自定义Module扩展，主要是在这里做XSS过滤的！！，其他的是其他业务，不用看
        SimpleModule simpleModule = new SimpleModule();
        //添加过滤逻辑类！
        simpleModule.addDeserializer(String.class,new StringDeserializer());
        converter.getObjectMapper().registerModule(simpleModule);

        //设置中文编码格式
        List<MediaType> list = new ArrayList<>();
        list.add(MediaType.APPLICATION_JSON_UTF8);
        converter.setSupportedMediaTypes(list);

        return converter;
    }

}
```

真正的过滤逻辑类`StringDeserializer`：

```java
//检验请求体的参数
@Component
public class StringDeserializer extends JsonDeserializer<String> {
    @Override
    public String deserialize(JsonParser jsonParser, DeserializationContext deserializationContext) throws IOException, JsonProcessingException {
        String str = jsonParser.getText().trim();
        //sql注入拦截
        if (sqlInject(str)) {
          throw new CustomerException("参数含有非法攻击字符，已禁止继续访问！");
        }

        return xssClean(str);

    }

    public boolean sqlInject(String str) {

        if (StringUtils.isEmpty(str)) {
            return false;
        }

        //去掉'|"|;|\字符
        str = org.apache.commons.lang3.StringUtils.replace(str, "'", "");
        str = org.apache.commons.lang3.StringUtils.replace(str, "\"", "");
        str = org.apache.commons.lang3.StringUtils.replace(str, ";", "");
        str = org.apache.commons.lang3.StringUtils.replace(str, "\\", "");

        //转换成小写
        str = str.toLowerCase();

        //非法字符
        String[] keywords = {"master", "truncate", "insert", "select", "delete", "update", "declare", "alert","alter", "drop"};

        //判断是否包含非法字符
        for (String keyword : keywords) {
            if (str.indexOf(keyword) != -1) {
                return true;
            }
        }
        return false;

    }

    //xss攻击拦截

    public String xssClean(String value) {
        if (value == null || "".equals(value)) {
            return value;
        }

        //非法字符
        String[] keywords = {"<", ">", "<>", "()", ")", "(", "javascript:", "script","alter", "''","'"};
        //判断是否包含非法字符
        for (String keyword : keywords) {
            if (value.indexOf(keyword) != -1) {
               throw new CustomerException("参数含有非法攻击字符，已禁止继续访问！");
            }
        }

        return value;
    }
}
```

使用这种形式也可以完成json请求体的过滤，但个人更推荐使用`XssHttpServletRequestWraper`的形式来完成xss过滤！！

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247523057&idx=1&sn=32b42c6b0ac41b48785b7c0d24ce344a&chksm=fcf7453ccb80cc2a4a6cf38d5b9ab0354f09f270418bf4ff5eeb832b020aedabd561979b712d&token=1260267649&lang=zh_CN#rd)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！