//
//  SegmentSpecFakeData.m
//  FullStorySegmentMiddleware_Example
//
//  Created by FullStory on 7/14/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

// SegmentSpecFakeData contains mock data for all events' properties, according to Segment ecommerce spec defined here:
// https://segment.com/docs/connections/spec/ecommerce/v2/

#import <Foundation/Foundation.h>
#import "SegmentSpecFakeData.h"

@implementation SegmentSpecFakeData

+ (NSDictionary*)eCommerceEventProductsSearched {
    return @{
        @"query": @"blue roses"
    };
}

+ (NSDictionary*)eCommerceEventProductListViewed {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"list_id"] = @"hot_deals_1";
    dict[@"category"] = @"Deals";
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)eCommerceEventProductListFiltered {
    return @{
        @"list_id": @"todays_deals_may_11_2019",
        @"filters": @[
                @{
                    @"type": @"department",
                    @"value": @"beauty",
                },
                @{
                    @"type": @"price",
                    @"value": @"under-$25",
                }
        ],
        @"sorts": @[
                @{
                    @"type": @"price",
                    @"value": @"desc",
                }
        ],
        @"products": @[
                @{
                    @"product_id": @"507f1f77bcf86cd798439011",
                    @"sku": @"45360-32",
                    @"name": @"Special Facial Soap",
                    @"price": @12.60,
                    @"position": @1,
                    @"category": @"Beauty",
                    @"url": @"https://www.example.com/product/path",
                    @"image_url": @"https://www.example.com/product/path.jpg",
                },
                @{
                    @"product_id": @"505bd76785ebb509fc283733",
                    @"sku": @"46573-32",
                    @"name": @"Fancy Hairbrush",
                    @"price": @7.60,
                    @"position": @2,
                    @"category": @"Beauty",
                }
        ]
    };
}

+ (NSDictionary*)eCommerceEventPromotionViewed {
    return @{
        @"promotion_id": @"promo_1",
        @"creative": @"top_banner_2",
        @"name": @"75% store-wide shoe sale",
        @"position": @"home_banner_top"
    };
}

+ (NSDictionary*)eCommerceEventPromotionClicked {
    return @{
        @"promotion_id": @"promo_1",
        @"creative": @"top_banner_2",
        @"name": @"75% store-wide shoe sale",
        @"position": @"home_banner_top"
    };
}

+ (NSDictionary*)eCommerceEventProductClicked {
    return [SegmentSpecFakeData getMonopolyProduct];
}

+ (NSDictionary*)eCommerceEventProductViewed {
    NSDictionary *tempDict = @{
        @"currency": @"usd",
        @"value": @18.99,
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)eCommerceEventProductAdded {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cart_id"] = @"skdjsidjsdkdj29j";
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)eCommerceEventProductRemoved {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cart_id"] = @"skdjsidjsdkdj29j";
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)eCommerceEventCartViewed {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cart_id"] = @"skdjsidjsdkdj29j";
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)eCommerceEventCheckoutStarted {
    NSDictionary *tempDict = @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"affiliation": @"Google Store",
        @"value": @30,
        @"revenue": @25.00,
        @"shipping": @3,
        @"tax": @2,
        @"discount": @2.5,
        @"coupon": @"hasbros",
        @"currency": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)eCommerceEventCheckoutStepViewed {
    return @{
        @"checkout_id": @"50314b8e9bcf000000000000",
        @"step": @2,
        @"shipping_method": @"Fedex",
        @"payment_method": @"Visa",
    };
}

+ (NSDictionary*)eCommerceEventCheckoutStepCompleted {
    return @{
        @"checkout_id": @"50314b8e9bcf000000000000",
        @"step": @2,
        @"shipping_method": @"Fedex",
        @"payment_method": @"Visa",
    };
}

+ (NSDictionary*)eCommerceEventCheckoutPaymentInfoEntered {
    return @{
        @"checkout_id": @"39f39fj39f3jf93fj9fj39fj3f",
        @"order_id": @"dkfsjidfjsdifsdfksdjfkdsfjsdfkdsf"
    };
}

+ (NSDictionary*)eCommerceEventOrderUpdated {
    NSDictionary *tempDict = @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"affiliation": @"Google Store",
        @"total": @27.50,
        @"revenue": @25.00,
        @"shipping": @3,
        @"tax": @2,
        @"discount": @2.5,
        @"coupon": @"hasbros",
        @"currency": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)eCommerceEventOrderCompleted {
    NSDictionary *tempDict = @{
        @"checkout_id": @"fksdjfsdjfisjf9sdfjsd9f",
        @"order_id": @"50314b8e9bcf000000000000",
        @"affiliation": @"Google Store",
        @"total": @27.50,
        @"subtotal": @22.50,
        @"revenue": @25.00,
        @"shipping": @3,
        @"tax": @2,
        @"discount": @2.5,
        @"coupon": @"hasbros",
        @"currency": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)eCommerceEventOrderRefunded {
    NSDictionary *tempDict = @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"total": @30,
        @"currency": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)eCommerceEventOrderCancelled {
    NSDictionary *tempDict = @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"affiliation": @"Google Store",
        @"total": @27.50,
        @"subtotal": @22.50,
        @"revenue": @25.00,
        @"shipping": @3,
        @"tax": @2,
        @"discount": @2.5,
        @"coupon": @"hasbros",
        @"currency": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)eCommerceEventCouponEntered {
    return @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"cart_id": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id": @"may_deals_2016"
    };
}

+ (NSDictionary*)eCommerceEventCouponApplied {
    return @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"cart_id": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id": @"may_deals_2016",
        @"coupon_name": @"May Deals 2016",
        @"discount": @23.32
    };
}

