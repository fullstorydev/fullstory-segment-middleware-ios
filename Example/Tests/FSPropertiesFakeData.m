//
//  FSPropertiesFakeData.m
//  FullStorySegmentMiddleware_Example
//
//  Created by FullStory on 7/14/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

//   FSPropertiesFakeData contains transformed data resulted from SegmentSpecFakeData class.
//   FullStory's requirement for custom property names suffix can be found here:
//   https://help.fullstory.com/hc/en-us/articles/360020623234-FS-Recording-Client-API-Requirements
//   Sample input in json format:
//   {
//       name: "a product",
//       quantity: 5,
//       price: 3.30,
//       type: ["string1", "string2"],
//       keysArray: [{key: "val1"}, {key: "val2"}]
//   }
//   Sample output:
//    {
//       name_str: "a product",
//       quantity_int: 5,
//       price_real: 3.30,
//       type_strs: ["string1", "string2"],
//       keysArray.key_strs: ["val1", "val2"]
//   }


#import <Foundation/Foundation.h>
#import "FSPropertiesFakeData.h"

@implementation FSPropertiesFakeData

+ (NSDictionary*)ECommerceEventsProductsSearched {
    return @{
        @"query_str": @"blue roses"
    };
}

+ (NSDictionary*)ECommerceEventsProductListViewed {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"list_id_str"] = @"hot_deals_1";
    dict[@"category_str"] = @"Deals";
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsProductListFiltered {
    return @{
        @"list_id_str": @"todays_deals_may_11_2019",
        @"filters.type_strs": @[@"department", @"price"],
        @"filters.value_strs": @[@"beauty", @"under-$25"],
        @"sorts.type_str": @"price",
        @"sorts.value_str": @"desc",
        @"products.product_id_strs": @[@"507f1f77bcf86cd798439011",@"505bd76785ebb509fc283733"],
        @"products.sku_strs": @[@"45360-32", @"46573-32"],
        @"products.name_strs": @[@"Special Facial Soap", @"Fancy Hairbrush"],
        @"products.price_reals": @[@12.60, @7.60],
        @"products.position_ints": @[@1, @2],
        @"products.category_strs": @[@"Beauty", @"Beauty"],
        @"products.url_str": @"https://www.example.com/product/path",
        @"products.image_url_str": @"https://www.example.com/product/path.jpg",
    };
}

+ (NSDictionary*)ECommerceEventsPromotionViewed {
    return @{
        @"promotion_id_str": @"promo_1",
        @"creative_str": @"top_banner_2",
        @"name_str": @"75% store-wide shoe sale",
        @"position_str": @"home_banner_top"
    };
}

+ (NSDictionary*)ECommerceEventsPromotionClicked {
    return @{
        @"promotion_id_str": @"promo_1",
        @"creative_str": @"top_banner_2",
        @"name_str": @"75% store-wide shoe sale",
        @"position_str": @"home_banner_top"
    };
}

+ (NSDictionary*)ECommerceEventsProductClicked {
    return [FSPropertiesFakeData getMonopolyProduct];
}

