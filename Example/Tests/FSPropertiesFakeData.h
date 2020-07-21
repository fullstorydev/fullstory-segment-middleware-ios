//
//  FSPropertiesFakeData.h
//  FullStorySegmentMiddleware
//
//  Created by FullStory on 7/15/20.
//  Copyright © 2020 FullStory. All rights reserved.
//

#ifndef FSPropertiesFakeData_h
#define FSPropertiesFakeData_h

@interface FSPropertiesFakeData : NSObject

+ (NSDictionary*)eCommerceEventProductsSearched;
+ (NSDictionary*)eCommerceEventProductListViewed;
+ (NSDictionary*)eCommerceEventProductListFiltered;
+ (NSDictionary*)eCommerceEventPromotionViewed;
+ (NSDictionary*)eCommerceEventPromotionClicked;
+ (NSDictionary*)eCommerceEventProductClicked;
+ (NSDictionary*)eCommerceEventProductViewed;
+ (NSDictionary*)eCommerceEventProductAdded;
+ (NSDictionary*)eCommerceEventProductRemoved;
+ (NSDictionary*)eCommerceEventCartViewed;
+ (NSDictionary*)eCommerceEventCheckoutStarted;
+ (NSDictionary*)eCommerceEventCheckoutStepViewed;
+ (NSDictionary*)eCommerceEventCheckoutStepCompleted;
+ (NSDictionary*)eCommerceEventCheckoutPaymentInfoEntered;
+ (NSDictionary*)eCommerceEventOrderUpdated;
+ (NSDictionary*)eCommerceEventOrderCompleted;
+ (NSDictionary*)eCommerceEventOrderRefunded;
+ (NSDictionary*)eCommerceEventOrderCancelled;
+ (NSDictionary*)eCommerceEventCouponEntered;
+ (NSDictionary*)eCommerceEventCouponApplied;
+ (NSDictionary*)eCommerceEventCouponDenied;
+ (NSDictionary*)eCommerceEventCouponRemoved;
+ (NSDictionary*)eCommerceEventProductAddedToWishlist;
+ (NSDictionary*)eCommerceEventProductRemovedFromWishlist;
+ (NSDictionary*)eCommerceEventWishlistProductAddedToCart;
+ (NSDictionary*)eCommerceEventProductShared;
+ (NSDictionary*)eCommerceEventProductReviewed;
+ (NSDictionary*)eCommerceEventCartShared;
+ (NSDictionary*)getMonopolyProduct;
+ (NSDictionary*)getGameProducts;

@end

#endif /* FSPropertiesFakeData_h */