+ (NSDictionary*)eCommerceEventCouponDenied {
    return @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"cart_id": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id": @"may_deals_2016",
        @"reason": @"Coupon expired"
    };
}

+ (NSDictionary*)eCommerceEventCouponRemoved {
    return @{
        @"order_id": @"50314b8e9bcf000000000000",
        @"cart_id": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id": @"may_deals_2016",
        @"coupon_name": @"May Deals 2016",
        @"discount": @23.32
    };
}

+ (NSDictionary*)eCommerceEventProductAddedToWishlist {
    NSDictionary *tempDict = @{
        @"wishlist_id": @"skdjsidjsdkdj29j",
        @"wishlist_name": @"Loved Games"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)eCommerceEventProductRemovedFromWishlist {
    NSDictionary *tempDict = @{
        @"wishlist_id": @"skdjsidjsdkdj29j",
        @"wishlist_name": @"Loved Games"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)eCommerceEventWishlistProductAddedToCart {
    NSDictionary *tempDict = @{
        @"wishlist_id": @"skdjsidjsdkdj29j",
        @"wishlist_name": @"Loved Games",
        @"cart_id": @"99j2d92j9dj29dj29d2d"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)eCommerceEventProductShared {
    NSDictionary *tempDict = @{
        @"share_via": @"email",
        @"share_message": @"Hey, check out this item",
        @"recipient": @"friend@example.com"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[SegmentSpecFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)eCommerceEventProductReviewed {
    return @{
        @"product_id": @"507f1f77bcf86cd799439011",
        @"review_id": @"kdfjrj39fj39jf3",
        @"review_body": @"I love this product",
        @"rating": @5,
    };
}

+ (NSDictionary*)eCommerceEventCartShared {
    return @{
        @"share_via": @"email",
        @"share_message": @"kdfjrj39fj39jf3",
        @"review_body": @"Hey, check out this item",
        @"recipient": @"friend@example.com",
        @"cart_id": @"d92jd29jd92jd29j92d92jd",
        @"products": @[
                @{@"product_id": @"507f1f77bcf86cd799439011"},
                @{@"product_id": @"505bd76785ebb509fc183733"}
        ]
    };
}

+ (NSDictionary*)getMonopolyProduct {
     return @{
         @"product_id": @"507f1f77bcf86cd799439011",
         @"sku": @"G-32",
         @"category": @"Games",
         @"name": @"Monopoly: 3rd Edition",
         @"brand": @"Hasbro",
         @"variant": @"200 pieces",
         @"price": @18.99,
         @"quantity": @1,
         @"coupon": @"MAYDEALS",
         @"position": @3,
         @"url": @"https://www.example.com/product/path",
         @"image_url": @"https://www.example.com/product/path.jpg",
     };
}

+ (NSDictionary*)getGameProducts {
    return @{
        @"products": @[
                @{
                    @"product_id": @"507f1f77bcf86cd799439011",
                    @"sku": @"45790-32",
                    @"name": @"Monopoly: 3rd Edition",
                    @"price": @19.0,
                    @"position": @1,
                    @"category": @"Games",
                    @"url": @"https://www.example.com/product/path-32",
                    @"image_url": @"https://www.example.com/product/path.jpg-32",
                },
                @{
                    @"product_id": @"505bd76785ebb509fc183733",
                    @"sku": @"46493-32",
                    @"name": @"Uno Card Game",
                    @"price": @3.0,
                    @"position": @2,
                    @"category": @"Games",
                }
        ]
    };
}

@end
