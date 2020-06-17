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
    next ([context modify:^(id<SEGMutableContext>  _Nonnull ctx) {
        // TODO: add support for Options
        switch (ctx.eventType) {
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
                if (self.enableSendScreenAsEvents) {
                    NSString *name = [[NSString alloc] initWithFormat:@"Segment Screen: %@",payload.name];
                    [FS event:name properties:payload.properties];
                }
                break;
            }
            case SEGEventTypeTrack:{
                SEGTrackPayload *payload = (SEGTrackPayload *) ctx.payload;

                // transform props to comply with FS custome events requriement
                NSDictionary *props = [self getSuffixedProps:payload.properties];
                NSLog(@"props final: %@",props);
                // Segment Track event, optionally enabled /w events allowlisted, send as custom events into FullStory
                if (self.allowlistAllTrackEvents || [self.allowlistEvents containsObject:payload.event]) {
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
        if (self.enableFSSessionURLInEvents) {
            // Create local var: payload, is not nil only when the evnet is Track or Screen
            SEGPayload *payload = [self getNewPayloadWithFSURL:context];
            if (payload != nil) ctx.payload = payload;
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


- (NSDictionary *) getSuffixedProps: (NSDictionary *)properties {
    //TODO: Segment will crash and not allow props to have curcular dependency, but we should handle it here anyways
    
    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithCapacity:[properties count]];
    for(NSString *key in properties){
        NSString *suffix = @"";

        // properties should always be a NSDictionary, but still check to make sure the value we get is an object
        // Check Type Encoding: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        const char* typeCode = @encode(typeof(props[key]));

        if ([@"@" isEqualToString:@(typeCode)]) {
            NSObject *obj = properties[key];
            
            // if it's a NSDictionary: recurrsively get props, and we can not take underscore in key for nested objects
            // more info: https://help.fullstory.com/hc/en-us/articles/360020623234-FS-Recording-Client-API-Requirements
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [props setValue:[self getSuffixedProps:properties[key]]
                         forKey:[key stringByReplacingOccurrencesOfString:@"_" withString:@""]];
            } else if ([obj isKindOfClass:[NSArray class]]) {
                // array of dicts? array of strings/ints/numbers? yuck!
                NSArray *arr = (NSArray *) obj;
                NSDictionary *dict = [self getDictionaryFromArrayObject:arr withKey:key];
                [props addEntriesFromDictionary:dict];
            } else {
                // if this is not a dictionary or array, then treat it like simple values, if data falls outside of these, we don't try to infer anything and just send as is to the server
                suffix = [self getSuffixStringFromSimpleObject:obj];
                [self appendToDictionary:props withKey:[key stringByAppendingString:suffix] andValue:properties[key]];
            }
        }else{
            #ifdef DEBUG
                NSAssert(FALSE, @"key `%@` is not an object can't be serialized for FS custom event.", key);
            #else
                NSLog(@"key `%@` is not an object can't be serialized for FS custom event.", key);
                // if prod, then ignore this pops all together
            #endif
        }
    }

    return props;
}

- (NSString *) getSuffixStringFromSimpleObject: (NSObject *) obj {
    // default to no suffix;
    NSString * suffix = @"";
    if ([obj isKindOfClass:[NSNumber class]]) {
        // defaut to real
        suffix = @"_real";
        NSNumber *n = (NSNumber *) obj;
        const char *type = n.objCType;
        if([@"i" isEqualToString:@(type)]) {
            suffix = @"_int";
        } else if ([@"B" isEqualToString:@(type)]) {
            // bool-type gets encoded as number number, and doesn't get encoded into 'B', but check anyway
            suffix = @"_bool";
        }
    } else if ([obj isKindOfClass:[NSDate class]]) {
        suffix = @"_date";
    } else if([obj isKindOfClass:[NSString class]]) {
        suffix = @"_str";
    }

    return suffix;
}

- (NSDictionary *) getDictionaryFromArrayObject:(NSArray *) arr withKey:(NSString *) key {
    // FS does not accept array of dicts, only "premitive" arrays allowed
    // So if it's an array of dicts or nested arrays, then we need to convert the root array to a dict so it becomes nested dicts
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    for (int i = 0; i < [arr count]; i++) {
        NSObject *item = arr[i];
        
        if ([item isKindOfClass:[NSDictionary class]]) {
            // if array of dicts, we then loop through all dicts, flatten out each key/val into arrays, we will loose the object association but it allows user to search for each key/val in the array in FS (i.e. searching for one product when array of products are sent)
//
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[self getSuffixedProps:(NSDictionary *) item]];
            NSLog(@"tempDict: %@, key %@",tempDict, key);
//            [tempDict addEntriesFromDictionary:dict[key]];
//            [dict setObject:tempDict forKey:[key stringByReplacingOccurrencesOfString:@"_" withString:@""]];
            [self appendToDictionary:dict withKey:key andDictionary:tempDict];
            NSLog(@"dict: %@",dict);
        } else if ([item isKindOfClass:[NSArray class]]) {
            // TODO: Segment spec should not allow nested array properties, ignore for now, but we should handle it eventually
            NSDictionary *tempDict = [self getDictionaryFromArrayObject:(NSArray *)item withKey:key];
            [self appendToDictionary:dict withKey:key andDictionary:tempDict];
        } else {
            // default to simple object
            // if there are arrays of mixed type, then in the final props we will add approporate values to the same, key but with each type suffix
            NSString* suffix = [[self getSuffixStringFromSimpleObject:item] stringByAppendingString:@"s"];
            // get the current array form this specified suffix, if any, then append current item
            NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[dict valueForKey:[key stringByAppendingString:suffix]]];
            [tempArr addObject:item];
            [dict setValue:tempArr forKey:[key stringByAppendingString:suffix]];
        }
    }

    return dict;
}

-(void) appendToDictionary:(NSMutableDictionary *) dict withKey:(NSString *) key andDictionary:(NSDictionary *) dict2 {
    // when adding a parsed array into the result dict, check if the key with suffix already exsist, if so then we need to append to the result arrays insead of replacing the object.
    for (NSString *key in dict2) {
        if (dict[key] != nil && [dict[key] isKindOfClass:[NSArray class]]) {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:dict[key]];
            [arr addObjectsFromArray:dict2[key]];
            [dict removeObjectForKey:key];
            [dict setObject:arr forKey:key];
        } else if(dict[key] != nil) {
            // if the current value is not an array already, then delete it and upgrade it to array
            NSArray *arr = [[NSArray alloc]initWithObjects:dict[key], dict2[key], nil];
            [dict removeObjectForKey:key];
            [dict setObject:arr forKey:[key stringByAppendingString:@"s"]];
        } else {
             [dict setObject:dict2[key] forKey:key];
        }
    }
}

-(void) appendToDictionary:(NSMutableDictionary *) dict withKey:(NSString *) key andValue:(NSObject *) obj {
    // when adding a parsed array into the result dict, check if the key with suffix already exsist, if so then we need to append to the result arrays insead of replacing the object.
    if (dict[key] != nil && [dict[key] isKindOfClass:[NSArray class]]) {
        [dict[key] addObject:obj];
    } else if(dict[key] != nil) {
        // if the current value is not an array already, then delete it and upgrade it to array
        NSArray *arr = [[NSArray alloc]initWithObjects:dict[key], obj, nil];
        NSString *suffixedKey = [key stringByAppendingString:@"s"];
        [dict removeObjectForKey:key];
        [self appendToDictionary:dict withKey:suffixedKey andDictionary:@{suffixedKey: arr}];
    } else {
         [dict setObject:obj forKey:key];
    }
}

// get all possible events from Event integer enum: https://segment.com/docs/connections/sources/catalog/libraries/mobile/ios/#usage
- (NSString *) getEventName:(SEGEventType)type {
    NSArray *eventArr = @[
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
