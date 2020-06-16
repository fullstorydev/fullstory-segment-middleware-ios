//
//  FullStoryMiddleware.m
//  ios-shoppe-demo
//
//  Created on 5/15/20.
//  Copyright © 2020 FullStory All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGMiddleware.h>
#import "FullStoryMiddleware.h"
#import <FullStory/FullStory.h>

@implementation FullStoryMiddleware

- (id)initWithAllowlistEvents:(NSArray<NSString *> *) allowlistEvents {
     if (self = [super init]) {
         self.enableSendScreenAsEvents = false;
         self.enableGroupTraitsAsUserVars = false;
         self.enableFSSessionURLInEvents = true;
         self.allowlistAllTrackEvents = false;
         self.allowlistEvents = [[NSMutableArray alloc] initWithArray:allowlistEvents];
     }
    return self;
}

- (id)init{
    // Init with no allowlisted events
    return [self initWithAllowlistEvents:nil];
}

- (void)context:(SEGContext * _Nonnull)context next:(SEGMiddlewareNext _Nonnull)next {
    next([context modify:^(id<SEGMutableContext>  _Nonnull ctx) {
        // TODO: add support for Options
        switch(ctx.eventType){
            case SEGEventTypeGroup:{
                SEGGroupPayload *payload = (SEGGroupPayload *) ctx.payload;
                // Create mutable userVars and optionally add the group traits as userVars to be assoicated to the user in FullStory
                NSMutableDictionary *userVars = [[NSMutableDictionary alloc] initWithObjectsAndKeys:payload.groupId,@"groupID", nil];
                if(self.enableGroupTraitsAsUserVars){
                    [userVars addEntriesFromDictionary:payload.traits];
                }
                [FS setUserVars:userVars];
                break;
            }
            case SEGEventTypeIdentify:{
                SEGIdentifyPayload *payload = (SEGIdentifyPayload *) ctx.payload;
                // Segment Identify event, identify the same userID and traits in FullStory
                // if displayName is not set, by default, user email is the displayName
                [FS identify: payload.userId userVars:payload.traits];
                break;
            }
            case SEGEventTypeScreen:{
                SEGScreenPayload *payload = (SEGScreenPayload *) ctx.payload;
                // Segment Screen event, optionally enabled and send as custom events into FullStory
                if(self.enableSendScreenAsEvents){
                    NSString *name = [[NSString alloc] initWithFormat:@"Segment Screen: %@",payload.name];
                    [FS event:name properties:payload.properties];
                }
                break;
            }
            case SEGEventTypeTrack: {
                SEGTrackPayload *payload = (SEGTrackPayload *) ctx.payload;
                // Segment Track event, optionally enabled /w events allowlisted, send as custom events into FullStory
                if(self.allowlistAllTrackEvents || [self.allowlistEvents containsObject:payload.event]){
                    [FS event:payload.event properties:props];
                }
                break;
            }
            case SEGEventTypeReset:{
                // Segment Reset, usually called when user logs out, so anonymize the user in FullStory
                [FS anonymize];
                break;
            }
            default:{}
        }
        
        // Always log the segment event with INFO level to FullStory dev tools
        [FS logWithLevel:FSLOG_INFO format:@"Segment event type: %@", [self getEventName:ctx.eventType]];
        
        // Only override the ctx.payload if:
        // - is Track or Screen event
        // - enabled FS session URL as part of the track/screen event properties
        if(self.enableFSSessionURLInEvents){
            // Create local var: payload, is not nil only when the evnet is Track or Screen
            SEGPayload *payload = [self getNewPayloadWithFSURL:context];
            if(payload != nil) ctx.payload = payload;
        }
    }]);
}

