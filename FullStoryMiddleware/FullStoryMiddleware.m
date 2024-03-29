//
//  FullStoryMiddleware.m
//  ios-shoppe-demo
//
//  Created on 5/15/20.
//  Copyright © 2020 FullStory All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FullStoryMiddleware.h"
#import "FSSuffixedProperties.h"


// private SEGScreenPayload to provide the signitures to check for during respondsToSelector:@selector
// this is due to a signiture change between Analytics 3 and 4.
// We workaround it by checking if the init response to either of these below
@interface SEGScreenPayload()
- (instancetype)initWithName:(NSString *)name
                  properties:(NSDictionary *)properties
                     context:(NSDictionary *)context
                integrations:(NSDictionary *)integrations;

- (instancetype)initWithName:(NSString *)name
                    category:(NSString *)category
                  properties:(NSDictionary *_Nullable)properties
                     context:(NSDictionary *)context
                integrations:(NSDictionary *)integrations;
@end

@implementation FullStoryMiddleware

- (id)initWithAllowlistEvents:(NSArray<NSString *> *)allowlistEvents {
     if (self = [super init]) {
         self.enableSendScreenAsEvents = false;
         self.enableGroupTraitsAsUserVars = false;
         self.enableFSSessionURLInEvents = true;
         self.allowlistAllTrackEvents = false;
         self.allowlistEvents = [[NSMutableArray alloc] initWithArray:allowlistEvents];
         self.enableIdentifyEvents = YES;
     }
    return self;
}

- (id)init{
    // Init with no allowlisted events
    return [self initWithAllowlistEvents:nil];
}

- (void)context:(SEGContext * _Nonnull)context next:(SEGMiddlewareNext _Nonnull)next {
    next([context modify:^(id<SEGMutableContext> _Nonnull ctx) {
        // TODO: add support for Options
        switch (ctx.eventType) {
            case SEGEventTypeGroup: {
                SEGGroupPayload *payload = (SEGGroupPayload *) ctx.payload;
                // Create mutable userVars and optionally add the group traits as userVars to be assoicated to the user in FullStory
                NSMutableDictionary *userVars = [[NSMutableDictionary alloc] initWithObjectsAndKeys:payload.groupId,@"groupID_str", nil];
                if (self.enableGroupTraitsAsUserVars) {
                    FSSuffixedProperties *traits = [[FSSuffixedProperties alloc] initWithProperties:payload.traits];
                    [userVars addEntriesFromDictionary:traits.suffixedProperties];
                }
                [FS setUserVars:userVars];
                break;
            }
            case SEGEventTypeIdentify: {
                SEGIdentifyPayload *payload = (SEGIdentifyPayload *)ctx.payload;
                // Segment Identify event, identify the same userID and traits in FullStory
                // if displayName is not set, by default, user email is the displayName
                // optionally disabled with enableIdentifyEvents
                if (self.enableIdentifyEvents) {
                  FSSuffixedProperties *traits = [[FSSuffixedProperties alloc] initWithProperties:payload.traits];
                  [FS identify:payload.userId userVars:traits.suffixedProperties];
                }
                break;
            }
            case SEGEventTypeScreen: {
                SEGScreenPayload *payload = (SEGScreenPayload *)ctx.payload;
                // Segment Screen event, optionally enabled and send as custom events into FullStory
                if (self.enableSendScreenAsEvents) {
                    NSString *name = [[NSString alloc] initWithFormat:@"Segment Screen: %@",payload.name];
                    FSSuffixedProperties *fsProps = [[FSSuffixedProperties alloc] initWithProperties:payload.properties];
                    [FS event:name properties:fsProps.suffixedProperties];
                }
                break;
            }
            case SEGEventTypeTrack: {
                SEGTrackPayload *payload = (SEGTrackPayload *)ctx.payload;
                // Segment Track event, optionally enabled /w events allowlisted, send as custom events into FullStory
                if (self.allowlistAllTrackEvents || [self.allowlistEvents containsObject:payload.event]) {
                    // transform props to comply with FS custom events requirement
                    FSSuffixedProperties *fsProps = [[FSSuffixedProperties alloc] initWithProperties:payload.properties];
                    [FS event:payload.event properties:fsProps.suffixedProperties];
                }
                break;
            }
            case SEGEventTypeReset: {
                // Segment Reset, usually called when user logs out, so anonymize the user in FullStory
                [FS anonymize];
                break;
            }
            default: break;
        }

        // Always log the segment event with INFO level to FullStory dev tools
        [FS logWithLevel:FSLOG_INFO format:@"Segment event type: %@", [self getEventName:ctx.eventType]];

        // Only override the ctx.payload to insert the current FullStory session URL if:
        // - it is Track or Screen event
        // - enableFSSessionURLInEvents is YES to enable FS session URL as part of the track/screen event properties
        // if enabled you will recieve at your destination events with FS URL added as part of the event properties
        if (self.enableFSSessionURLInEvents) {
            // Create local var: payload, is not nil only when the evnet is Track or Screen
            SEGPayload *payload = [self getNewPayloadWithFSURL:context];
            if (payload != nil) ctx.payload = payload;
        }
    }]);
}

- (SEGPayload *)getNewPayloadWithFSURL:(SEGContext * _Nonnull)context {
    // Return not nil when we find Track and Screen event, and insert FS session URL into event properties
    SEGPayload *newPayload = nil;
    switch (context.eventType) {
        case SEGEventTypeTrack: {
            SEGTrackPayload *trackPayload = (SEGTrackPayload *) context.payload;
            NSMutableDictionary *newProps = [[NSMutableDictionary alloc] initWithDictionary:trackPayload.properties];
            [newProps setValue:[FS currentSessionURL] forKey:@"FSSessionURL"];

            newPayload = [[SEGTrackPayload alloc]
                                           initWithEvent:trackPayload.event
                                           properties:newProps
                                           context:trackPayload.context
                                           integrations:trackPayload.integrations];
            break;
        }
        case SEGEventTypeScreen: {
            SEGScreenPayload *screenPayload = (SEGScreenPayload *) context.payload;
            NSMutableDictionary *newProps = [[NSMutableDictionary alloc] initWithDictionary:screenPayload.properties];
            [newProps setValue:[FS currentSessionURL] forKey:@"FSSessionURL"];

            {
                SEGScreenPayload *uninitPayload = [SEGScreenPayload alloc];

                // init has a different signiture for Analytics version < 4
                if ([uninitPayload respondsToSelector:@selector(initWithName:properties:context:integrations:)]) {
                    newPayload = [uninitPayload
                                  initWithName:screenPayload.name
                                  properties:newProps
                                  context:screenPayload.context
                                  integrations:screenPayload.integrations];
                } else if ([uninitPayload respondsToSelector:@selector(initWithName:category:properties:context:integrations:)]) {
                    newPayload = [uninitPayload
                                  initWithName:screenPayload.name
                                  category:screenPayload.category
                                  properties:newProps
                                  context:screenPayload.context
                                  integrations:screenPayload.integrations];
                } else {
                    // if not responding to either, return nil so we abort and pass the original paylaod back
                    newPayload = nil;
                }
            }
            break;
        }
        default:
            newPayload = nil;
            break;
    }
    return newPayload;
}

- (NSString *)getEventName:(SEGEventType)type {
    NSArray *eventArr =@[
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
    return eventArr[type];
}

@end
