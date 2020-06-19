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
        // TODO: add support for Options
        switch (ctx.eventType) {
            case SEGEventTypeGroup: {
                SEGGroupPayload *payload = (SEGGroupPayload *) ctx.payload;
                // Create mutable userVars and optionally add the group traits as userVars to be assoicated to the user in FullStory
                NSMutableDictionary *userVars = [[NSMutableDictionary alloc] initWithObjectsAndKeys:payload.groupId,@"groupID", nil];
                if(self.enableGroupTraitsAsUserVars){
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
    //TODO: Segment will crash and not allow props to have curcular dependency, but we should handle it here anyways
    
    NSMutableDictionary *props = [[NSMutableDictionary alloc] initWithCapacity:[properties count]];
    for (NSString *key in properties) {
        NSString *suffix = @"";

        // properties should always be a NSDictionary, but still check to make sure the value we get is an object
        // where '@' represents an Object
        // Type Encoding: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        const char* typeCode = @encode(typeof(properties[key]));

        if (*typeCode == '@') {
            NSObject *obj = properties[key];
            // if it's a NSDictionary: recurrsively get props, and we can not take underscore in key for nested objects, so we simply remove underscores
            // more info: https://help.fullstory.com/hc/en-us/articles/360020623234-FS-Recording-Client-API-Requirements
            if ([obj isKindOfClass:[NSDictionary class]]) {
                [props setValue:[self getSuffixedProps:properties[key]]
                         forKey:[key stringByReplacingOccurrencesOfString:@"_" withString:@""]];
            } else if ([obj isKindOfClass:[NSArray class]]) {
                NSArray *arr = (NSArray *) obj;
                // Flatten the array of objects into a dictionary: with each key being an array which holds the values from each object for that key
                NSDictionary *dict = [self getDictionaryFromArrayObject:arr withKey:key];
                [self appendToDictionary:props withKey:@"" andValue:dict];
            } else {
                // not a dictionary or array, don't try to infer anything and just send as is to the server
                suffix = [self getSuffixStringFromSimpleObject:obj];
                [self appendToDictionary:props withKey:[key stringByAppendingString:suffix] andValue:obj];
            }
        } else {
            #ifdef DEBUG
                NSAssert(FALSE, @"key `%@` is not an object can't be serialized for FS custom event.", key);
            #else
                NSLog(@"key `%@` is not an object can't be serialized for FS custom event.", key);
                // if prod, then ignore this property all together
            #endif
        }
    }

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
        suffix = @"_str";
    }

    return suffix;
}

- (NSDictionary *)getDictionaryFromArrayObject:(NSArray *)arr withKey:(NSString *)key {
    // To comply with FS requirements, does not accept array of dicts, only "primitive" arrays allowed
    // Convert the root array into a dict, flatten the array, with each possible key from all objects becoming an array of values.
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    for (int i = 0; i < [arr count]; i++) {
        NSObject *item = arr[i];

        if ([item isKindOfClass:[NSDictionary class]]) {
            // Loop through all dicts, flatten out each key/val into arrays,
            // Allows user to search for each key/val in the array in FS (i.e. searching for one product when array of products are sent)
            NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:[self getSuffixedProps:(NSDictionary *) item]];
            [self appendToDictionary:dict withKey:key andValue:tempDict];
        } else if ([item isKindOfClass:[NSArray class]]) {
            // TODO: Segment spec should not allow nested array properties, ignore for now, but we should handle it eventually
            NSDictionary *tempDict = [self getDictionaryFromArrayObject:(NSArray *)item withKey:key];
            [self appendToDictionary:dict withKey:@"" andValue:tempDict];
        } else {
            // default to simple object and parse for suffix
            NSString* suffix = [[self getSuffixStringFromSimpleObject:item] stringByAppendingString:@"s"];
            // get the current array form this specified suffix, if any, then append current item
            NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:[dict valueForKey:[key stringByAppendingString:suffix]]];
            [tempArr addObject:item];
            [dict setValue:tempArr forKey:[key stringByAppendingString:suffix]];
        }
    }

    return dict;
}

- (void)appendToDictionary:(NSMutableDictionary *)dict withKey:(NSString *)key andDictionary:(NSDictionary *)dict2 {
    // when adding a parsed dict into the result dict, enumerate and add each object
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

- (void)appendToDictionary:(NSMutableDictionary *)dict withKey:(NSString *)key andArray:(NSArray *)arr {
    // when adding a parsed array into the result dict, enumerate and add each object
    for (id obj in (NSArray *)arr) {
        [self appendToDictionary:dict withKey:key andValue:obj];
    }
}

- (void)appendToDictionary:(NSMutableDictionary *)dict withKey:(NSString *)key andSimpleObject:(NSObject *)obj {
    // add one obj into the result dict, check if the key with suffix already exsist, if so append to the result arrays.
    // key is already suffixed, we just need to check if it ends with 's' to know if it's plural
    // TODO: un-rely on suffix check to determin if it's already an array or not
    bool isPlural = [key hasSuffix:@"s"];
    NSString *pluralKey = [key stringByAppendingString:@"s"];

    // dict contain either singular or plural form, remove exsisting key, concatnating all values, and add a new key as plural (flatten the array)
    if (isPlural) {
        NSString *singularKey = [key substringToIndex:[key length] - 1];
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray: dict[key]];
        if (dict[singularKey] != nil) {
            [arr addObject:dict[singularKey]];
        }
        [arr addObject:obj];
        [dict removeObjectForKey:singularKey];
        [dict setObject:arr forKey:key];
    } else if (dict[key] || dict[pluralKey] ) {
        // if key exist but not plural
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:obj, dict[key], nil];
        if (dict[pluralKey] != nil) {
            [arr addObjectsFromArray:dict[pluralKey]];
        }
        [dict removeObjectForKey:key];
        [dict setObject:arr forKey:pluralKey];
    } else {
        [dict setObject:obj forKey:key];
    }
}

- (void)appendToDictionary:(NSMutableDictionary *)dict withKey:(NSString *)key andValue:(NSObject *)obj {
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
- (NSString *)getEventName:(SEGEventType)type {
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
