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

+ (NSDictionary*)ECommerceEventsProductsSearched;
+ (NSDictionary*)ECommerceEventsProductListViewed;
+ (NSDictionary*)ECommerceEventsProductListFiltered;
+ (NSDictionary*)ECommerceEventsPromotionViewed;
+ (NSDictionary*)ECommerceEventsPromotionClicked;
+ (NSDictionary*)ECommerceEventsProductClicked;
+ (NSDictionary*)ECommerceEventsProductViewed;
+ (NSDictionary*)ECommerceEventsProductAdded;
+ (NSDictionary*)ECommerceEventsProductRemoved;
+ (NSDictionary*)ECommerceEventsCartViewed;
+ (NSDictionary*)ECommerceEventsCheckoutStarted;
+ (NSDictionary*)ECommerceEventsCheckoutStepViewed;
+ (NSDictionary*)ECommerceEventsCheckoutStepCompleted;
+ (NSDictionary*)ECommerceEventsCheckoutPaymentInfoEntered;
+ (NSDictionary*)ECommerceEventsOrderUpdated;
+ (NSDictionary*)ECommerceEventsOrderCompleted;
+ (NSDictionary*)ECommerceEventsOrderRefunded;
+ (NSDictionary*)ECommerceEventsOrderCancelled;
+ (NSDictionary*)ECommerceEventsCouponEntered;
+ (NSDictionary*)ECommerceEventsCouponApplied;
+ (NSDictionary*)ECommerceEventsCouponDenied;
+ (NSDictionary*)ECommerceEventsCouponRemoved;
+ (NSDictionary*)ECommerceEventsProductAddedToWishlist;
+ (NSDictionary*)ECommerceEventsProductRemovedFromWishlist;
+ (NSDictionary*)ECommerceEventsWishlistProductAddedToCart;
+ (NSDictionary*)ECommerceEventsProductShared;
+ (NSDictionary*)ECommerceEventsProductReviewed;
+ (NSDictionary*)ECommerceEventsCartShared;
+ (NSDictionary*)getMonopolyProduct;
+ (NSDictionary*)getGameProducts;

@end

#endif /* FSPropertiesFakeData_h */