- (SEGPayload *) getNewPayloadWithFSURL:(SEGContext * _Nonnull)context {
    // Return not nil when we find Track and Screen event, and insert FS session URL into event properties
    SEGPayload *newPayload = nil;
    switch (context.eventType) {
        case SEGEventTypeTrack:{
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
        case SEGEventTypeScreen:{
            SEGScreenPayload *screenPayload = (SEGScreenPayload *) context.payload;
            NSMutableDictionary *newProps = [[NSMutableDictionary alloc] initWithDictionary:screenPayload.properties];
            [newProps setValue:[FS currentSessionURL] forKey:@"FSSessionURL"];
            
            newPayload = [[SEGScreenPayload alloc]
                                           initWithName:screenPayload.name
                                           properties:screenPayload.properties
                                           context:screenPayload.context
                                           integrations:screenPayload.integrations];
            break;
        }
        default:
            newPayload = nil;
            break;
    }
    return newPayload;
}


- (NSDictionary *) getSuffixedProps: (NSDictionary *)properties{
    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithDictionary:properties];
    //TODO: Segment does not allow props to have curcular dependency, but we should handle it here anyways
    for(id key in properties){
        // Check Type Encoding: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        const char* typeCode = @encode(typeof([props valueForKey:key]));
        NSLog(@"typeCode for %@ is: %s",key,typeCode);
        NSString *suffix = [[NSString alloc] init];
        
        NSObject *obj = [props valueForKey:key];
        // make sure the value is an object
        if([@"@" isEqualToString:@(typeCode)]){
            [props removeObjectForKey:key];
            // NSDictionary: recurrsively check for types, and we can not take underscore so we just replace them with dashes
            if([obj isKindOfClass:[NSDictionary class]]){
                [props setValue:[self getSuffixedProps:[properties valueForKey:key]]
                         forKey:[key stringByReplacingOccurrencesOfString:@"_" withString:@"-"]];
            }else if ([obj isKindOfClass:[NSArray class]]){
//                // array of objects? array of strings/ints/numbers? yuck!
                NSMutableArray *arr = (NSMutableArray *) obj;
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//
                for (int i = 0; i < [arr count]; i++){
                    NSObject *item = arr[i];
                    // if array of Dictionaries
                    if([item isKindOfClass:[NSDictionary class]]){
                        [dict setObject:[self getSuffixedProps:(NSDictionary *) item]
                                 forKey:[key stringByAppendingFormat:@"%d",i]];
                    }else{
                        suffix = [[self getSuffixStringFromObject:item] stringByAppendingString:@"s"];
                        NSLog(@"Arr suffix is: %@", suffix);
                    }
                }
                [props setValue:arr forKey:[key stringByAppendingString:suffix]];
                [props setValue:dict forKey:[key stringByReplacingOccurrencesOfString:@"_" withString:@"-"]];
            }else{
                suffix = [self getSuffixStringFromObject:obj];
                [props setValue:[properties valueForKey:key] forKey:[key stringByAppendingString:suffix]];
            }
        }else{
            NSLog(@"is not object");
        }
        
        NSLog(@"new props is %@", props);
        
        
        //
        //        // handle premitive types:
        //               if ( NSNotFound != [[NSString stringWithFormat:@"%s", typeCode] rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"{}"]].location ) {
        //                   //this value is struct, do not handle
        //               }
        //               else if ( [@"i" isEqualToString:@(typeCode)] )
        //               {
        //                   //this value is int
        //               }
        //
        //        // do type check if there is underscore
        //               if([key containsString:@"_"]){
        //                   // FS requirements: https://help.fullstory.com/hc/en-us/articles/360020623234-FS-Recording-Client-API-Requirements
        //                   NSLog(@"%@ contains _",key);
        //                   if([[props valueForKey:key] isKindOfClass:[NSString class]]){
        //
        //                   }else if([[props valueForKey:key] isKindOfClass:[NSNumber class]]){
        //                       NSLog(@"%@ is number",key);
        //                   }
        //
        //               }
    }
    
    
    
    
    return props;
}

- (NSString *) getSuffixStringFromObject: (NSObject *) obj{
    // defualt to string
    NSString *suffix = @"_str";
    
    if([obj isKindOfClass:[NSNumber class]]){
        suffix = @"_real";
    }else if([obj isKindOfClass:[NSString class]]){
        suffix = @"_str";
    }else if ([obj isKindOfClass:[NSDate class]]){
        suffix = @"_date";
    }
    return suffix;
}

// get all possible events from Event integer enum: https://segment.com/docs/connections/sources/catalog/libraries/mobile/ios/#usage
- (NSString *) getEventName:(SEGEventType)type {
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

