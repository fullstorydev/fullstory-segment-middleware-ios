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
       
    SEGPayload* result = [_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];
    XCTAssertTrue([result isKindOfClass:[SEGTrackPayload class]]);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_TrackPayload_ReturnsTrackPayloadWithFSURL {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    OCMStub([fs currentSessionURL]).andReturn(@"testURL");
    
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];
    SEGTrackPayload* result = (SEGTrackPayload*)[_fullStoryMiddleware getNewPayloadWithFSURL:context];
    SEGTrackPayload *expect = [FullStoryMiddlewareTest getExpectedSEGPayloadWithURL:SEGEventTypeTrack];

    // TODO: better compare equal for differnet payloads,
    // for now just shallow compare the properties one by one
    XCTAssertEqualObjects(expect.context, result.context);
    XCTAssertEqualObjects(expect.integrations, result.integrations);
    XCTAssertEqualObjects(expect.timestamp, result.timestamp);
    XCTAssertEqualObjects(expect.properties, result.properties);
    XCTAssertEqualObjects(expect.event, result.event);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_ScreenPayload_ReturnsScreenPayloadType {
    // create a mock for the SEGContext, we only need eventType from it here
    id segContextMock = OCMClassMock([SEGContext class]);
    OCMStub([segContextMock eventType]).andReturn(SEGEventTypeScreen);
   
    SEGPayload* result = [_fullStoryMiddleware getNewPayloadWithFSURL:segContextMock];
    XCTAssertTrue([result isKindOfClass:[SEGScreenPayload class]]);
}

- (void)testFullStoryMiddleware_GetNewPayloadWithFSURL_ScreenPayload_ReturnsScreenPayloadWithFSURL {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    OCMStub([fs currentSessionURL]).andReturn(@"testURL");
    
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeScreen];
    SEGScreenPayload *result = (SEGScreenPayload*)[_fullStoryMiddleware getNewPayloadWithFSURL:context];
    SEGScreenPayload *expect = [FullStoryMiddlewareTest getExpectedSEGPayloadWithURL:SEGEventTypeScreen];
    
    XCTAssertEqualObjects(expect.context, result.context);
    XCTAssertEqualObjects(expect.integrations, result.integrations);
    XCTAssertEqualObjects(expect.timestamp, result.timestamp);
    XCTAssertEqualObjects(expect.properties, result.properties);
    XCTAssertEqualObjects(expect.name, result.name);
}

- (void)testFullStoryMiddleware_GroupPayload_DisableGroupTraitsAsUserVars_NextBlockCalled {
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeGroup];

    // expect that `next` block is called
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

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeGroup];
    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMVerify([fs setUserVars:@{@"groupID_str": @"groupId"}]);
}

- (void)testFullStoryMiddleware_GroupPayload_EnableGroupTraitsAsUserVars_NextBlockCalled {
    _fullStoryMiddleware.enableGroupTraitsAsUserVars = true;
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeGroup];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_GroupPayload_EnableGroupTraitsAsUserVars_FSSetUserVarsCalledWithGroupId {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    
    _fullStoryMiddleware.enableGroupTraitsAsUserVars = true;

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeGroup];
    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    NSDictionary *userVars = @{@"groupID_str": @"groupId", @"industry_str": @"retail"};
    OCMVerify([fs setUserVars:userVars]);
}

- (void)testFullStoryMiddleware_IdentifyPayload_NoTraits_NextBlockCalled {
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeIdentify];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_IdentifyPayload_UserTraits_FSIdentifyCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeIdentify];

    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMVerify([fs identify: @"testUserId" userVars:@{@"firstName_str": @"test first"}];);
}

- (void)testFullStoryMiddleware_IdentifyPayload_DisableIdentifyEvents_FSIdentifyNotCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeIdentify];

    _fullStoryMiddleware.enableIdentifyEvents = false;
    
    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMReject([fs identify: [OCMArg any] userVars:[OCMArg any]];);
}

- (void)testFullStoryMiddleware_ScreenPayload_EnableSendScreenAsEvents_NextBlockCalled {
    _fullStoryMiddleware.enableSendScreenAsEvents = true;
    _fullStoryMiddleware.enableFSSessionURLInEvents = false;
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeScreen];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_ScreenPayload_EnableSendScreenAsEvents_FSEventCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    
    _fullStoryMiddleware.enableSendScreenAsEvents = true;

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeScreen];

    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMVerify([fs event:@"Segment Screen: testScreen" properties:@{@"prop_str":@"testProp"}];);
}

