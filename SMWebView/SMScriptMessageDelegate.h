//
//  SMScriptMessageDelegate.h
//  smell
//
//  Created by lixuepeng on 16/8/15.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WKScriptMessageHandler.h>

@interface SMScriptMessageDelegate : NSObject <WKScriptMessageHandler>

@property (nonatomic, assign) id<WKScriptMessageHandler> scriptDelegate;

- (id)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end
