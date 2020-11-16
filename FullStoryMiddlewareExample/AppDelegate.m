//
//  AppDelegate.m
//  FullStoryMiddlewareExample
//
//  Created by FullStory on 9/24/20.
//  Copyright (c) 2020 FullStory. All rights reserved.
//

#import "AppDelegate.h"
#import <Analytics/SEGAnalytics.h>
#import <FullStoryMiddleware/FullStoryMiddleware.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // set certain events to be the only ones allowed to forward to FullStory
    NSArray *allowList = @[@"Product Viewed", @"Order Completed", @"Completed Checkout Step"];
    FullStoryMiddleware *fsm = [[FullStoryMiddleware alloc] initWithAllowlistEvents: allowList];
    
    // enable to insert FS session URL to Segment event properties and contexts
    // default to true
    fsm.enableFSSessionURLInEvents = true;
    // when calling Segment group, send group traits as userVars
    // default to false
    fsm.enableGroupTraitsAsUserVars = true;
    // when calling Segment screen, sent the screen event as custom events to FS
    // default to false
    fsm.enableSendScreenAsEvents = true;
    // allow all track events as FS custom events
    // alternatively allow list events that you would like to track
    // note: enabling this will cause the middleware to ignore the event allowlist
    // default to false
    fsm.allowlistAllTrackEvents = true;
    
    
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"jg953hydkaC9F8ViwqfMwfufFW9FlwJT"];
    configuration.trackApplicationLifecycleEvents = YES;
    configuration.recordScreenViews = YES;
    
    // Add FullStoryMiddleware as one of the sourceMiddlewares
    configuration.middlewares = @[fsm];
    [SEGAnalytics setupWithConfiguration:configuration];

    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