- (void)testFullStoryMiddleware_ScreenPayload_DisableSendScreenAsEvents_NextBlockCalled {
    _fullStoryMiddleware.enableSendScreenAsEvents = false;
    _fullStoryMiddleware.enableFSSessionURLInEvents = false;
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeScreen];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_ScreenPayload_DisableSendScreenAsEvents_FSEventNotCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    
    _fullStoryMiddleware.enableSendScreenAsEvents = false;

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeScreen];

    OCMReject([fs event:[OCMArg any] properties:[OCMArg any]]);
    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
}

- (void)testFullStoryMiddleware_TrackPayload_DisallowlistAllTrackEvents_NoAllowlistedEvents_NextBlockCalled {
    _fullStoryMiddleware.allowlistAllTrackEvents = false;
    _fullStoryMiddleware.enableFSSessionURLInEvents = false;
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_TrackPayload_DisallowlistAllTrackEvents_NoAllowlistedEvents_FSEventNotCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    
    _fullStoryMiddleware.allowlistAllTrackEvents = false;

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];

    OCMReject([fs event:[OCMArg any] properties:[OCMArg any]]);
    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
}

- (void)testFullStoryMiddleware_TrackPayload_DisallowlistAllTrackEvents_AllowlistedEvents_NextBlockCalled {
    _fullStoryMiddleware.allowlistAllTrackEvents = false;
    _fullStoryMiddleware.enableFSSessionURLInEvents = false;
    _fullStoryMiddleware.allowlistEvents = @[@"testEvent"];
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_TrackPayload_DisallowlistAllTrackEvents_AllowlistedEvents_FSEventCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    
    _fullStoryMiddleware.allowlistAllTrackEvents = false;
    _fullStoryMiddleware.allowlistEvents = @[@"testEvent"];

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];

    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMVerify([fs event:@"testEvent" properties:@{@"prop_str":@"testProp"}]);
}

- (void)testFullStoryMiddleware_TrackPayload_AllowlistAllTrackEvents_NextBlockCalled {
    _fullStoryMiddleware.allowlistAllTrackEvents = true;
    _fullStoryMiddleware.enableFSSessionURLInEvents = false;
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_TrackPayload_AllowlistAllTrackEvents_FSEventCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    
    _fullStoryMiddleware.allowlistAllTrackEvents = true;

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];

    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMVerify([fs event:@"testEvent" properties:@{@"prop_str":@"testProp"}]);
}

- (void)testFullStoryMiddleware_TrackPayload_EnableFSSessionURLInEvents_NextBlockCalled {
    id fs = OCMClassMock([FS class]);
    OCMStub([fs currentSessionURL]).andReturn(@"testURL");
    
    _fullStoryMiddleware.enableFSSessionURLInEvents = true;
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeTrack];
    SEGTrackPayload *expect = [FullStoryMiddlewareTest getExpectedSEGPayloadWithURL:SEGEventTypeTrack];

    // expect that `next` block is called
    XCTestExpectation *expectation = [self expectationWithDescription:@"next block called"];
    
    // assert the context is correct when next block is called
    void(^next)(SEGContext * _Nullable newContext) = ^(SEGContext * _Nullable newContext){
        XCTAssertEqual(newContext.eventType, context.eventType);
        XCTAssertEqual(newContext.userId, context.userId);
        XCTAssertEqual(newContext.anonymousId, context.anonymousId);
        XCTAssertEqual(newContext.debug, context.debug);
        XCTAssertEqualObjects(newContext._analytics, context._analytics);
        XCTAssertEqualObjects(newContext.error, context.error);
        XCTAssertEqualObjects(((SEGTrackPayload*)newContext.payload).properties, expect.properties);
        [expectation fulfill];
    };

    [_fullStoryMiddleware context:context next:next];
    [self waitForExpectations:@[expectation] timeout:10];
}

- (void)testFullStoryMiddleware_ResetPayload_NextBlockCalled {
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeReset];

    // expect that `next` block is called
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

- (void)testFullStoryMiddleware_ResetPayload_AllowlistAllTrackEvents_FSAnonymizeCalled {
    // create a mock for the FS
    id fs = OCMClassMock([FS class]);
    
    _fullStoryMiddleware.allowlistAllTrackEvents = true;

    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeReset];

    [_fullStoryMiddleware context:context next:^(SEGContext * _Nullable newContext){}];
    OCMVerify([fs anonymize]);
}

