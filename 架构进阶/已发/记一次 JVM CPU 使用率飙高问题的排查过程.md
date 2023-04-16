



**大家好，我是不才陈某~**

## 1.CAS服务端构建

### 1.1.war包部署

cas5.3版本

> https://github.com/apereo/cas-overlay-template

构建完成后将war包部署到tomcat即可

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JwdbjupDFptEzb2JnicxgfpzeEdTSIpbNrDPticqxgku6ykHQTagOgBLA/640?wx_fmt=png)

### 1.2.配置文件修改

**支持http协议**

修改`apache-tomcat-8.5.53\webapps\cas\WEB-INF\classes\services`目录下的`HTTPSandIMAPS-10000001.json`，在serviceId中添加http即可

```json
{
  "@class" : "org.apereo.cas.services.RegexRegisteredService",
  "serviceId" : "^(https|http|imaps)://.*",
  "name" : "HTTPS and IMAPS",
  "id" : 10000001,
  "description" : "This service definition authorizes all application urls that support HTTPS and IMAPS protocols.",
  "evaluationOrder" : 10000
}
```

在`apache-tomcat-8.5.53\webapps\cas\WEB-INF\classes`下application.properties添加配置

```properties
cas.tgc.secure=false
cas.serviceRegistry.initFromJson=true
```

**配置默认登录用户名密码及登出重定向**

修改`apache-tomcat-8.5.53\webapps\cas\WEB-INF\classes`下application.properties配置

```properties
cas.authn.accept.users=admin::admin

#配置允许登出后跳转到指定页面
cas.logout.followServiceRedirects=true
```

### 1.3.启动

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JPLTljWdeHelMeicCSB3Kia1cOY5icZHgZoK0SicbBU6ZdlRYTx8cjkicibLw/640?wx_fmt=png)

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JeJxo3ibjHVnUYXIsfibAKlTFVY3GeNNDpyu0KLv8Jibel6cicZ7vvcITrg/640?wx_fmt=png)

## 2.客户端构建

### 2.1.pom依赖

```xml
<dependency>
    <groupId>net.unicon.cas</groupId>
    <artifactId>cas-client-autoconfig-support</artifactId>
    <version>2.3.0-GA</version>
</dependency>
```

### 2.2.yml配置

client-host-url配置的地址和前端ajax调用的地址必须一致，统一使用`ip:port`或`hostname:port`；如果本地后端配置localhost，前端使用ip，会造成Ticket验证失败

```yaml
cas:
  server-url-prefix: http://172.19.25.113:8080/cas
  server-login-url: http://172.19.25.113:8080/cas/login
  client-host-url: http://172.19.25.113:1010
  validation-type: cas
  use-session: true
  authentication-url-patterns:
    /auth
```

### 2.3.后端代码

启动类添加`@EnableCasClient`注解

```java
@EnableCasClient
@SpringBootApplication
public class SpringbootCasDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(SpringbootCasDemoApplication.class, args);
    }
}
```

自定义`AuthenticationFilter`重定向策略

```java
public class CustomAuthRedirectStrategy implements AuthenticationRedirectStrategy {

    @Override
    public void redirect(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, String s) throws IOException {
        httpServletResponse.setCharacterEncoding("utf-8");
        httpServletResponse.setContentType("application/json; charset=utf-8");
        PrintWriter out = httpServletResponse.getWriter();
        out.write("401");
    }
}
```

Cors及CasClient相关filter初始化参数配置

```java
@Configuration
public class CasAuthConfig extends CasClientConfigurerAdapter {

    @Override
    public void configureAuthenticationFilter(FilterRegistrationBean authenticationFilter) {
        Map<String, String> initParameters = authenticationFilter.getInitParameters();
        initParameters.put("authenticationRedirectStrategyClass", "cc.jasonwang.springbootcasdemo.config.CustomAuthRedirectStrategy");
    }

    @Override
    public void configureValidationFilter(FilterRegistrationBean validationFilter) {
        Map<String, String> initParameters = validationFilter.getInitParameters();
        initParameters.put("encodeServiceUrl", "false");
    }

    @Bean
    public FilterRegistrationBean corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        config.addAllowedOrigin("*");
        config.addAllowedHeader("*");
        config.addAllowedMethod("*");
        source.registerCorsConfiguration("/**", config);
        FilterRegistrationBean<CorsFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new CorsFilter(source));
        registrationBean.setOrder(-2147483648);
        return registrationBean;
    }
}
```

Controller

```java
@RestController
public class HelloController {

    @Value("${cas.server-url-prefix}")
    private String casServerUrlPrefix;

    @GetMapping("/auth")
    public void auth(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        Assertion assertion = (Assertion) session.getAttribute("_const_cas_assertion_");
        response.setHeader("Content-type", "application/json;charset=UTF-8");
        response.setCharacterEncoding("utf-8");
        response.setStatus(200);
        if (assertion != null) {
            String redirectUrl= request.getParameter("redirectUrl");
            try {
                response.setHeader("Content-type", "text/html;charset=UTF-8");
                response.sendRedirect(redirectUrl);
            } catch (IOException e) {
                e.printStackTrace();
            }
        } else {
            try {
                response.getWriter().print("401");
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    @GetMapping("/logout")
    public RedirectView logout(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        session.invalidate();
        String indexPageUrl = "http://127.0.0.1";
        return new RedirectView( casServerUrlPrefix + "/logout?service=" + indexPageUrl);
    }
}
```

