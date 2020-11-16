//
//  ViewController.m
//  FullStoryMiddlewareExample
//
//  Created by FullStory on 9/24/20.
//  Copyright (c) 2020 FullStory. All rights reserved.
//

#import "ViewController.h"
#import <Analytics/SEGAnalytics.h>

@interface ViewController ()

/* Please note that this is simply minimal code to demostrate the functionality of the FullStorySegmentMiddleware
 please follow Apple's guide line and refer to Segment documentation on implementing Analytics for iOS for your app
 
 Below APIs are automatically forwared to FullStory based on the middleware settings
*/

// allowlisted event:
@property (weak, nonatomic) IBOutlet UIButton *productViewed;
// not allowlisted event:
@property (weak, nonatomic) IBOutlet UIButton *viewedCheckoutStep;
// allowlisted event:
@property (weak, nonatomic) IBOutlet UIButton *completedCheckoutStep;
// allowlisted event:
@property (weak, nonatomic) IBOutlet UIButton *orderCompleted;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)onClickEvent:(UIButton*)sender {
    // This 
    // get event name from button title
    NSString *eventName = sender.currentTitle;
    NSDictionary *fakeEventProperties = @{
      @"cart_id_str" : @"130983678493",
      @"product_id_str" : @"798ith22928347",
      @"sku_str" : @"L-100",
      @"category_str" : @"Clothing",
      @"name_str" : @"Button Front Cardigan",
      @"brand_str" : @"Bright & Bold",
      @"variant_str" : @"Blue",
      @"price_real" : @58.99,
      @"quantity_real" : @1,
      @"coupon_str" : @"25OFF",
      @"position_int" : @3,
      @"url_str" : @"https://www.example.com/product/path",
      @"image_url_str" : @"https://www.example.com/product/path.jpg"
    };
    
    [[SEGAnalytics sharedAnalytics] track:eventName
                               properties:fakeEventProperties];
    
    [[SEGAnalytics sharedAnalytics] screen:eventName];
}


@end
