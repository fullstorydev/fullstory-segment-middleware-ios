//
//  AppDelegate.m
//  FullStoryMiddlewareExample
//
//  Created by FullStory on 9/24/20.
//  Copyright (c) 2020 FullStory. All rights reserved.
//

#import "AppDelegate.h"
#import <FullStoryMiddleware/FullStoryMiddleware.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // set certain events to be the only ones allowed to forward to FullStory
    NSArray *allowList = @[@"Product Viewed", @"Order Completed", @"Completed Checkout Step"];
    FullStoryMiddleware *fsm = [[FullStoryMiddleware alloc] initWithAllowlistEvents: allowList];
    
    // Enable to insert FS session URL to Segment event properties and contexts.
    //
    // Default is true.
    fsm.enableFSSessionURLInEvents = true;
    
    // When calling Segment group, send group traits as userVars.
    //
    // Default is false.
    fsm.enableGroupTraitsAsUserVars = true;
    
    // When calling Segment screen, send the screen event as custom events to FS.
    //
    // Default is false.
    fsm.enableSendScreenAsEvents = true;
    
    // Allow all track events as FS custom events.
    // Alternatively, allow list events that you would like to track.
    //
    // Note: enabling this will cause the middleware to ignore the event allowlist.
    //
    // Default is false.
    fsm.allowlistAllTrackEvents = true;
    
    // Allow all identify events as FS identify.
    //
    // Default is true.
    fsm.enableIdentifyEvents = true;
    
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"YOUR_SEGMENT_KEY_HERE"];
    configuration.trackApplicationLifecycleEvents = YES;
    configuration.recordScreenViews = YES;
    
    // Add FullStoryMiddleware as one of the sourceMiddlewares
    configuration.sourceMiddleware = @[fsm];
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
