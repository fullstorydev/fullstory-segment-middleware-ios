//
//  FullStoryMiddleware.h
//  FullStoryMiddleware
//
//  Created on 5/15/20.
//  Copyright © 2020 FullStory All rights reserved.
//

#ifndef FullStoryMiddleware_h
#define FullStoryMiddleware_h

#import <Foundation/Foundation.h>
#import <FullStory/FullStory.h>
#if defined(__has_include) && __has_include(<Analytics/SEGAnalytics.h>)
#import <Analytics/SEGAnalytics.h>
#else
@import Segment;
#endif

#if defined(__has_include) && __has_include(<Analytics/SEGMiddleware.h>)
#import <Analytics/SEGMiddleware.h>
#endif

//! Project version number for FullStoryMiddleware.
FOUNDATION_EXPORT double FullStoryMiddlewareVersionNumber;

//! Project version string for FullStoryMiddleware.
FOUNDATION_EXPORT const unsigned char FullStoryMiddlewareVersionString[];


@interface FullStoryMiddleware : NSObject<SEGMiddleware>

@property (strong, nonatomic) NSArray<NSString *>* allowlistEvents;
@property (nonatomic) BOOL enableSendScreenAsEvents;
@property (nonatomic) BOOL enableGroupTraitsAsUserVars;
@property (nonatomic) BOOL enableFSSessionURLInEvents;
@property (nonatomic) BOOL allowlistAllTrackEvents;
@property (nonatomic) BOOL enableIdentifyEvents;

- (id)initWithAllowlistEvents:(NSArray<NSString *> *) allowlistEvents;

@end

#endif /* FullStoryMiddleware_h */
