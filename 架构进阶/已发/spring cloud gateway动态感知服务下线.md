**大家好，我是不才陈某~**

最近[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)的球友在学习星球中的《精尽Spring Cloud Alibaba》专栏提到一个问题，相信也有很多人在线上环境遇到过，或许也因此被批过：一个集群中有某个服务突然下线，但是网关还是会去请求这个实例，所以线上就报错了，报错信息如下图：

![](https://www.java-family.cn/BlogImage/20230227214054.png)

究其原因到底为何呢？有没有一种靠谱的解决方案呢？别着急，往下看

## 产生原因

Gateway中有个缓存 CachingRouteLocator ，而网关服务使用的是lb模式，服务在上线或者下线之后，未能及时刷新这个缓存，相应的源码如下：

```java
public class CachingRouteLocator implements Ordered, RouteLocator,
		ApplicationListener<RefreshRoutesEvent>, ApplicationEventPublisherAware {

	private static final Log log = LogFactory.getLog(CachingRouteLocator.class);

	private static final String CACHE_KEY = "routes";

	private final RouteLocator delegate;

	private final Flux<Route> routes;

	private final Map<String, List> cache = new ConcurrentHashMap<>();

	private ApplicationEventPublisher applicationEventPublisher;

	public CachingRouteLocator(RouteLocator delegate) {
		this.delegate = delegate;
		routes = CacheFlux.lookup(cache, CACHE_KEY, Route.class)
				.onCacheMissResume(this::fetch);
	}

	private Flux<Route> fetch() {
		return this.delegate.getRoutes().sort(AnnotationAwareOrderComparator.INSTANCE);
	}

	@Override
	public Flux<Route> getRoutes() {
		return this.routes;
	}

	/**
	 * Clears the routes cache.
	 * @return routes flux
	 */
	public Flux<Route> refresh() {
		this.cache.clear();
		return this.routes;
	}

	@Override
	public void onApplicationEvent(RefreshRoutesEvent event) {
		try {
			fetch().collect(Collectors.toList()).subscribe(list -> Flux.fromIterable(list)
					.materialize().collect(Collectors.toList()).subscribe(signals -> {
						applicationEventPublisher
								.publishEvent(new RefreshRoutesResultEvent(this));
						cache.put(CACHE_KEY, signals);
					}, throwable -> handleRefreshError(throwable)));
		}
		catch (Throwable e) {
			handleRefreshError(e);
		}
	}

	private void handleRefreshError(Throwable throwable) {
		if (log.isErrorEnabled()) {
			log.error("Refresh routes error !!!", throwable);
		}
		applicationEventPublisher
				.publishEvent(new RefreshRoutesResultEvent(this, throwable));
	}

	@Deprecated
	/* for testing */ void handleRefresh() {
		refresh();
	}

	@Override
	public int getOrder() {
		return 0;
	}

	@Override
	public void setApplicationEventPublisher(
			ApplicationEventPublisher applicationEventPublisher) {
		this.applicationEventPublisher = applicationEventPublisher;
	}
}
```

那么解决方案就自然能够想出来，只需要在服务下线时能够去实时的刷新这个缓存自然就解决了

## 解决方案

这里通过去监听 Nacos 实例刷新事件，一旦出现实例发生变化马上删除缓存。在删除负载均衡缓存后，Spring Cloud Gateway 在处理请求时发现没有缓存会重新拉取一遍服务列表，这样之后都是用的是最新的服务列表了，也就达到了我们动态感知上下线的目的。

代码如下：

```java
@Component
@Slf4j
public  class NacosInstancesChangeEventListener extends Subscriber<InstancesChangeEvent> {
    @Resource
    private CacheManager defaultLoadBalancerCacheManager;

    @Override
    public void onEvent(InstancesChangeEvent event) {
        log.info("Spring Gateway 接收实例刷新事件：{}, 开始刷新缓存", JacksonUtils.toJson(event));
        Cache cache = defaultLoadBalancerCacheManager.getCache(SERVICE_INSTANCE_CACHE_NAME);
        if (cache != null) {
            cache.evict(event.getServiceName());
        }
        log.info("Spring Gateway 实例刷新完成");
    }

    @Override
    public Class<? extends com.alibaba.nacos.common.notify.Event> subscribeType() {
        return InstancesChangeEvent.class;
    }
}
```

这里通过继承的方式监听 Nacos 的 `InstancesChangeEvent`，在 onEvent 接收到实例刷新的信息后直接删除对应服务的负载均衡缓存，缓存的名字是定义在 Spring Gateway 的相关代码中的，直接引入即可，`Cache` 则是继承自 Spring Cache 接口，负载均衡缓存也继承了 Cache 接口，有了 Cache 接口就可以直接使用其接口定义的 evict 方法即可，而缓存的 key 名就则就是服务名，在 InstancesChangeEvent 中，通过 getServiceName 就可以得到服务名。

这里就不演示了，有兴趣的小伙伴可以测试一下

## 最后说一句（别白嫖，求关注）

陈某每一篇文章都是精心输出，如果这篇文章对你有所帮助，或者有所启发的话，帮忙**点赞**、**在看**、**转发**、**收藏**，你的支持就是我坚持下去的最大动力！

另外陈某的[知识星球](https://mp.weixin.qq.com/s?__biz=MzU3MDAzNDg1MA==&mid=2247518914&idx=1&sn=b3fdfd78c32b15077ac67535ccc10a00&scene=21#wechat_redirect)开通了，公众号回复关键词：**知识星球** 获取限量**30元**优惠券加入只需**89**元，一顿饭钱，但是星球回馈的价值却是巨大，目前更新了**Spring全家桶实战系列**、**亿级数据分库分表实战**、**DDD微服务实战专栏**、**我要进大厂、Spring，Mybatis等框架源码、架构实战22讲**等....每增加一个专栏价格将上涨20元

![](https://mmbiz.qpic.cn/mmbiz_png/19cc2hfD2rBvqdy8J18dlib7KepGcvuW08g7COtYpQvVoZzRtQFLgaW1GxibV1vsWMQ27S4wsOlt1ySoh3uEAeIw/640?wx_fmt=png&wxfrom=5&wx_lazy=1&wx_co=1)

关注公众号：【码猿技术专栏】，公众号内有超赞的粉丝福利，回复：加群，可以加入技术讨论群，和大家一起讨论技术，吹牛逼！