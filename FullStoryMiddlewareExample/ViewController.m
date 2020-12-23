//
//  ViewController.m
//  FullStoryMiddlewareExample
//
//  Created by FullStory on 9/24/20.
//  Copyright (c) 2020 FullStory. All rights reserved.
//

#import "ViewController.h"
<<<<<<< HEAD
#import <Analytics/SEGAnalytics.h>

@interface ViewController ()

/* Please note that this is simply minimal code to demonstrate the functionality of FullStorySegmentMiddleware
 please follow Apple's guidelines and refer to Segment documentation on implementing Analytics for your iOS app
 
 The APIs below are automatically forwarded to FullStory based on the middleware settings
*/

// allowlisted events:
@property (weak, nonatomic) IBOutlet UIButton *productViewed;
@property (weak, nonatomic) IBOutlet UIButton *completedCheckoutStep;
@property (weak, nonatomic) IBOutlet UIButton *orderCompleted;

// non-allowlisted events:
@property (weak, nonatomic) IBOutlet UIButton *viewedCheckoutStep;

=======

@interface ViewController ()

>>>>>>> f5504ff (Sabrina/re-structuring project (#11))
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
<<<<<<< HEAD
}
- (IBAction)onClickEvent:(UIButton*)sender { 
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
=======
    // Do any additional setup after loading the view.
>>>>>>> f5504ff (Sabrina/re-structuring project (#11))
}


@end