- (void)testFullStoryMiddleware_AliasPayload_NextBlockCalled {
    SEGContext *context = [FullStoryMiddlewareTest getFakeOriginalSEGContext:SEGEventTypeAlias];

    // expect that `next` block is called
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






// helpers
// generate fake SEGContext including it's payload
+ (SEGContext*)getFakeOriginalSEGContext:(SEGEventType)type {
    NSDictionary *emptyDict = [[NSDictionary alloc] init];
    
    SEGAnalytics *sharedAnalytics = [SEGAnalytics sharedAnalytics];
    
    switch (type) {
        case SEGEventTypeGroup:{
            SEGGroupPayload *groupPayload = [[SEGGroupPayload alloc] initWithGroupId:@"groupId"
                                                                              traits:@{@"industry": @"retail"}
                                                                             context:emptyDict
                                                                        integrations:emptyDict];
            return [[[SEGContext alloc] initWithAnalytics:sharedAnalytics]
                    modify:^(id<SEGMutableContext> _Nonnull ctx) {
                ctx.eventType = SEGEventTypeGroup;
                ctx.payload = groupPayload;
            }];
        }
        case SEGEventTypeScreen: {
            SEGScreenPayload *screenPayload = [[SEGScreenPayload alloc] initWithName:@"testScreen"
                                                                  properties:@{@"prop":@"testProp"}
                                                                     context:emptyDict
                                                                integrations:emptyDict];

            return [[[SEGContext alloc] initWithAnalytics:sharedAnalytics]
                    modify:^(id<SEGMutableContext> _Nonnull ctx) {
                ctx.eventType = SEGEventTypeScreen;
                ctx.payload = screenPayload;
            }];
            
        }
        case SEGEventTypeTrack: {
            SEGTrackPayload *trackPayload = [[SEGTrackPayload alloc] initWithEvent:@"testEvent"
                                                                        properties:@{@"prop":@"testProp"}
                                                                           context:emptyDict
                                                                      integrations:emptyDict];
            return [[[SEGContext alloc] initWithAnalytics:sharedAnalytics]
                    modify:^(id<SEGMutableContext> _Nonnull ctx) {
                ctx.eventType = SEGEventTypeTrack;
                ctx.payload = trackPayload;
            }];
        }
        case SEGEventTypeIdentify: {
            SEGIdentifyPayload *identifyPayload = [[SEGIdentifyPayload alloc] initWithUserId:@"testUserId"
                                                                                 anonymousId:@"randomAnonymousId"
                                                                                      traits:@{@"firstName": @"test first"}
                                                                                     context:emptyDict
                                                                                integrations:emptyDict];
            return [[[SEGContext alloc] initWithAnalytics:sharedAnalytics]
                    modify:^(id<SEGMutableContext> _Nonnull ctx) {
                ctx.eventType = SEGEventTypeIdentify;
                ctx.payload = identifyPayload;
            }];
        }
        case SEGEventTypeAlias: {
            SEGAliasPayload *aliasPayload = [[SEGAliasPayload alloc] initWithNewId:@"newUserId"
                                                                           context:emptyDict
                                                                      integrations:emptyDict];
            return [[[SEGContext alloc] initWithAnalytics:sharedAnalytics]
                    modify:^(id<SEGMutableContext> _Nonnull ctx) {
                ctx.eventType = SEGEventTypeAlias;
                ctx.payload = aliasPayload;
            }];
        }
        case SEGEventTypeReset: {
            SEGPayload *payload = [[SEGPayload alloc] initWithContext:emptyDict
                                                         integrations:emptyDict];
            return [[[SEGContext alloc] initWithAnalytics:sharedAnalytics]
                    modify:^(id<SEGMutableContext> _Nonnull ctx) {
                ctx.eventType = SEGEventTypeReset;
                ctx.payload = payload;
            }];
        }
        default:
            return nil;
    }
}

// helper get expected payload with FSSessionURL inserted
+ (id)getExpectedSEGPayloadWithURL:(SEGEventType)type {
    NSDictionary *emptyDict = [[NSDictionary alloc] init];
    NSDictionary *props = @{
        @"prop":@"testProp",
        @"FSSessionURL": @"testURL"
    };
    
    switch (type) {
        case SEGEventTypeGroup:{

        }
        case SEGEventTypeScreen: {
            return [[SEGScreenPayload alloc] initWithName:@"testScreen"
                                               properties:props
                                                  context:emptyDict
                                             integrations:emptyDict];
        }
        case SEGEventTypeTrack: {
            return [[SEGTrackPayload alloc] initWithEvent:@"testEvent"
                                               properties:props
                                                  context:emptyDict
                                             integrations:emptyDict];
        }
        default:
            return nil;
    }
}
@end
