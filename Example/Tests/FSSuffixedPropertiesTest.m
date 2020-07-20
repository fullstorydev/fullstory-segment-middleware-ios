//
//  FSSuffixedPropertiesTests.m
//  FSSuffixedPropertiesTests
//
//  Created by FullStory on 06/07/2020.
//  Copyright (c) 2020 FullStory. All rights reserved.
//

@import XCTest;
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

- (void)testFSSuffixedPropertiesInit {
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] init];
    NSDictionary* output = [[NSDictionary alloc] init];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testFSSuffixedPropertiesInitWithNilProperties {
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:nil];
    NSDictionary* output = [[NSDictionary alloc] init];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testFSSuffixedPropertiesInitWithProperties {
    NSDictionary* input = [[NSDictionary alloc] initWithObjectsAndKeys:@"value1", @"key1", @1, @"key2", @3.0, @"key3", nil];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [[NSDictionary alloc] initWithObjectsAndKeys:@"value1", @"key1_str", @1, @"key2_int", @3.0, @"key3_real", nil];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

// Segment Ecommerce Events coverage:
- (void)testSegmentSpecECommerceEventProductsSearched {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductsSearched];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductsSearched];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductListViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductListViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductListViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductListFiltered {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductListFiltered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductListFiltered];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventPromotionViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventPromotionViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventPromotionViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}


- (void)testSegmentSpecECommerceEventPromotionClicked {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventPromotionClicked];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventPromotionClicked];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductClicked {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductClicked];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductClicked];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductAdded {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductAdded];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductAdded];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductRemoved {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductRemoved];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductRemoved];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCartViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCartViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCartViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCheckoutStarted {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutStarted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCheckoutStarted];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCheckoutStepViewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutStepViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCheckoutStepViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCheckoutStepCompleted {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutStepCompleted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCheckoutStepCompleted];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCheckoutPaymentInfoEntered {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCheckoutPaymentInfoEntered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCheckoutPaymentInfoEntered];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventOrderUpdated {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderUpdated];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventOrderUpdated];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventOrderCompleted {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderCompleted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventOrderCompleted];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventOrderRefunded {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderRefunded];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventOrderRefunded];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventOrderCancelled {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventOrderCancelled];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventOrderCancelled];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCouponEntered {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponEntered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCouponEntered];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCouponApplied {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponApplied];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCouponApplied];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCouponDenied {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponDenied];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCouponDenied];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCouponRemoved {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCouponRemoved];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCouponRemoved];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductAddedToWishlist {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductAddedToWishlist];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductAddedToWishlist];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductRemovedFromWishlist {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductRemovedFromWishlist];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductRemovedFromWishlist];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventWishlistProductAddedToCart {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventWishlistProductAddedToCart];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventWishlistProductAddedToCart];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductShared {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductShared];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductShared];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventProductReviewed {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventProductReviewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventProductReviewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventCartShared {
    NSDictionary* input = [SegmentSpecFakeData eCommerceEventCartShared];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData eCommerceEventCartShared];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

@end
