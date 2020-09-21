//
//  FSSuffixedProperties.m
//  Analytics
//
//  Created on 6/25/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

// FSSuffixedProperties comply with FS data requirements
// Sample input Dictionary:
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
// Sample suffixedProperties:
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

#import <Foundation/Foundation.h>
#import "FSSuffixedProperties.h"

@implementation FSSuffixedProperties

- (id)init {
    // init with empty properteis
    return [self initWithProperties:nil];
}

- (id)initWithProperties:(NSDictionary *)properties {
    // transform properties to comply with FS custom events requirement
    // more info: https://help.fullstory.com/hc/en-us/articles/360020623234-FS-Recording-Client-API-Requirements
    // TODO: Segment does not allow props to have curcular dependency, but we should handle it anyways

    self.suffixedProperties = [[NSMutableDictionary alloc] init];

    // Depth first search to iterate through potentially nested properties
    NSMutableArray *stack = [[NSMutableArray alloc] initWithObjects:properties, nil];
    while (stack.count > 0) {
        NSDictionary *dict = [stack lastObject];
        [stack removeLastObject];
        for (NSString *key in dict) {
            if ([dict[key] isKindOfClass:[NSDictionary class]]) {
                // nested dictionaries, concatenate keys and push back to stack
                for (NSString *k in dict[key]){
                    NSString *concatenatedKey = [key stringByAppendingFormat:@".%@",k];
                    [stack addObject:@{concatenatedKey:dict[key][k]}];
                }
            } else if ([dict[key] isKindOfClass:[NSArray class]]) {
                // To comply with FS requirements, flatten the array of objects into a flat dictionary:
                // each item in array becomes a dictionary, with the same key, and the item itself as value
                // this enables searching values in an array in FS (i.e. searching for one product when array of products are sent)
                // then push each item with the same key back to stack
                for (id item in dict[key]) {
                    [stack addObject:@{key:item}];
                }
            } else {
                // not dictionary nor array, simply treat as a "primitive" value and send them as-is with suffix
                NSString *suffix = [self getSuffixStringFromSimpleObject:dict[key]];
                [self addSimpleObject:dict[key] withKey:[key stringByAppendingString:suffix]];
            }
        }
    }
    // all keys are singular form now in suffixedProperties
    // now pluralize keys (i.e. _str -> _strs) when appropriate
    [self pluralizeAllArrayKeys];

    return self;
}

- (void)addSimpleObject:(NSObject *)obj withKey:(NSString *)key {
    // add obj into suffixedProperties, check if the key already exists, if so convert(or add) to value array.
    // input key is already suffixed and always in singular form
    // if the same key already exist, check if plural key is already in the dict
    if (self.suffixedProperties[key] != nil) {
        // concatenate array and replace
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:obj, nil];
        if ([self.suffixedProperties[key] isKindOfClass:[NSArray class]]) {
            [arr addObjectsFromArray:self.suffixedProperties[key]];
        } else {
            [arr addObject:self.suffixedProperties[key]];
        }
        [self.suffixedProperties setObject:arr forKey:key];
    } else {
        [self.suffixedProperties setObject:obj forKey:key];
    }
}

- (NSString *)getSuffixStringFromSimpleObject:(NSObject *)obj {
    // default to no suffix;
    NSString * suffix = @"";

    if ([obj isKindOfClass:[NSNumber class]]) {
        // defaut to real
        suffix = @"_real";
        NSNumber *n = (NSNumber *) obj;
        const char *typeCode = n.objCType;
        
        if (!strcmp(typeCode, "B") || !strcmp(typeCode, "c")) {
            suffix = @"_bool";
        } else if (!strcmp(typeCode,"i")) {
            suffix = @"_int";
        }
    } else if ([obj isKindOfClass:[NSDate class]]) {
        suffix = @"_date";
    } else if([obj isKindOfClass:[NSString class]]) {
        // TODO: parse date string properly
        suffix = @"_str";
    }
    return suffix;
}

- (void)pluralizeAllArrayKeys {
    NSArray *keys = self.suffixedProperties.allKeys;
    for (NSString *key in keys) {
        if ([self.suffixedProperties[key] isKindOfClass:[NSArray class]]) {
            // all keys should be suffixed and singular
            [self.suffixedProperties setValue:self.suffixedProperties[key] forKey:[key stringByAppendingString:@"s"]];
            [self.suffixedProperties removeObjectForKey:key];
        }
    }
}

@end
