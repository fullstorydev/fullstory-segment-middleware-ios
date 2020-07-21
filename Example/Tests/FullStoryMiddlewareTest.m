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
    
    _fullStoryMiddleware = [[FullStoryMiddleware alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFullStoryMiddlewareInit {
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

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_TrackPayload_ReturnsTrackPayloadType {
    // create a mock for the SEGContext, we only need eventType from it here
    id segContextMock = OCMClassMock([SEGContext class]);
    OCMStub([segContextMock eventType]).andReturn(SEGEventTypeTrack);
       
    SEGPayload* output = [_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];
    XCTAssertTrue([output isKindOfClass:[SEGTrackPayload class]]);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_TrackPayload_ReturnsTrackPayloadWithFSURL {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    OCMStub([fs currentSessionURL]).andReturn(@"testURL");

    NSDictionary* emptyDict = [[NSDictionary alloc] init];
    SEGTrackPayload* trackPayload = [[SEGTrackPayload alloc] initWithEvent:@"testEvent"
                                                          properties:emptyDict
                                                             context:emptyDict
                                                        integrations:emptyDict];
    SEGTrackPayload* expect = [[SEGTrackPayload alloc] initWithEvent:@"testEvent"
                                                          properties:@{@"FSSessionURL": @"testURL"}
                                                             context:emptyDict
                                                        integrations:emptyDict];
    SEGContext *context = [[[SEGContext alloc] initWithAnalytics:[SEGAnalytics sharedAnalytics]] modify:^(id<SEGMutableContext> _Nonnull ctx) {
        ctx.eventType = SEGEventTypeTrack;
        ctx.payload = trackPayload;
    }];
    
    SEGTrackPayload* output = (SEGTrackPayload*)[_fullStoryMiddleware getNewPayloadWithFSURL:context];

    XCTAssertEqualObjects(expect.context, output.context);
    XCTAssertEqualObjects(expect.properties, output.properties);
    XCTAssertEqualObjects(expect.integrations, output.integrations);
    XCTAssertEqualObjects(expect.event, output.event);
    XCTAssertEqualObjects(expect.timestamp, output.timestamp);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_ScreenPayload_ReturnsScreenPayloadType {
    // create a mock for the SEGContext, we only need eventType from it here
    id segContextMock = OCMClassMock([SEGContext class]);
    OCMStub([segContextMock eventType]).andReturn(SEGEventTypeScreen);
   
    SEGPayload* output = [_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];
    XCTAssertTrue([output isKindOfClass:[SEGScreenPayload class]]);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_ScreenPayload_ReturnsScreenPayloadWithFSURL {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    OCMStub([fs currentSessionURL]).andReturn(@"testURL");

    NSDictionary* emptyDict = [[NSDictionary alloc] init];
    SEGScreenPayload* screenPayload = [[SEGScreenPayload alloc] initWithName:@"testScreen"
                                                          properties:emptyDict
                                                             context:emptyDict
                                                        integrations:emptyDict];
    SEGScreenPayload* expect = [[SEGScreenPayload alloc] initWithName:@"testScreen"
                                                          properties:@{@"FSSessionURL": @"testURL"}
                                                             context:emptyDict
                                                        integrations:emptyDict];
    SEGContext *context = [[[SEGContext alloc] initWithAnalytics:[SEGAnalytics sharedAnalytics]] modify:^(id<SEGMutableContext> _Nonnull ctx) {
        ctx.eventType = SEGEventTypeScreen;
        ctx.payload = screenPayload;
    }];
    
    SEGScreenPayload* output = (SEGScreenPayload*)[_fullStoryMiddleware getNewPayloadWithFSURL:context];

    XCTAssertEqualObjects(expect.context, output.context);
    XCTAssertEqualObjects(expect.properties, output.properties);
    XCTAssertEqualObjects(expect.integrations, output.integrations);
    XCTAssertEqualObjects(expect.name, output.name);
    XCTAssertEqualObjects(expect.timestamp, output.timestamp);
}

- (void)testFullStoryMiddleware_GroupPayload_DisableGroupTraitsAsUserVars_NextBlockCalled {
    SEGGroupPayload *groupPayload = [[SEGGroupPayload alloc] initWithGroupId:@"groupId"
                                                            traits:[[NSDictionary alloc]init]
                                                           context:[[NSDictionary alloc]init]
                                                      integrations:[[NSDictionary alloc]init]];
    SEGContext *context = [[[SEGContext alloc] initWithAnalytics:[SEGAnalytics sharedAnalytics]] modify:^(id<SEGMutableContext> _Nonnull ctx) {
        ctx.eventType = SEGEventTypeGroup;
        ctx.payload = groupPayload;
    }];

    // expect the next block is called
    XCTestExpectation *expectation = [self expectationWithDescription:@"next block called"];
    
    // assert the context is correct when next block is called
    void(^next)(SEGContext * _Nullable newContext) = ^(SEGContext * _Nullable newContext){
        XCTAssertEqual(newContext.eventType, context.eventType);
        XCTAssertEqual(newContext.userId, context.userId);
        XCTAssertEqual(newContext.anonymousId, context.anonymousId);
        XCTAssertEqual(newContext.debug, context.debug);
        XCTAssertEqualObjects(newContext._analytics, context._analytics);
        XCTAssertEqualObjects(newContext.error, context.error);
        XCTAssertEqualObjects(newContext.payload, context.payload);
        [expectation fulfill];
    };

    [_fullStoryMiddleware context:context next:next];
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testFullStoryMiddleware_GroupPayload_DisableGroupTraitsAsUserVars_FSSetUserVarsCalledWithGroupId {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);

    SEGGroupPayload *groupPayload = [[SEGGroupPayload alloc] initWithGroupId:@"groupId"
                                                            traits:[[NSDictionary alloc]init]
                                                           context:[[NSDictionary alloc]init]
                                                      integrations:[[NSDictionary alloc]init]];
    SEGContext *context = [[[SEGContext alloc] initWithAnalytics:[SEGAnalytics sharedAnalytics]] modify:^(id<SEGMutableContext> _Nonnull ctx) {
        ctx.eventType = SEGEventTypeGroup;
        ctx.payload = groupPayload;
    }];

    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMVerify([fs setUserVars:@{@"groupID": @"groupId"}]);
}

@end
