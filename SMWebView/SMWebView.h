//
//  SMWebView.h
//  SMWebView
//
//  Created by lixuepeng on 16/8/26.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WKScriptMessageHandler.h>
#import <WebKit/WKSecurityOrigin.h>
#import <WebKit/WebKit.h>
#import <WebKit/WKScriptMessageHandler.h>
@class SMWebView;
@protocol SMWebViewDelegate <NSObject>
@optional
- (void)webViewDidStartLoad:(SMWebView *)webView;
- (void)webViewDidFinishLoad:(SMWebView *)webView;
- (void)webView:(SMWebView *)webView didFailLoadWithError:(NSError *)error;
- (BOOL)webView:(SMWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
-(void)webView:(SMWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message completionHandler:(void (^)(void))completionHandler;
@end
@interface SMWebView : UIView
@property(weak,nonatomic)id<SMWebViewDelegate> delegate;
// ios8一下只能用UIWebview
-(id)initWithFrame:(CGRect)frame isUseUIWebView:(BOOL)useUIWebView;
//当前是用的webview
@property (nonatomic, readonly) id webView;
@property (nonatomic, readonly) BOOL isUseUIWebView;
//初始请求
@property (nonatomic, readonly) NSURLRequest *loadRequest;
//当前网页链接请求
@property (nonatomic, readonly) NSURLRequest *currentRequest;
//预估网页加载速度
@property (nonatomic, readonly) double estimatedProgress;

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly) BOOL canGoBack;//网页是否可后退
@property (nonatomic, readonly) BOOL canGoForward;//网页是否可前进

- (id)loadRequest:(NSURLRequest *)request;
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

- (id)goBack;
- (id)goForward;
- (id)reload;
- (id)reloadFromOrigin;
- (void)stopLoading;

//添加本地js,ios8以后可用
-(void)addUserScriptWithPath:(NSString*)path injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly;
//UIWebview 可以通过urlcache的方式拦截url来实现替换js，wk不可以
//直接添加js代码
-(void)addUserScriptWithJS:(NSString*)js injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly;
 //添加js回调通知方式,ios8以后可用
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name;
 //注销注册过的js回调通知方式，ios8以后可用
- (void)removeScriptMessageHandlerForName:(NSString *)name;
//执行js函数
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;

@end