### 2.4.页面

```html
<!DOCTYPE html>
<html lang="en" dir="ltr">
  <head>
    <meta charset="utf-8">
    <title></title>
  </head>
  <body>
      <span>单点地址：</span><input class="url" type="text"/><br>
      <button type="button" class="button">登录</button><br>
      <div class="response" style="width: 200px;height:200px;border: 1px solid #3333;"></div>
     <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
      <script type="text/javascript">
        $(".button").click(function(){
          $.get("http://172.19.25.113:1010/auth", function(data){
            $(".response").text(data)
            if(data == 401){
              window.location.href = "http://localhost:8080/cas/login?service=http://172.19.25.113:1010/auth?redirectUrl=http://127.0.0.1"
            }
          })
        })
      </script>
  </body>
</html>
```

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7J1z0Ez6sQsjeT7ddeXg4iajlUZHF8wz1p9PPKqIQ7SNLCQXL9wHmZdRg/640?wx_fmt=png)

这里只是验证前后端分离下页面url跳转问题，页面没有放在nginx服务上

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JibqtNKnN9aod1wYqhkYGOvQDHg3pjMOcjE4qssa1dgpDE5eRvW86PLw/640?wx_fmt=png)

## 3.问题记录

### 3.1在前后端分离情况下，AuthenticationFilter重定向问题，导致前端发生跨域

> - https://www.jianshu.com/p/7b51d04f3327

##### （1）描述

cas前后端不分离的情况下是能够直接跳转的，然而前后端分离后，前端ajax访问后端在经过`AuthenticationFilter`时，验证未登录会重定向到CAS登录，导致前端发生跨域问题

##### （2）解决思路

在`AuthenticationFilter`中不进行重定向，验证未登录就直接返回一个错误状态码；由前端获取到状态码后进行判断，再跳转到CAS登录地址

AuthenticationFilter

```java
public final void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
    HttpServletRequest request = (HttpServletRequest)servletRequest;
    HttpServletResponse response = (HttpServletResponse)servletResponse;
    if (this.isRequestUrlExcluded(request)) {
        this.logger.debug("Request is ignored.");
        filterChain.doFilter(request, response);
    } else {
     // 获取Assertion 验证是否登录
        HttpSession session = request.getSession(false);
        Assertion assertion = session != null ? (Assertion)session.getAttribute("_const_cas_assertion_") : null;
        if (assertion != null) {
            filterChain.doFilter(request, response);
        } else {
            String serviceUrl = this.constructServiceUrl(request, response);
            String ticket = this.retrieveTicketFromRequest(request);
            boolean wasGatewayed = this.gateway && this.gatewayStorage.hasGatewayedAlready(request, serviceUrl);
            if (!CommonUtils.isNotBlank(ticket) && !wasGatewayed) {
                this.logger.debug("no ticket and no assertion found");
                String modifiedServiceUrl;
                if (this.gateway) {
                    this.logger.debug("setting gateway attribute in session");
                    modifiedServiceUrl = this.gatewayStorage.storeGatewayInformation(request, serviceUrl);
                } else {
                    modifiedServiceUrl = serviceUrl;
                }

                this.logger.debug("Constructed service url: {}", modifiedServiceUrl);
                String urlToRedirectTo = CommonUtils.constructRedirectUrl(this.casServerLoginUrl, this.getProtocol().getServiceParameterName(), modifiedServiceUrl, this.renew, this.gateway);
                this.logger.debug("redirecting to \"{}\"", urlToRedirectTo);
                // 通过这个方法进行重定向
                this.authenticationRedirectStrategy.redirect(request, response, urlToRedirectTo);
            } else {
                filterChain.doFilter(request, response);
            }
        }
    }
}
```

DefaultAuthenticationRedirectStrategy

```java
public final class DefaultAuthenticationRedirectStrategy implements AuthenticationRedirectStrategy {
    public DefaultAuthenticationRedirectStrategy() {
    }

    public void redirect(HttpServletRequest request, HttpServletResponse response, String potentialRedirectUrl) throws IOException {
     //response重定向
        response.sendRedirect(potentialRedirectUrl);
    }
}
```

##### （3）实现

自定义重定向策略，将`DefaultAuthenticationRedirectStrategy`替换掉

CustomAuthRedirectStrategy

