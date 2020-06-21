//
//  Constants.m
//  Analytics
//
//  Created on 6/20/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@implementation Constants

+ (NSArray *)segmentEventsArray {
    // All possible event names from Event integer enum: https://segment.com/docs/connections/sources/catalog/libraries/mobile/ios/#usage
    return @[
            // Should not happen, but default state
            @"SEGEventTypeUndefined",
            // Core Tracking Methods
            @"SEGEventTypeIdentify",
            @"SEGEventTypeTrack",
            @"SEGEventTypeScreen",
            @"SEGEventTypeGroup",
            @"SEGEventTypeAlias",
    
            // General utility
            @"SEGEventTypeReset",
            @"SEGEventTypeFlush",
    
            // Remote Notification
            @"SEGEventTypeReceivedRemoteNotification",
            @"SEGEventTypeFailedToRegisterForRemoteNotifications",
            @"SEGEventTypeRegisteredForRemoteNotifications",
            @"SEGEventTypeHandleActionWithForRemoteNotification",
    
            // Application Lifecycle
            @"SEGEventTypeApplicationLifecycle",
    
            // Misc.
            @"SEGEventTypeContinueUserActivity",
            @"SEGEventTypeOpenURL"
         ];
}

@end
