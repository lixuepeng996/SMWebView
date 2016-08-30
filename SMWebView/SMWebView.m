//
//  SMWebView.m
//  SMWebView
//
//  Created by lixuepeng on 16/8/26.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import "SMWebView.h"
#import "SMWebviewManager.h"
#import "SMWebViewProgress.h"
#define IPHONE_OS_VERSION_CURRENT_REQUIRED ([[[UIDevice currentDevice] systemVersion] floatValue])

@interface SMWebView()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,SMWebViewProgressDelegate>
@property (nonatomic, assign) double estimatedProgress;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong)SMWebViewProgress* webViewProgress;
@property (nonatomic, strong) NSURLRequest *loadRequest;
@property (nonatomic, strong) NSURLRequest *currentRequest;
@end

@implementation SMWebView
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self createWebView];
    }
    return self;
}
-(id)init{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame isUseUIWebView:NO];
}

-(id)initWithFrame:(CGRect)frame isUseUIWebView:(BOOL)useUIWebView{

    if (self=[super initWithFrame:frame]) {
        _isUseUIWebView=useUIWebView;
        [self createWebView];
    }
    return self;
}

-(void)createWebView{
    if(IPHONE_OS_VERSION_CURRENT_REQUIRED>=8.0 && self.isUseUIWebView == NO)
    {
        [self createWKWebview];
    }
    else
    {
        [self createUIWebView];
     
    }
    [self.webView setFrame:self.bounds];
    [self.webView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.webView];
}

-(void)createWKWebview{
    _isUseUIWebView = NO;
    WKWebViewConfiguration* configuration = [[WKWebViewConfiguration alloc] init];
    
    if ([SMWebviewManager shareManager].processPool) {
        configuration.processPool=[SMWebviewManager shareManager].processPool;
    }else{
        WKProcessPool *processPool=[[WKProcessPool alloc] init];
        [SMWebviewManager shareManager].processPool=processPool;
    }
    
    configuration.preferences = [WKPreferences new];
    configuration.userContentController = [WKUserContentController new];
    WKWebView* webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:configuration];
    webView.UIDelegate = self;
    webView.navigationDelegate = self;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
    _webView = webView;
}

-(void)createUIWebView{
     _isUseUIWebView = YES;
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.bounds];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    for (UIView *subview in [webView.scrollView subviews])
    {
        if ([subview isKindOfClass:[UIImageView class]])
        {
            ((UIImageView *) subview).image = nil;
            subview.backgroundColor = [UIColor clearColor];
        }
    }
    //降低UIWebview存在的内存泄漏,有一定的效果
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.webViewProgress = [[SMWebViewProgress alloc] init];
    webView.delegate = _webViewProgress;
    _webViewProgress.webViewDelegate = self;
    _webViewProgress.progressDelegate = self;
    
    _webView = webView;
}

#pragma mark- UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if(self.loadRequest == nil)
    {
        self.loadRequest = webView.request;
    }
    [self myWebViewDidFinishLoad];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self myWebViewDidStartLoad];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self myWebViewDidFailLoadWithError:error];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL resultBOOL = [self myWebViewShouldStartLoadWithRequest:request navigationType:navigationType];
    return resultBOOL;
}
- (void)webViewProgress:(SMWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    self.estimatedProgress = progress;
}

#pragma mark- WKNavigationDelegate
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"%@",navigationAction.request.URL);
    BOOL resultBOOL = [self myWebViewShouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
    if(resultBOOL)
    {
        self.currentRequest = navigationAction.request;
        if(navigationAction.targetFrame == nil)
        {
            [webView loadRequest:navigationAction.request];
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    else
    {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self myWebViewDidStartLoad];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self myWebViewDidFinishLoad];
}
- (void)webView:(WKWebView *) webView didFailProvisionalNavigation: (WKNavigation *) navigation withError: (NSError *) error
{
    [self myWebViewDidFailLoadWithError:error];
}
- (void)webView: (WKWebView *)webView didFailNavigation:(WKNavigation *) navigation withError: (NSError *) error
{
    [self myWebViewDidFailLoadWithError:error];
}

#pragma mark-webview代理
- (void)myWebViewDidFinishLoad
{
    if([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.delegate webViewDidFinishLoad:self];
    }
}
- (void)myWebViewDidStartLoad
{
    if([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.delegate webViewDidStartLoad:self];
    }
}
- (void)myWebViewDidFailLoadWithError:(NSError *)error
{
    if([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.delegate webView:self didFailLoadWithError:error];
    }
}
-(BOOL)myWebViewShouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(NSInteger)navigationType
{
    BOOL resultBOOL = YES;
    if([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        if(navigationType == -1) {
            navigationType = UIWebViewNavigationTypeOther;
        }
        resultBOOL = [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return resultBOOL;
}
#pragma mark-WKUIDelegate js alert()方法在wk里会被拦截
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    //    if ([_delegate respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:completionHandler:)]) {
    //        [_delegate webView:webView runJavaScriptAlertPanelWithMessage:message completionHandler:completionHandler];
    //    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [(UIViewController*)self.delegate presentViewController:alert animated:YES completion:nil];
    NSLog(@"alert message:%@",message);
}

#pragma mark-wkWebkvo
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"estimatedProgress"])
    {
        self.estimatedProgress = [change[NSKeyValueChangeNewKey] doubleValue];
    }
    else if([keyPath isEqualToString:@"title"])
    {
        self.title = change[NSKeyValueChangeNewKey];
    }
}

