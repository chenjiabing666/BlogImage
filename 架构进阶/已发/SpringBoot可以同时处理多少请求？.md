**大家好，我是不才陈某~**



我们都知道，SpringBoot默认的内嵌容器是Tomcat，也就是我们的程序实际上是运行在Tomcat里的。所以与其说SpringBoot可以处理多少请求，倒不如说Tomcat可以处理多少请求。



关于Tomcat的默认配置，都在`spring-configuration-metadata.json`文件中，对应的配置类则是`org.springframework.boot.autoconfigure.web.ServerProperties`。



![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109447907-799e3a42-fc9c-4e1f-beb0-0bf4395bd813.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_27%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)



和处理请求数量相关的参数有四个：

![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109460468-9a440188-11b4-453e-a127-11d2f1cbad59.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_31%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)





- **「server.tomcat.threads.min-spare」**：最少的工作线程数，默认大小是10。该参数相当于长期工，如果并发请求的数量达不到10，就会依次使用这几个线程去处理请求。
- **「server.tomcat.threads.max」**：最多的工作线程数，默认大小是200。该参数相当于临时工，如果并发请求的数量在10到200之间，就会使用这些临时工线程进行处理。
- **「server.tomcat.max-connections」**：最大连接数，默认大小是8192。表示Tomcat可以处理的最大请求数量，超过8192的请求就会被放入到等待队列。
- **「server.tomcat.accept-count」**：等待队列的长度，默认大小是100。



举个例子说明一下这几个参数之间的关系：

![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109473482-c40be281-2f34-4ee1-a685-7572e2caabb8.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_31%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)





如果把Tomcat比作一家饭店的话，那么一个请求其实就相当于一位客人。min-spare就是厨师(长期工)；max是厨师总数(长期工+临时工)；max-connections就是饭店里的座位数量；accept-count是门口小板凳的数量。来的客人优先坐到饭店里面，然后厨师开始忙活，如果长期工可以干得完，就让长期工干，如果长期工干不完，就再让临时工干。图中画的厨师一共15人，饭店里有30个座位，也就是说，如果现在来了20个客人，那么就会有5个人先在饭店里等着。如果现在来了35个人，饭店里坐不下，就会让5个人先到门口坐一下。如果来了50个人，那么饭店座位+门口小板凳一共40个，所以就会有10人离开。



也就是说，SpringBoot同所能处理的最大请求数量是`max-connections+accept-count`，超过该数量的请求直接就会被丢掉。



**「纸上得来终觉浅，绝知此事要躬行。」**



上面只是理论结果，现在通过一个实际的小例子来演示一下到底是不是这样：



创建一个SpringBoot的项目，在application.yml里配置一下这几个参数，因为默认的数量太大，不好测试，所以配小一点：



```yaml
server:
  tomcat:
    threads:
      # 最少线程数
      min-spare: 10
      # 最多线程数
      max: 15
    # 最大连接数
    max-connections: 30
    # 最大等待数
    accept-count: 10
```



再来写一个简单的接口：



```java
    @GetMapping("/test")
    public Response test1(HttpServletRequest request) throws Exception {
        log.info("ip:{},线程:{}", request.getRemoteAddr(), Thread.currentThread().getName());
        Thread.sleep(500);
        return Response.buildSuccess();
    }
```



代码很简单，只是打印了一下线程名，然后休眠0.5秒，这样肯定会导致部分请求处理一次性处理不了而进入到等待队列。



然后我用Apifox创建了一个测试用例，去模拟100个请求：

![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109502026-6d6b2daa-ce0b-4198-ae63-79cb5675eb22.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_20%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)





观察一下测试结果：

![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109512237-b3d5ec4c-b935-471c-b14e-964ed872f859.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_31%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)





从结果中可以看出，由于设置的 **「max-connections+accept-count」** 的和是40，所以有60个请求会被丢弃，这和我们的预期是相符的。由于最大线程是15，也就是有25个请求会先等待，等前15个处理完了再处理15个，最后在处理10个，也就是将40个请求分成了15,15,10这样三批进行处理。

![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109522896-caae881b-287b-4783-aaa5-e85c4e35b072.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_26%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)





再从控制台的打印日志可以看到，线程的最大编号是15，这也印证了前面的想法。



**「总结一下」**：如果并发请求数量低于**「server.tomcat.threads.max」**，则会被立即处理，超过的部分会先进行等待，如果数量超过max-connections与accept-count之和，则多余的部分则会被直接丢弃。



## 延伸：并发问题是如何产生的



到目前为止，就已经搞明白了SpringBoot同时可以处理多少请求的问题。但是在这里我还想基于上面的例子再延伸一下，就是为什么并发场景下会出现一些值和我们预期的不一样？



设想有以下场景：厨师们用一个账本记录一共做了多少道菜，每个厨师做完菜都记录一下，每次记录都是将账本上的数字先抄到草稿纸上，计算x+1等于多少，然后将计算的结果写回到账本上。

![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109537789-2555085b-1c1d-4146-960b-321c53c3aa60.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_31%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)





Spring容器中的Bean默认是单例的，也就是说，处理请求的Controller、Service实例就只有一份。在并发场景下，将cookSum定义为全局变量，是所有线程共享的，当一个线程读到了cookSum=20，然后计算，写回前另一个线程也读到是20，两个线程都加1后写回，最终cookSum就变成了21，但是实际上应该是22，因为加了两次。



```java
private int cookSum = 0;

@GetMapping("/test")
public Response test1(HttpServletRequest request) throws Exception {
 // 做菜。。。。。。
 cookSum += 1;
    log.info("做了{}道菜", cookSum);
    Thread.sleep(500);
 return Response.buildSuccess();
}
```



![](https://cdn.nlark.com/yuque/0/2023/png/295812/1678109548779-000bccbb-3cf3-4d6d-aa6f-fca8abd0531b.png?x-oss-process=image%2Fwatermark%2Ctype_d3F5LW1pY3JvaGVp%2Csize_31%2Ctext_5YWs5LyX5Y-377ya56CB54y_5oqA5pyv5LiT5qCP%2Ccolor_FFFFFF%2Cshadow_50%2Ct_80%2Cg_se%2Cx_10%2Cy_10)



如果要避免这样的情况发生，就涉及到加锁的问题了，就不在这里讨论了。