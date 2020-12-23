//
//  FSSuffixedProperties.h
//  Pods
//
//  Created on 6/25/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

#ifndef FSSuffixedProperties_h
#define FSSuffixedProperties_h

@interface FSSuffixedProperties : NSObject 

@property (strong, nonatomic) NSMutableDictionary* suffixedProperties;

- (id)initWithProperties:(NSDictionary *) properties;

@end

#endif /* FSSuffixedProperties_h */
