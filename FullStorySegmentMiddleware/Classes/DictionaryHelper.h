//
//  DictionaryHelper.h
//  Pods
//
//  Created on 6/25/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

#ifndef DictionaryHelper_h
#define DictionaryHelper_h

@interface DictionaryHelper

+ (void)appendToDictionary:(NSMutableDictionary *)dict withKey:(NSString *)key andSimpleObject:(NSObject *)obj;
+ (void)pluralizeAllArrayKeysInDictionary:(NSMutableDictionary *)dict;

@end

#endif /* DictionaryHelper_h */
