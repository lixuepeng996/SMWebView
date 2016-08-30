//
//  SMJSExportFunction.h
//  SMWebView
//
//  Created by lixuepeng on 16/8/29.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
//UIWebView 要实现js调用oc方法  得实现JSExport代理
@class SMJSExportFunction;
@protocol SMJSExportFunctionDelegate <NSObject>
@optional
-(void)tttt:(id)sender;
@end
@protocol SMJSExportFunctionObjectProtocol <JSExport>
-(void)tttt:(id)sender;
@end
@interface SMJSExportFunction : NSObject<SMJSExportFunctionObjectProtocol>
@property(nonatomic,weak)id<SMJSExportFunctionDelegate>delegate;
@end
