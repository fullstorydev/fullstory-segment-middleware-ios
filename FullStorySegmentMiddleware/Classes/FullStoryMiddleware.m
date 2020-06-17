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
            
            // if it's a NSDictionary: recurrsively get props, and we can not take underscore in key for nested objects, so we simply remove underscores
            // more info: https://help.fullstory.com/hc/en-us/articles/360020623234-FS-Recording-Client-API-Requirements
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [props setValue:[self getSuffixedProps:properties[key]]
                         forKey:[key stringByReplacingOccurrencesOfString:@"_" withString:@""]];
            } else if ([obj isKindOfClass:[NSArray class]]) {
                NSArray *arr = (NSArray *) obj;
                NSDictionary *dict = [self getDictionaryFromArrayObject:arr withKey:key];
                [self appendToDictionary:props withKey:@"" andValue:dict];
            } else {
                // if this is not a dictionary or array, then treat it like simple values, if data falls outside of these, we don't try to infer anything and just send as is to the server
                suffix = [self getSuffixStringFromSimpleObject:obj];
                [self appendToDictionary:props withKey:[key stringByAppendingString:suffix] andValue:properties[key]];
            }
        } else {
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

- (NSString *) getSuffixStringFromSimpleObject:(NSObject *) obj {
    // default to no suffix;
    NSString * suffix = @"";
    if ([obj isKindOfClass:[NSNumber class]]) {
        // defaut to real
        suffix = @"_real";
        NSNumber *n = (NSNumber *) obj;
        const char *type = n.objCType;
        if ([@"i" isEqualToString:@(type)]) {
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
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[self getSuffixedProps:(NSDictionary *) item]];
            [self appendToDictionary:dict withKey:key andValue:tempDict];
        } else if ([item isKindOfClass:[NSArray class]]) {
            // TODO: Segment spec should not allow nested array properties, ignore for now, but we should handle it eventually
            NSDictionary *tempDict = [self getDictionaryFromArrayObject:(NSArray *)item withKey:key];
            [self appendToDictionary:dict withKey:@"" andValue:tempDict];
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
    // when adding a parsed dict into the result dict, emurate and add each object
    for (NSString *k in dict2) {
        NSString *nestedKey;
        if ([key length] > 0) {
            nestedKey = [[key stringByAppendingString:@"."] stringByAppendingString:k];
        } else {
            nestedKey = k;
        }
        [self appendToDictionary:dict withKey:nestedKey andValue:dict2[k]];
    }
}

-(void) appendToDictionary:(NSMutableDictionary *) dict withKey:(NSString *) key andArray:(NSArray *) arr {
    // when adding a parsed array into the result dict, emurate and add each object
    for (id obj in (NSArray *)arr) {
        [self appendToDictionary:dict withKey:key andValue:obj];
    }
}

-(void) appendToDictionary:(NSMutableDictionary *) dict withKey:(NSString *) key andSimpleObject:(NSObject *) obj {
    // obj is simple, add it into the result dict, check if the key with suffix already exsist, if so then we need to append to the result arrays insead of replacing the object.
    // this creates a mutable array each time an object is added, maybe we should consider making arrays mutable in the dict
    // key is already suffixed, we just need to check if it ends with 's' to know if it's plural
    bool isPlural = [key hasSuffix:@"s"];
    NSString *pluralKey = [key stringByAppendingString:@"s"];
    NSString *singularKey = [key substringToIndex:[key length] - 1];
    
    // if there is already a key in singular or plural form in the dict, remove exsisting key and concatnating all values and add a new plural key (flatten the arrays)
    if (isPlural) {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray: dict[key]];
        if(dict[singularKey] != nil) { [arr addObject:dict[singularKey]]; }
        [arr addObject:obj];
        [dict removeObjectForKey:singularKey];
        [dict setObject:arr forKey:key];
    } else if (dict[key] || dict[pluralKey] ) {
        // if key exist but not plural
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:obj, dict[key], nil];
        if(dict[pluralKey] != nil) { [arr addObjectsFromArray:dict[pluralKey]]; }
        [dict removeObjectForKey:key];
        [dict setObject:arr forKey:pluralKey];
    } else {
        [dict setObject:obj forKey:key];
    }
}

-(void) appendToDictionary:(NSMutableDictionary *) dict withKey:(NSString *) key andValue:(NSObject *) obj {
    // umbrella function to handle 3 possible object input, if not a dict or array then we will treat the object as "simple"
    if ([obj isKindOfClass:[NSArray class]]) {
        [self appendToDictionary:dict withKey:key andArray:(NSArray *)obj];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
        [self appendToDictionary:dict withKey:key andDictionary:(NSDictionary *)obj];
    } else {
        [self appendToDictionary:dict withKey:key andSimpleObject:obj];
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
