//
//  SMJSExportFunction.m
//  SMWebView
//
//  Created by lixuepeng on 16/8/29.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import "SMJSExportFunction.h"

@implementation SMJSExportFunction
-(void)tttt:(id)sender{
    if ([_delegate respondsToSelector:@selector(tttt:)]) {
        [_delegate tttt:sender];
    }
}
@end