```java
public class CustomAuthRedirectStrategy implements AuthenticationRedirectStrategy {
    @Override
    public void redirect(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse, String s) throws IOException {
        httpServletResponse.setCharacterEncoding("utf-8");
        httpServletResponse.setContentType("application/json; charset=utf-8");
        PrintWriter out = httpServletResponse.getWriter();
        out.write("401");
    }
}
@Configuration
public class CasAuthConfig extends CasClientConfigurerAdapter {

    @Override
    public void configureAuthenticationFilter(FilterRegistrationBean authenticationFilter) {
        Map<String, String> initParameters = authenticationFilter.getInitParameters();
        initParameters.put("authenticationRedirectStrategyClass", "cc.jasonwang.springbootcasdemo.config.CustomAuthRedirectStrategy");
 }
}
```

### 3.2AuthenticationFilter自定义重定向策略实现后，前端仍然发生跨域问题

Spring 里那么多种 CORS 的配置方式，到底有什么区别

##### （1）描述

原使用`WebMvcConfigurationSupport`实现CORS，`AuthenticationFilter`输出状态码后，前端仍然发生跨域问题

```java
@Configuration
public class CorsConfig extends WebMvcConfigurationSupport {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowedHeaders("*")
                .allowedMethods("*")
                .maxAge(3600)
                .allowCredentials(true);
    }
}
```

##### （2）解决思路

通过查找资料发现：

实现 `WebMvcConfigurationSupport.addCorsMappings` 方法来进行的 CORS 配置，最后会在 Spring 的 Interceptor 或 Handler 中生效

注入 CorsFilter 的方式会让 CORS 验证在 Filter 中生效

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JsSpLMM3rUV3ic54u4eTeUicysIWa5UgSewAOC5ajJ3jVmS3S3aILibVRQ/640?wx_fmt=png)

##### （3）实现

修改CORS实现方式

```java
@Bean
public FilterRegistrationBean corsFilter() {
    UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowCredentials(true);
    config.addAllowedOrigin("*");
    config.addAllowedHeader("*");
    config.addAllowedMethod("*");
    source.registerCorsConfiguration("/**", config);
    FilterRegistrationBean<CorsFilter> registrationBean = new FilterRegistrationBean<>();
    registrationBean.setFilter(new CorsFilter(source));
    registrationBean.setOrder(-2147483648);
    return registrationBean;
}
```

### 3.3前端跳转CAS登录并传递redirectUrl参数，Ticket票据验证问题

##### （1）原因

`Cas20ProxyReceivingTicketValidationFilter`在进行Ticket验证时，CAS重定向的service地址进行了URLEncoder编码，而CAS使用Ticket获取到存储的service地址未进行编码，导致两个service不一致，造成Ticket票据验证失败

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JLsiaOmIbtia6L67B2gOSicxZ6WLJgjDh8TVFhNoFwEJ7oc9TwO6u8pjRg/640?wx_fmt=png)

##### （2）debug定位问题

AbstractTicketValidationFilter

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7J0aA9Z9qTaRObszcHtn4xVCKQQ2qpgMoy9DkdGlHH023zZdyABuphDg/640?wx_fmt=png)

AbstractUrlBasedTicketValidator

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JCQFe0Dan8XlJoOmp7I4NDM8jyKymGowUVic2pn5FDzLG86nJyW8siavQ/640?wx_fmt=png)

找到CAS服务器接口地址后，便想到在CAS服务器端看下接口是怎么实现的，下面就是在CAS服务器debug后的结果

**CAS Server**

在web.xml中找到了servlet映射

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JTJ7tpbA7Arh9Q3tmicZEuqOvicic1DtuA7T8tydwhJUerpmE7v6pauqiag/640?wx_fmt=png)

定位到`SafeDispatcherServlet`，根据目录结构和类文件名称找到了`ServiceValidateController`

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7Jia29dRlCpnzYibAMJ53HzSrR0k4YhflGBn5KYcr4fQza4QUPmicaBtj8g/640?wx_fmt=png)

ServiceValidateController

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JHgv2zSjP5xMkle9twlWKZCUONu0CYsibXrVnb3whF4hbfrQ3QJyTlmw/640?wx_fmt=png)

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7J0Ntl0KsKvyYJzkkTZR1pdsmnW5dpicaPbCLiaeicPGgslR1s5fzgjjLaw/640?wx_fmt=png)

![](https://mmbiz.qpic.cn/mmbiz_png/JfTPiahTHJho1qqhO80yeKG3JGic41Tb7JoDqEIWVhqgGIxpO8DPHtFaVeEgk9jkVxsLyBQSjfH4XT47GJfPeFEw/640?wx_fmt=png)

##### （3）实现

对`Cas20ProxyReceivingTicketValidationFilter`添加`encodeServiceUrl=false`初始化参数

```java
@Configuration
public class CasAuthConfig extends CasClientConfigurerAdapter {

    @Override
    public void configureAuthenticationFilter(FilterRegistrationBean authenticationFilter) {
        Map<String, String> initParameters = authenticationFilter.getInitParameters();
        initParameters.put("authenticationRedirectStrategyClass", "cc.jasonwang.springbootcasdemo.config.CustomAuthRedirectStrategy");
    }

    @Override
    public void configureValidationFilter(FilterRegistrationBean validationFilter) {
        Map<String, String> initParameters = validationFilter.getInitParameters();
        initParameters.put("encodeServiceUrl", "false");
    }
}
```

