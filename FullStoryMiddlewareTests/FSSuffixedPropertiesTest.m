//
//  FSSuffixedPropertiesTests.m
//  FSSuffixedPropertiesTests
//
//  Created by FullStory on 06/07/2020.
//  Copyright (c) 2020 FullStory. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FSSuffixedProperties.h"
#import "SegmentSpecFakeData.h"
#import "FSPropertiesFakeData.h"

@interface FSSuffixedPropertiesTest : XCTestCase

@property (strong, nonatomic) FSSuffixedProperties* fsSuffixedProperties;

@end

@implementation FSSuffixedPropertiesTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFSSuffixedPropertiesInitWithNilProperties {
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:nil];
    NSDictionary* expect = [[NSDictionary alloc] init];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testFSSuffixedPropertiesInit {
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] init];
    NSDictionary* expect = [[NSDictionary alloc] init];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testFSSuffixedPropertiesInitWithProperties {
    NSDictionary* input = @{
        @"key1": @"value1",
        @"key2": @5,
        @"key3": @3.0,
        @"key4": @YES
    };
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = @{
        @"key1_str": @"value1",
        @"key2_int": @5,
        @"key3_real": @3.0,
        @"key4_bool": @YES
    };
    
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

// Segment Ecommerce Events coverage:
- (void)testSegmentSpecECommerceEventProductsSearched {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductsSearched];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductsSearched];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductListViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductListViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductListViewed];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductListFiltered {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductListFiltered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductListFiltered];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventPromotionViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventPromotionViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventPromotionViewed];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}


- (void)testSegmentSpecECommerceEventPromotionClicked {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventPromotionClicked];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventPromotionClicked];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductClicked {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductClicked];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductClicked];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductViewed];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductAdded {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductAdded];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductAdded];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductRemoved {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductRemoved];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductRemoved];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCartViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCartViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCartViewed];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCheckoutStarted {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutStarted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCheckoutStarted];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCheckoutStepViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutStepViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCheckoutStepViewed];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCheckoutStepCompleted {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutStepCompleted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCheckoutStepCompleted];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCheckoutPaymentInfoEntered {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutPaymentInfoEntered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCheckoutPaymentInfoEntered];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventOrderUpdated {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderUpdated];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventOrderUpdated];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventOrderCompleted {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderCompleted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventOrderCompleted];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventOrderRefunded {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderRefunded];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventOrderRefunded];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventOrderCancelled {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderCancelled];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventOrderCancelled];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCouponEntered {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponEntered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCouponEntered];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCouponApplied {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponApplied];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCouponApplied];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCouponDenied {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponDenied];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCouponDenied];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCouponRemoved {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponRemoved];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCouponRemoved];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductAddedToWishlist {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductAddedToWishlist];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductAddedToWishlist];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductRemovedFromWishlist {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductRemovedFromWishlist];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductRemovedFromWishlist];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventWishlistProductAddedToCart {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventWishlistProductAddedToCart];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventWishlistProductAddedToCart];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductShared {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductShared];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductShared];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventProductReviewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductReviewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventProductReviewed];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

- (void)testSegmentSpecECommerceEventCartShared {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCartShared];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* expect = [FSPropertiesFakeData eCommerceEventCartShared];
    XCTAssertEqualObjects(expect, _fsSuffixedProperties.suffixedProperties);
}

@end
