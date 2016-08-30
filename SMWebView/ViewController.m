//
//  ViewController.m
//  SMWebView
//
//  Created by lixuepeng on 16/8/26.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import "ViewController.h"
#import "SMWebView.h"
#import <WebKit/WebKit.h>
#import "SMScriptMessageDelegate.h"
#import "SMJSExportFunction.h"
@interface ViewController ()<SMWebViewDelegate,SMJSExportFunctionDelegate>
@property(nonatomic,strong)SMWebView *webView;
@property (strong, nonatomic) JSContext *context;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView=[[SMWebView alloc] initWithFrame:CGRectMake(0, 0, 320,568) isUseUIWebView:YES];
    _webView.delegate=self;
    _webView.backgroundColor=[UIColor redColor];
    [self.view addSubview:_webView];
    self.title = [NSString stringWithFormat:@"当前使用的是：%@",_webView.isUseUIWebView?@"UIWebview":@"WKWebView"];
    if(_webView.isUseUIWebView)
    {
        //线面是UIWebview 设置cookie的方法
        NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"www.baidu.com"]];//此处链接应为你的项目ip
        for (NSHTTPCookie *cookie in cookies){
            NSArray *headeringCookie = [NSHTTPCookie cookiesWithResponseHeaderFields:[NSDictionary dictionaryWithObject:[[NSString alloc] initWithFormat:@"%@=%@",[cookie name],[cookie value]]forKey:@"Set-Cookie"]forURL:[NSURL URLWithString:@"www.baidu.com"]];
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie forURL:[NSURL URLWithString:@"www.baidu.com"]mainDocumentURL:nil];
        }
    }
    else
    {
        //注入本地js
        [_webView addUserScriptWithPath:[[NSBundle mainBundle] pathForResource:@"testJS" ofType:@"js"] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        
        //向js注入AppModel对象，这样js可以该对象传值
        SMScriptMessageDelegate *sDelegate=[[SMScriptMessageDelegate alloc] initWithDelegate:(id)self];
        [self.webView addScriptMessageHandler:sDelegate name:@"AppModel"];
        
        //因为wk不支持nsurlcachie 如果想实现设置cachie，可通过植入js代码的方式实现 调用jsdocument.cookie来设置
        [_webView addUserScriptWithJS:[NSString stringWithFormat:@"document.cookie=\'%@\'",[NSString stringWithFormat:@"JSESSIONID=272173718"]] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    }
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"testHTML" ofType:@"HTML"];
    [_webView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:[NSURL fileURLWithPath:filePath]];
    [self.view bringSubviewToFront:self.webBackBtn];
    // Do any additional setup after loading the view, typically from a nib.
}
// js给oc传值 再此实现方法调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",message.body);
    NSString *function=[NSString stringWithFormat:@"%@:",message.body[@"fun"]];
    //   NSDictionary *prama=message.body[@"prama"];
    if ([self respondsToSelector:NSSelectorFromString(function) ]) {
        [self performSelector:NSSelectorFromString(function)  withObject:message.body afterDelay:0.f];
    }
}

-(void)webView:(SMWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}


-(IBAction)webBack:(id)sender{
    NSString *js = @"alert('哈哈')";
    [self.webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSLog(@"response: %@ error: %@", response, error);
        NSLog(@"call js alert by native");
    }];
}

- (void)webViewDidStartLoad:(SMWebView *)webView{
    
}
- (void)webViewDidFinishLoad:(SMWebView *)webView{
    //UIWebView实现js调用oc有两种方式
    if(_webView.isUseUIWebView){
        //这种方法是给js注入SMJSExportFunction对象实现
        self.context = [webView.webView  valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
                SMJSExportFunction *exportFunction =[SMJSExportFunction new];
                exportFunction.delegate=self;
                self.context[@"wobridge"]=exportFunction;
        /*
        //第二种方法  以 JSExport 协议关联 native 的方法
        self.context.exceptionHandler =
        ^(JSContext *context, JSValue *exceptionValue)
        {
            context.exception = exceptionValue;
            NSLog(@"%@", exceptionValue);
        };
        self.context[@"native"] = self;//关联native
        //js中调用sumit方法将在此处响应
        self.context[@"submit"] =
        ^(id dic)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"msg from js" message:@"ll" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
                [alert show];
            });
        };
        */
    }
//    NSString *js = @"submit({pp:'oc',param : '这是一个测试'})";
//    [self.context evaluateScript:js];
}
- (void)webView:(SMWebView *)webView didFailLoadWithError:(NSError *)error{
    
}

-(void)tttt:(id)sender{
    NSLog(@"js调用方法执行%@",sender);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
