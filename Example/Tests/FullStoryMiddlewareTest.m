//
//  FullStoryMiddlewareTest.m
//  FullStorySegmentMiddleware_Example
//
//  Created by FullStory on 7/20/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <Analytics/SEGAnalytics.h>
#import <FullStory/FullStory.h>
#import <OCMock/OCMock.h>
#import "FullStoryMiddleware.h"


@interface FullStoryMiddlewareTest : XCTestCase

@property (strong, nonatomic) FullStoryMiddleware* fullStoryMiddleware;

@end

// interface for testing private methods
@interface FullStoryMiddleware (Testing)

- (SEGPayload *)getNewPayloadWithFSURL:(SEGContext * _Nonnull)context;

@end

@implementation FullStoryMiddlewareTest

- (void)setUp {
    [super setUp];
    
    SEGAnalyticsConfiguration *configuration = [SEGAnalyticsConfiguration configurationWithWriteKey:@"write_key"];
    [SEGAnalytics setupWithConfiguration:configuration];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFullStoryMiddlewareInit {
    _fullStoryMiddleware = [[FullStoryMiddleware alloc] init];
    XCTAssertTrue(_fullStoryMiddleware.enableFSSessionURLInEvents);
    XCTAssertFalse(_fullStoryMiddleware.enableSendScreenAsEvents);
    XCTAssertFalse(_fullStoryMiddleware.enableGroupTraitsAsUserVars);
    XCTAssertFalse(_fullStoryMiddleware.allowlistAllTrackEvents);
    XCTAssertEqualObjects(_fullStoryMiddleware.allowlistEvents, @[]);
}

- (void)testFullStoryMiddlewareInitWithAllowlistEvents {
    _fullStoryMiddleware = [[FullStoryMiddleware alloc] initWithAllowlistEvents:@[@"Product Added"]];
    XCTAssertTrue(_fullStoryMiddleware.enableFSSessionURLInEvents);
    XCTAssertFalse(_fullStoryMiddleware.enableSendScreenAsEvents);
    XCTAssertFalse(_fullStoryMiddleware.enableGroupTraitsAsUserVars);
    XCTAssertFalse(_fullStoryMiddleware.allowlistAllTrackEvents);
    XCTAssertEqualObjects(_fullStoryMiddleware.allowlistEvents, @[@"Product Added"]);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_TrackPayloadReturnsTrackPayload {
    _fullStoryMiddleware = [[FullStoryMiddleware alloc] init];

    // create a mock for the SEGContext
    id segContextMock = OCMClassMock([SEGContext class]);
    OCMStub([segContextMock eventType]).andReturn(SEGEventTypeTrack);
       
    SEGPayload* output = [_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];
    XCTAssertTrue([output isKindOfClass:[SEGTrackPayload class]]);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_TrackPayloadReturnsTrackPayloadWithFSURL {
    _fullStoryMiddleware = [[FullStoryMiddleware alloc] init];
    NSDictionary* emptyDict = [[NSDictionary alloc] init];
    SEGTrackPayload* trackPayload = [[SEGTrackPayload alloc] initWithEvent:@"testEvent"
                                                          properties:emptyDict
                                                             context:emptyDict
                                                        integrations:emptyDict];
    SEGTrackPayload* expect = [[SEGTrackPayload alloc] initWithEvent:@"testEvent"
                                                          properties:@{@"FSSessionURL": @"testURL"}
                                                             context:emptyDict
                                                        integrations:emptyDict];

    // create a mock for the SEGContext
    id segContextMock = OCMClassMock([SEGContext class]);
    OCMStub([segContextMock eventType]).andReturn(SEGEventTypeTrack);
    OCMStub([segContextMock payload]).andReturn(trackPayload);
    
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    OCMStub([fs currentSessionURL]).andReturn(@"testURL");
    
    SEGTrackPayload* output = (SEGTrackPayload*)[_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];

    XCTAssertEqualObjects(expect.context, output.context);
    XCTAssertEqualObjects(expect.properties, output.properties);
    XCTAssertEqualObjects(expect.integrations, output.integrations);
    XCTAssertEqualObjects(expect.event, output.event);
    XCTAssertEqualObjects(expect.timestamp, output.timestamp);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_ScreenPayload_ReturnsScreenPayload {
    _fullStoryMiddleware = [[FullStoryMiddleware alloc] init];

    // create a mock for the SEGContext
    id segContextMock = OCMClassMock([SEGContext class]);
    OCMStub([segContextMock eventType]).andReturn(SEGEventTypeScreen);
       
    SEGPayload* output = [_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];
    XCTAssertTrue([output isKindOfClass:[SEGScreenPayload class]]);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_ScreenPayload_ReturnsScreenPayloadWithFSURL {
    _fullStoryMiddleware = [[FullStoryMiddleware alloc] init];
    NSDictionary* emptyDict = [[NSDictionary alloc] init];
    SEGScreenPayload* screenPayload = [[SEGScreenPayload alloc] initWithName:@"testScreen"
                                                          properties:emptyDict
                                                             context:emptyDict
                                                        integrations:emptyDict];
    SEGScreenPayload* expect = [[SEGScreenPayload alloc] initWithName:@"testScreen"
                                                          properties:@{@"FSSessionURL": @"testURL"}
                                                             context:emptyDict
                                                        integrations:emptyDict];

    // create a mock for the SEGContext
    id segContextMock = OCMClassMock([SEGContext class]);
    OCMStub([segContextMock eventType]).andReturn(SEGEventTypeScreen);
    OCMStub([segContextMock payload]).andReturn(screenPayload);
    
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    OCMStub([fs currentSessionURL]).andReturn(@"testURL");
    
    SEGScreenPayload* output = (SEGScreenPayload*)[_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];

    XCTAssertEqualObjects(expect.context, output.context);
    XCTAssertEqualObjects(expect.properties, output.properties);
    XCTAssertEqualObjects(expect.integrations, output.integrations);
    XCTAssertEqualObjects(expect.name, output.name);
    XCTAssertEqualObjects(expect.timestamp, output.timestamp);
}


@end
