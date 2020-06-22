//
//  FullStoryMiddleware.m
//  ios-shoppe-demo
//
//  Created on 5/15/20.
//  Copyright © 2020 FullStory All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Analytics/SEGMiddleware.h>
#import <FullStory/FullStory.h>
#import "FullStoryMiddleware.h"
#import "Constants.h"


@implementation FullStoryMiddleware

- (id)initWithAllowlistEvents:(NSArray<NSString *> *)allowlistEvents {
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
    next([context modify:^(id<SEGMutableContext> _Nonnull ctx) {
        // TODO: added support for Options
        switch (ctx.eventType) {
            case SEGEventTypeGroup: {
                SEGGroupPayload *payload = (SEGGroupPayload *) ctx.payload;
                // Create mutable userVars and optionally add the group traits as userVars to be assoicated to the user in FullStory
                NSMutableDictionary *userVars = [[NSMutableDictionary alloc] initWithObjectsAndKeys:payload.groupId,@"groupID", nil];
                if (self.enableGroupTraitsAsUserVars) {
                    [userVars addEntriesFromDictionary:payload.traits];
                }
                [FS setUserVars:userVars];
                break;
            }
            case SEGEventTypeIdentify: {
                SEGIdentifyPayload *payload = (SEGIdentifyPayload *)ctx.payload;
                // Segment Identify event, identify the same userID and traits in FullStory
                // if displayName is not set, by default, user email is the displayName
                [FS identify: payload.userId userVars:payload.traits];
                break;
            }
            case SEGEventTypeScreen: {
                SEGScreenPayload *payload = (SEGScreenPayload *)ctx.payload;
                // Segment Screen event, optionally enabled and send as custom events into FullStory
                if (self.enableSendScreenAsEvents) {
                    NSString *name = [[NSString alloc] initWithFormat:@"Segment Screen: %@",payload.name];
                    [FS event:name properties:payload.properties];
                }
                break;
            }
            case SEGEventTypeTrack: {
                SEGTrackPayload *payload = (SEGTrackPayload *)ctx.payload;

                // transform props to comply with FS custom events requirement
                NSDictionary *props = [self getSuffixedProps:payload.properties];
                NSLog(@"%@",props);
                // Segment Track event, optionally enabled /w events allowlisted, send as custom events into FullStory
                if (self.allowlistAllTrackEvents || [self.allowlistEvents containsObject:payload.event]) {
                    [FS event:payload.event properties:props];
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

// restructure the properties input comply with FS data requirements
// Sample input:
// @{ @"item_name": @"Sword of Heracles",
//    @"revenue": @2.95,
//    @"features": @[@"Slay the Nemean Lion", @"Slay the nine-headed Lernaean Hydra."],
//    @"products": @[
//              @{@"product_id": @"productid_1",@"price": @1.11},
//              @{@"product_id": @"productid_2",@"price": @2.22}
//      ],
//    @"mixed_array": @[@2,@4,@3.5,@"testmix",@[@"arr1", @"arr2"],@{@"objkey":@"objVal"},@4.5,@[@"arr3", @"arr4"]],
//    @"int_array":@[@2,@4,@5,@10],
//    @"bool_test": @true,
//    @"nestedobjs_test":@{@"nestedkey":@"nestedval"},
//    @"coupons_test":@[@{@"discount":@10.5},@{@"freeshipping":@true}]
// }
// Sample output:
// @{ @"item_name_str": @"Sword of Heracles",
//    @"revenue_real": @2.95,
//    @"features_strs": @[@"Slay the Nemean Lion", @"Slay the nine-headed Lernaean Hydra."],
//    @"products.product_id_strs": @[@"Sproductid_2", @"productid_1"],
//    @"products.price_reals": @[@2.22, @1.11],
//    @"mixedArr.objkey_str": @"objVal"
//    @"mixedArr_ints":@[@2,@4]
//    @"mixedArr_reals": @[@3.5, @4.5]
//    @"mixedArr_strs": @[@"testmix", @"arr1", @"arr2", @"arr3", @"arr4"]
//    @"int_array_ints":@[@2,@4,@5,@10],
//    @"bool_test_int": @1,
//    @"nestedobjs_test":@{@"nestedkey":@"nestedval"},
//    @"coupons_test.price_real": @10.5,
//    @"coupons_test.freeshipping_int": @1
// }


- (NSDictionary *)getSuffixedProps:(NSDictionary *)properties {
    // transform props to comply with FS custom events requirement
    // more info: https://help.fullstory.com/hc/en-us/articles/360020623234-FS-Recording-Client-API-Requirements
    //TODO: Segment will crash and not allow props to have curcular dependency/nested or mixed arrays, but we should handle it here anyways
    
    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithCapacity:[properties count]];
    NSMutableArray *stack = [[NSMutableArray alloc] initWithObjects:properties, nil];
    while (stack.count > 0) {
        NSDictionary *dict = [stack objectAtIndex:(stack.count - 1)];
        [stack removeObject:dict];
        for (NSString *key in dict) {
            if ([dict[key] isKindOfClass:[NSDictionary class]]) {
                // nested dicts, concat keys and push back to stack
                for (NSString *k in dict[key]){
                    NSString *concatenatedKey = [key stringByAppendingFormat:@".%@",k];
                    [stack addObject:@{concatenatedKey:dict[key][k]}];
                }
            } else if ([dict[key] isKindOfClass:[NSArray class]]) {
                // To comply with FS requirements, flatten the array of objects into a dictionary:
                // each item in array becomes a dictionary, with this key, and item as value
                // enable search value the array in FS (i.e. searching for one product when array of products are sent)
                // then push each item with the same key back to stack
                for (id item in dict[key]) {
                    [stack addObject:@{key:item}];
                }
            } else {
                // not dict nor array, simply treat as a "primitive" value and send them as-is
                NSString *suffix = [self getSuffixStringFromSimpleObject:dict[key]];
                [self appendToDictionary:props withKey:[key stringByAppendingString:suffix] andSimpleObject:dict[key]];
            }
        }

    }
    [self pluralizeAllArrayKeysInDictionary:props];
    return props;
}

- (NSString *)getSuffixStringFromSimpleObject:(NSObject *)obj {
    // default to no suffix;
    NSString * suffix = @"";
    if ([obj isKindOfClass:[NSNumber class]]) {
        // defaut to real
        suffix = @"_real";
        NSNumber *n = (NSNumber *) obj;
        const char *typeCode = n.objCType;
        if (*typeCode == 'i') {
            suffix = @"_int";
        } else if (*typeCode == 'B') {
            // bool-type gets encoded as number number, and doesn't get encoded into 'B', but check anyway
            suffix = @"_bool";
        }
    } else if ([obj isKindOfClass:[NSDate class]]) {
        suffix = @"_date";
    } else if([obj isKindOfClass:[NSString class]]) {
        // TODO: parse date string properly
        suffix = @"_str";
    }
    return suffix;
}

- (void)appendToDictionary:(NSMutableDictionary *)dict withKey:(NSString *)key andSimpleObject:(NSObject *)obj {
    // add one obj into the result dict, check if the key with suffix already exists, if so append to the result arrays.
    // key is already suffixed and always singular form
    if (dict[key] != nil) {
        // if the same key already exist, check if plural key is already in the dict
        // concatenate array and replace
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:obj, nil];
        if ([dict[key] isKindOfClass:[NSArray class]]) {
            [arr addObjectsFromArray:dict[key]];
        } else {
            [arr addObject:dict[key]];
        }
        [dict setObject:arr forKey:key];
    } else {
        [dict setObject:obj forKey:key];
    }
}

- (void)pluralizeAllArrayKeysInDictionary:(NSMutableDictionary *)dict {
    NSArray *keys = dict.allKeys;
    for (NSString *key in keys) {
        if ([dict[key] isKindOfClass:[NSArray class]]) {
            // all keys should be suffixed and singular
            [dict setValue:dict[key] forKey:[key stringByAppendingString:@"s"]];
            [dict removeObjectForKey:key];
        }
    }
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