+ (NSDictionary*)ECommerceEventsProductViewed {
    NSDictionary *tempDict = @{
        @"currency_str": @"usd",
        @"value_real": @18.99,
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsProductAdded {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cart_id_str"] = @"skdjsidjsdkdj29j";
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsProductRemoved {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cart_id_str"] = @"skdjsidjsdkdj29j";
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsCartViewed {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    dict[@"cart_id_str"] = @"skdjsidjsdkdj29j";
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsCheckoutStarted {
    NSDictionary *tempDict = @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"affiliation_str": @"Google Store",
        @"value_int": @30,
        @"revenue_real": @25.00,
        @"shipping_int": @3,
        @"tax_int": @2,
        @"discount_real": @2.5,
        @"coupon_str": @"hasbros",
        @"currency_str": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsCheckoutStepViewed {
    return @{
        @"checkout_id_str": @"50314b8e9bcf000000000000",
        @"step_int": @2,
        @"shipping_method_str": @"Fedex",
        @"payment_method_str": @"Visa",
    };
}

+ (NSDictionary*)ECommerceEventsCheckoutStepCompleted {
    return @{
        @"checkout_id_str": @"50314b8e9bcf000000000000",
        @"step_int": @2,
        @"shipping_method_str": @"Fedex",
        @"payment_method_str": @"Visa",
    };
}

+ (NSDictionary*)ECommerceEventsCheckoutPaymentInfoEntered {
    return @{
        @"checkout_id_str": @"39f39fj39f3jf93fj9fj39fj3f",
        @"order_id_str": @"dkfsjidfjsdifsdfksdjfkdsfjsdfkdsf"
    };
}

+ (NSDictionary*)ECommerceEventsOrderUpdated {
    NSDictionary *tempDict = @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"affiliation_str": @"Google Store",
        @"total_real": @27.50,
        @"revenue_real": @25.00,
        @"shipping_int": @3,
        @"tax_int": @2,
        @"discount_real": @2.5,
        @"coupon_str": @"hasbros",
        @"currency_str": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsOrderCompleted {
    NSDictionary *tempDict = @{
        @"checkout_id_str": @"fksdjfsdjfisjf9sdfjsd9f",
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"affiliation_str": @"Google Store",
        @"total_real": @27.50,
        @"subtotal_real": @22.50,
        @"revenue_real": @25.00,
        @"shipping_int": @3,
        @"tax_int": @2,
        @"discount_real": @2.5,
        @"coupon_str": @"hasbros",
        @"currency_str": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsOrderRefunded {
    NSDictionary *tempDict = @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"total_int": @30,
        @"currency_str": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsOrderCancelled {
    NSDictionary *tempDict = @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"affiliation_str": @"Google Store",
        @"total_real": @27.50,
        @"subtotal_real": @22.50,
        @"revenue_real": @25.00,
        @"shipping_int": @3,
        @"tax_int": @2,
        @"discount_real": @2.5,
        @"coupon_str": @"hasbros",
        @"currency_str": @"USD",
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getGameProducts]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsCouponEntered {
    return @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"cart_id_str": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id_str": @"may_deals_2016"
    };
}

+ (NSDictionary*)ECommerceEventsCouponApplied {
    return @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"cart_id_str": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id_str": @"may_deals_2016",
        @"coupon_name_str": @"May Deals 2016",
        @"discount_real": @23.32
    };
}

+ (NSDictionary*)ECommerceEventsCouponDenied {
    return @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"cart_id_str": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id_str": @"may_deals_2016",
        @"reason_str": @"Coupon expired"
    };
}

+ (NSDictionary*)ECommerceEventsCouponRemoved {
    return @{
        @"order_id_str": @"50314b8e9bcf000000000000",
        @"cart_id_str": @"923923929jd29jd92dj9j93fj3",
        @"coupon_id_str": @"may_deals_2016",
        @"coupon_name_str": @"May Deals 2016",
        @"discount_real": @23.32
    };
}

+ (NSDictionary*)ECommerceEventsProductAddedToWishlist {
    NSDictionary *tempDict = @{
        @"wishlist_id_str": @"skdjsidjsdkdj29j",
        @"wishlist_name_str": @"Loved Games"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsProductRemovedFromWishlist {
    NSDictionary *tempDict = @{
        @"wishlist_id_str": @"skdjsidjsdkdj29j",
        @"wishlist_name_str": @"Loved Games"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsWishlistProductAddedToCart {
    NSDictionary *tempDict = @{
        @"wishlist_id_str": @"skdjsidjsdkdj29j",
        @"wishlist_name_str": @"Loved Games",
        @"cart_id_str": @"99j2d92j9dj29dj29d2d"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsProductShared {
    NSDictionary *tempDict = @{
        @"share_via_str": @"email",
        @"share_message_str": @"Hey, check out this item",
        @"recipient_str": @"friend@example.com"
    };
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:tempDict];
    [dict addEntriesFromDictionary:[FSPropertiesFakeData getMonopolyProduct]];
    return dict;
}

+ (NSDictionary*)ECommerceEventsProductReviewed {
    return @{
        @"product_id_str": @"507f1f77bcf86cd799439011",
        @"review_id_str": @"kdfjrj39fj39jf3",
        @"review_body_str": @"I love this product",
        @"rating_int": @5,
    };
}

+ (NSDictionary*)ECommerceEventsCartShared {
    return @{
        @"share_via_str": @"email",
        @"share_message_str": @"kdfjrj39fj39jf3",
        @"review_body_str": @"Hey, check out this item",
        @"recipient_str": @"friend@example.com",
        @"cart_id_str": @"d92jd29jd92jd29j92d92jd",
        @"products.product_id_strs": @[@"507f1f77bcf86cd799439011", @"505bd76785ebb509fc183733"]
    };
}

+ (NSDictionary*)getMonopolyProduct {
     return @{
         @"product_id_str": @"507f1f77bcf86cd799439011",
         @"sku_str": @"G-32",
         @"category_str": @"Games",
         @"name_str": @"Monopoly: 3rd Edition",
         @"brand_str": @"Hasbro",
         @"variant_str": @"200 pieces",
         @"price_real": @18.99,
         @"quantity_int": @1,
         @"coupon_str": @"MAYDEALS",
         @"position_int": @3,
         @"url_str": @"https://www.example.com/product/path",
         @"image_url_str": @"https://www.example.com/product/path.jpg",
     };
}

+ (NSDictionary*)getGameProducts {
    return @{
        @"products.product_id_strs": @[@"507f1f77bcf86cd799439011", @"505bd76785ebb509fc183733"],
        @"products.sku_strs": @[@"45790-32", @"46493-32"],
        @"products.name_strs": @[@"Monopoly: 3rd Edition", @"Uno Card Game"],
        @"products.price_reals": @[@19.0, @3.0],
        @"products.position_ints": @[@1, @2],
        @"products.category_strs": @[@"Games", @"Games"],
        @"products.url_str": @"https://www.example.com/product/path-32",
        @"products.image_url_str": @"https://www.example.com/product/path.jpg-32"
    };
}

@end
