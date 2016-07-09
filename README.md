# UIWebviewWithCookie

这两天有个项目需求，在网上找了好多博文都不可以拿来就能实现（对于伸手党怎么能行），为了避免浪费大家的时间我在这里给出一份一定可行的方法：

 ## 1.相关知识点介绍
  
    1. iOS在`UIWebView`中获取的cookie的方法：`NSHTTPCookieStorage * nCookies = [NSHTTPCookieStorage sharedHTTPCookieStorage]`
    2. 再具体获取某个域的饼干：`NSArray* cookiesURL = [nCookies cookiesForURL：[NSURL URLWithString：@“你的URL”]];`
    3. 通过`[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie]`方法将 `cookies`来保存起来，但是这样虽然可以保存`cookies`但是你应用退出之后还是会丢失(其实是cookies过期的问题)，做好的方法是把`cookies`放到`NSUserDefaults`保存起来:
## 2、实现方法  
 
###1. **在UIWebView的代理方法中实现获取`cookies`并将`cookies`放到`NSUserDefaults`保存起来：** `(void)webViewDidFinishLoad:(UIWebView *)webView`中写入

 ```
 NSArray *nCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSHTTPCookie *cookie;
    for (id c in nCookies)
    {
        if ([c isKindOfClass:[NSHTTPCookie class]])
        {
            cookie=(NSHTTPCookie *)c;
            if ([cookie.name isEqualToString:@"PHPSESSID"]) {
                NSNumber *sessionOnly = [NSNumber numberWithBool:cookie.sessionOnly];
                NSNumber *isSecure = [NSNumber numberWithBool:cookie.isSecure];
                NSArray *cookies = [NSArray arrayWithObjects:cookie.name, cookie.value, sessionOnly, cookie.domain, cookie.path, isSecure, nil];
                [[NSUserDefaults standardUserDefaults] setObject:cookies forKey:@"cookies"];
                break;
            }
        }
    }

###2.**获取`cookies`：运行之后，`UIWebview`加载url之前获取保存好的`cookies`，并设置`cookies`**

 NSArray *cookies =[[NSUserDefaults standardUserDefaults]  objectForKey:@"cookies"];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:[cookies objectAtIndex:0] forKey:NSHTTPCookieName];
        [cookieProperties setObject:[cookies objectAtIndex:1] forKey:NSHTTPCookieValue];
        [cookieProperties setObject:[cookies objectAtIndex:3] forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:[cookies objectAtIndex:4] forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookieuser = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]  setCookie:cookieuser];
 ```

**注意：要在[self.webView loadRequest:req];之前设置获取cookies！**
到现在为止你的应用肯定就已经实现了你想要的功能！
吃水不忘挖井人：（其中连接上面实现的稍微有些问题，我在我这里已经进行了修改）[功能实现参考链接](http://blog.csdn.net/gx_wqm/article/details/47086181)
