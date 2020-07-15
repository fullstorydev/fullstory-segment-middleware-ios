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

- (void)testSegmentSpecECommerceEventsProductsSearched {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductsSearched];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductsSearched];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductListViewed {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductListViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductListViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductListFiltered {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductListFiltered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductListFiltered];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsPromotionViewed {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsPromotionViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsPromotionViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}


- (void)testSegmentSpecECommerceEventsPromotionClicked {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsPromotionClicked];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsPromotionClicked];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductClicked {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductClicked];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductClicked];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductViewed {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductAdded {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductAdded];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductAdded];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductRemoved {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductRemoved];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductRemoved];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCartViewed {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCartViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCartViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCheckoutStarted {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCheckoutStarted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCheckoutStarted];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCheckoutStepViewed {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCheckoutStepViewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCheckoutStepViewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCheckoutStepCompleted {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCheckoutStepCompleted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCheckoutStepCompleted];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCheckoutPaymentInfoEntered {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCheckoutPaymentInfoEntered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCheckoutPaymentInfoEntered];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsOrderUpdated {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsOrderUpdated];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsOrderUpdated];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsOrderCompleted {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsOrderCompleted];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsOrderCompleted];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsOrderRefunded {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsOrderRefunded];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsOrderRefunded];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsOrderCancelled {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsOrderCancelled];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsOrderCancelled];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCouponEntered {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCouponEntered];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCouponEntered];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCouponApplied {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCouponApplied];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCouponApplied];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCouponDenied {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCouponDenied];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCouponDenied];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCouponRemoved {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCouponRemoved];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCouponRemoved];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductAddedToWishlist {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductAddedToWishlist];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductAddedToWishlist];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductRemovedFromWishlist {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductRemovedFromWishlist];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductRemovedFromWishlist];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsWishlistProductAddedToCart {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsWishlistProductAddedToCart];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsWishlistProductAddedToCart];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductShared {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductShared];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductShared];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsProductReviewed {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsProductReviewed];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsProductReviewed];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

- (void)testSegmentSpecECommerceEventsCartShared {
    NSDictionary* input = [SegmentSpecFakeData ECommerceEventsCartShared];
    _fsSuffixedProperties = [[FSSuffixedProperties alloc] initWithProperties:input];
    NSDictionary* output = [FSPropertiesFakeData ECommerceEventsCartShared];
    XCTAssertEqualObjects(_fsSuffixedProperties.suffixedProperties, output);
}

@end