- (id)loadRequest:(NSURLRequest *)request
{
    self.loadRequest = request;
    self.currentRequest = request;
    
    if(_isUseUIWebView)
    {
        [(UIWebView*)self.webView loadRequest:request];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.webView loadRequest:request];
    }
}
- (id)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    if(_isUseUIWebView)
    {
        [(UIWebView*)self.webView loadHTMLString:string baseURL:baseURL];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.webView loadHTMLString:string baseURL:baseURL];
    }
}
-(NSURLRequest *)currentRequest
{
    if(_isUseUIWebView)
    {
        return [(UIWebView*)self.webView request];;
    }
    else
    {
        return _currentRequest;
    }
}
-(NSURL *)URL
{
    if(_isUseUIWebView)
    {
        return [(UIWebView*)self.webView request].URL;;
    }
    else
    {
        return [(WKWebView*)self.webView URL];
    }
}
-(BOOL)isLoading
{
    return [self.webView isLoading];
}
-(BOOL)canGoBack
{
    return [self.webView canGoBack];
}
-(BOOL)canGoForward
{
    return [self.webView canGoForward];
}

- (id)goBack
{
    if(_isUseUIWebView)
    {
        [(UIWebView*)self.webView goBack];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.webView goBack];
    }
}
- (id)goForward
{
    if(_isUseUIWebView)
    {
        [(UIWebView*)self.webView goForward];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.webView goForward];
    }
}
- (id)reload
{
    if(_isUseUIWebView)
    {
        [(UIWebView*)self.webView reload];
        return nil;
    }
    else
    {
        return [(WKWebView*)self.webView reload];
    }
}
- (id)reloadFromOrigin
{
    if(_isUseUIWebView)
    {
        if(self.loadRequest)
        {
            [self evaluateJavaScript:[NSString stringWithFormat:@"window.location.replace('%@')",self.loadRequest.URL.absoluteString] completionHandler:nil
             ];
        }
        return nil;
    }
    else
    {
        return [(WKWebView*)self.webView reloadFromOrigin];
    }
}
- (void)stopLoading
{
    [self.webView stopLoading];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    if(_isUseUIWebView)
    {
        NSString* result = [(UIWebView*)self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if(completionHandler)
        {
            completionHandler(result,nil);
        }
    }
    else
    {
        return [(WKWebView*)self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    }
}
-(NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)javaScriptString
{
    if(_isUseUIWebView)
    {
        NSString* result = [(UIWebView*)self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        return result;
    }
    else
    {
        __block NSString* result = nil;
        __block BOOL isExecuted = NO;
        [(WKWebView*)self.webView evaluateJavaScript:javaScriptString completionHandler:^(id obj, NSError *error) {
            result = obj;
            isExecuted = YES;
        }];
        
        while (isExecuted == NO) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        return result;
    }
}

//添加本地js
-(void)addUserScriptWithPath:(NSString*)path injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly{
    NSString* jScript= [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *wkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:jScript injectionTime:injectionTime forMainFrameOnly:forMainFrameOnly];
    [((WKWebView*)(self.webView)).configuration.userContentController addUserScript:wkUScript];
}
//直接添加js代码
-(void)addUserScriptWithJS:(NSString*)js injectionTime:(WKUserScriptInjectionTime)injectionTime forMainFrameOnly:(BOOL)forMainFrameOnly{
    WKUserScript *twkUScript = [[NSClassFromString(@"WKUserScript") alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [((WKWebView*)(self.webView)).configuration.userContentController addUserScript:twkUScript];
}
/**
 *  添加js回调oc通知方式，适用于 iOS8 之后
 */
- (void)addScriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler name:(NSString *)name
{
    if ([_webView isKindOfClass:NSClassFromString(@"WKWebView")]) {
        [[(WKWebView *)_webView configuration].userContentController addScriptMessageHandler:scriptMessageHandler name:name];
    }
}

/**
 *  注销 注册过的js回调oc通知方式，适用于 iOS8 之后
 */
- (void)removeScriptMessageHandlerForName:(NSString *)name
{
    if ([_webView isKindOfClass:NSClassFromString(@"WKWebView")]) {
        [[(WKWebView *)_webView configuration].userContentController removeScriptMessageHandlerForName:name];
    }
}

-(BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL hasResponds = [super respondsToSelector:aSelector];
    if(hasResponds == NO)
    {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    if(hasResponds == NO)
    {
        hasResponds = [self.delegate respondsToSelector:aSelector];
    }
    return hasResponds;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    if([self.webView respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.webView];
    }
    else
    {
        [invocation invokeWithTarget:self.delegate];
    }
}

-(void)dealloc
{
    if(_isUseUIWebView)
    {
        UIWebView* webView = _webView;
        webView.delegate = nil;
    }
    else
    {
        WKWebView* webView = _webView;
        webView.UIDelegate = nil;
        webView.navigationDelegate = nil;
        
        [webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [webView removeObserver:self forKeyPath:@"title"];
    }
    [_webView scrollView].delegate = nil;
    [_webView stopLoading];
    [(UIWebView*)_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    [_webView removeFromSuperview];
    _webView = nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
