//
//  SMWebViewProgress.h
//  smell
//
//  Created by lixuepeng on 16/8/15.
//  Copyright © 2016年 lixuepeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern const float SMInitialProgressValue;
extern const float SMInteractiveProgressValue;
extern const float SMFinalProgressValue;
typedef void (^SMWebViewProgressBlock)(float progress);
@protocol SMWebViewProgressDelegate;
@interface SMWebViewProgress : NSObject<UIWebViewDelegate>
@property (nonatomic, assign) id<SMWebViewProgressDelegate>progressDelegate;
@property (nonatomic, assign) id<UIWebViewDelegate>webViewDelegate;
@property (nonatomic, copy) SMWebViewProgressBlock progressBlock;
@property (nonatomic, readonly) float progress; // 0.0..1.0
- (void)reset;
@end
@protocol SMWebViewProgressDelegate <NSObject>
- (void)webViewProgress:(SMWebViewProgress *)webViewProgress updateProgress:(float)progress;
@end