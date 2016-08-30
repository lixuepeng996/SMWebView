//
//  SMScriptMessageDelegate.m
//  smell
//
//  Created by lixuepeng on 16/8/15.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import "SMScriptMessageDelegate.h"

@implementation SMScriptMessageDelegate

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate
{
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end
