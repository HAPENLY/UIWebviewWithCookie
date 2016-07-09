//
//  ViewController.m
//  UIWebviewWithCookie
//
//  Created by hudong on 16/7/9.
//  Copyright © 2016年 ZPengs. All rights reserved.
//
/**
 *  详见简书地址：http://www.jianshu.com/p/9bf9a82183bb
 *  喜欢Star谢谢！
 */

#import "ViewController.h"
#define YourURL @"http://www.baidu.com"
@interface ViewController ()<UIWebViewDelegate>
@property (nonatomic,strong)UIWebView *webView;
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.scrollView.frame =self.webView.frame;
    _webView.backgroundColor = [UIColor grayColor];
    _webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20)];
    _webView.delegate = self;
    //判断是否沙盒中是否有这个值
    if ([[[[NSUserDefaults standardUserDefaults]dictionaryRepresentation]allKeys]containsObject:@"cookie"]) {
        //获取cookies：程序起来之后，uiwebview加载url之前获取保存好的cookies，并设置cookies，
        NSArray *cookies =[[NSUserDefaults standardUserDefaults]  objectForKey:@"cookie"];
        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
        [cookieProperties setObject:[cookies objectAtIndex:0] forKey:NSHTTPCookieName];
        [cookieProperties setObject:[cookies objectAtIndex:1] forKey:NSHTTPCookieValue];
        [cookieProperties setObject:[cookies objectAtIndex:3] forKey:NSHTTPCookieDomain];
        [cookieProperties setObject:[cookies objectAtIndex:4] forKey:NSHTTPCookiePath];
        NSHTTPCookie *cookieuser = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]  setCookie:cookieuser];
    }
    //发请求
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",YourURL]]];
    _webView.scalesPageToFit = YES;
    [ self.webView loadRequest:req];
    [self.view addSubview:self.webView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
// 将获取的cookie储存在沙盒中（ 通过 [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie: cookies]来保存cookies，但是我发现，即使这样设置之后再app退出之后，该cookies还是丢失了（其实是cookies过期的问题)
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
                [[NSUserDefaults standardUserDefaults] setObject:cookies forKey:@"cookie"];
                break;
            }
        }
    }
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"--------------%@",error);
}
@end

