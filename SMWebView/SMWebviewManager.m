//
//  SMWebviewManager.m
//  SMWebView
//
//  Created by lixuepeng on 16/8/26.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import "SMWebviewManager.h"

@implementation SMWebviewManager
+(SMWebviewManager*)shareManager
{
    static SMWebviewManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

@end
