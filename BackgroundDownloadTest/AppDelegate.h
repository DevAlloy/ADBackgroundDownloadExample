//
//  AppDelegate.h
//  BackgroundDownloadTest
//
//  Created by Tsyganov Stanislav on 10.01.14.
//  Copyright (c) 2014 Tsyganov Stanislav. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) void (^backgroundSessionCompletionHandler)();

@end
