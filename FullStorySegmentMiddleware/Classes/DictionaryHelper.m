//
//  DictionaryHelper.m
//  Analytics
//
//  Created on 6/25/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DictionaryHelper.h"

@implementation DictionaryHelper

+ (void)appendToDictionary:(NSMutableDictionary *)dict withKey:(NSString *)key andSimpleObject:(NSObject *)obj {
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

+ (void)pluralizeAllArrayKeysInDictionary:(NSMutableDictionary *)dict {
    NSArray *keys = dict.allKeys;
    for (NSString *key in keys) {
        if ([dict[key] isKindOfClass:[NSArray class]]) {
            // all keys should be suffixed and singular
            [dict setValue:dict[key] forKey:[key stringByAppendingString:@"s"]];
            [dict removeObjectForKey:key];
        }
    }
}

@end
