//
//  SMWebviewManager.h
//  SMWebView
//
//  Created by lixuepeng on 16/8/26.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
@interface SMWebviewManager : NSObject
+(SMWebviewManager*)shareManager;
@property(nonatomic,strong) WKProcessPool *processPool;//一个web内容加载池,wk不支持cache和cookie，可通过同一个processPool来实现共用cookie
@end
