#import <Foundation/Foundation.h>

@protocol FSDelegate;

typedef enum FSEventLogLevel {
    FSLOG_ASSERT = 0,
    FSLOG_ERROR,
    FSLOG_WARNING,
    FSLOG_INFO,
    FSLOG_DEBUG,
} FSEventLogLevel;

typedef NSString *_Nonnull FSViewClass NS_TYPED_ENUM;

FOUNDATION_EXPORT FSViewClass const FSViewClassMask;
FOUNDATION_EXPORT FSViewClass const FSViewClassMaskWithoutConsent;
FOUNDATION_EXPORT FSViewClass const FSViewClassUnmask;
FOUNDATION_EXPORT FSViewClass const FSViewClassUnmaskWithConsent;
FOUNDATION_EXPORT FSViewClass const FSViewClassExclude;
FOUNDATION_EXPORT FSViewClass const FSViewClassExcludeWithoutConsent;

__attribute__((visibility("default")))
@interface FS : NSObject

@property (class) id<FSDelegate> _Nullable delegate;
@property (class, readonly) NSString* _Nullable currentSession;
@property (class, readonly) NSString* _Nullable currentSessionURL;

NS_ASSUME_NONNULL_BEGIN
+ (void)anonymize;
/**
 Each time a page loads from a user you can identify, you'll want to call the FS.identify() function to associate
 your own application-specific id with the active user.

 @param uid: A string containing your unique identifier for the current user.
 */
+ (void)identify:(NSString *)uid;
/*!
 Each time a page loads from a user you can identify, you'll want to call the FS.identify() function to associate
 your own application-specific id with the active user.

 @discussion Limits: Sustained calls are limited to 12 calls per minute, with a burst limit of 5 calls per
 second.

 @param uid: A string containing your unique identifier for the current user.
 @param userVars: An NSDictionary (Dictionary if swift) with key/value pairs that provides additional
 information about your user (optional).

 @code
 // Objective-C
 NSMutableDictionary *userVars = [NSMutableDictionary dictionary];
 userVars = @{
              @"email": @"user1@example.com",
              @"displayName": @"Shopping User"
            };
 [FS identify:@"462718483" userVars:userVars]

 // Swift
 let userId = "13ff474bae77" // <- replace with your user’s Id
 let info = [
             "email": "user1@example.com",
             "displayName": "Shopping User"
            ]
 FS.identify(userId, userVars: info)
*/
+ (void)identify:(NSString *)uid userVars:(NSDictionary<NSString *, id> *)userVars;
/*!
 Each time a page loads from a user you can identify, you'll want to call the FS.identify() function to associate
 your own application-specific id with the active user.

 @discussion Limits:
 Sustained calls are limited to 12 calls per minute, with a burst limit of 5 calls per second.

 @param userVars: An NSDictionary with key/value pairs that provides additional information about your
 user (optional).

 @discussion Special Fields:
 @discussion displayName | The value of displayName is displayed in the session list and on the user
 card in the app.
 @discussion email | The value of email is used to let you email the user directly from the FS app.
 The email value can also be used to retrieve users and sessions via the Get User and List Sessions HTTP
 APIs.

 @code
 // Create or use an NSDictionary || (Dictionary if swift)
 // Objective-C
 NSMutableDictionary *userVars = [NSMutableDictionary dictionary];

 userVars = @{
                 @"email": @"user1@example.com",
                 @"displayName": @"Shopping User",
                 @"pricingPlan": @"free",
                 @"totalSpent": 14.50,
                 @"requiresHelp": YES,
             };
 [FS setUserVars: userVars]

 // Swift
 let info = [
             "email": "user1@example.com",
             "displayName": "Shopping User",
             "pricingPlan": "free",
             "totalSpent": 14.50,
             "requiresHelp": true,
            ]
 FS.setUserVars( userVars: info)
*/
+ (void)setUserVars:(NSDictionary<NSString *, id> *)userVars;
+ (void)logWithLevel:(FSEventLogLevel)level format:(NSString *)format, ...;
+ (void)logWithLevel:(FSEventLogLevel)level message:(NSString *)string;
/*!
 UIViews that have been configured to "Record with user consent" in FullStory's privacy settings are recorded
 in combination with an FS.consent invocation. FS.consent(true) must be called to begin recording elements
 that have been configured to record with user consent.

 @param userConsents: If `true`, elements configured to record with user consent in FullStory's privacy
 settings will begin recording. If false, these elements will no longer be recorded by FullStory.

 @code
 // Objective-C
 [FS consent:YES];

 // Swift
 FS.consent(true)
*/
+ (void)consent:(BOOL)consented;
/*!
 Domain-specific events recorded by FullStory add additional intelligence when you're searching across
 sessions and creating new user segments. You can define and record these events with FS.event.

 @discussion * Event names can be no longer than 250 characters.
 @discussion * The maximum size of eventProperties is 512Kb.
 @discussion * Sustained calls are limited to 30 calls per minute, with a burst limit of 10 calls per second.
 @discussion * Arrays of objects will not be indexed (arrays of strings and numbers will be indexed), with
 the exception of Order Completed events.

 @param eventName: A string containing the name of the event.
 @param eventProperties: A NSDictionary containing additional information about the event that will be
 indexed by FullStory.

 @code
 // Create or use an NSDictionary || (Dictionary if swift )
 // Objective-C
 // Adding a product to an ecommerce cart
 NSMutableDictionary *eventProperties = [NSMutableDictionary dictionary];
 eventProperties = @{
                         @"cartID" : @"130983678493",
                         @"productID" : @"798ith22928347",
                         @"sku" : @"L-100",
                         @"category" : @"Clothing"
                         @"name" : @"Button Front Cardigan",
                         @"brand" : @"Bright & Bold",
                         @"variant" : @"Blue",
                         @"priceReal" : 58.99,
                         @"quantityReal" : 1,
                         @"coupon" : @"25OFF",
                         @"position" : 3,
                         @"url" : @"https://www.example.com/product/path",
                         @"imageURL" : @"https://www.example.com/product/path.jpg"
                    };
 [FS event:@"ProductAdded" :eventProperties];

 // SaaS product subscription:
 eventProperties = @{
      @"uid": '750948353',
      @"planName": 'Professional',
      @"planPriceReal": 299,
      @"planUsers": 10,
      @"daysInTrial": 42,
      @"featurePacks": @['MAPS', 'DEV', 'DATA'],
 };
 [FS event:@"ProductAdded" :eventProperties];

 // Swift
 // Adding a product to an ecommerce cart
 eventProperties = [
                         "cartID" : "130983678493",
                         "productID" : "798ith22928347",
                         "sku" : "L-100",
                         "category" : "Clothing"
                         "name" : "Button Front Cardigan",
                         "brand" : "Bright & Bold",
                         "variant" : "Blue",
                         "priceReal" : 58.99,
                         "quantityReal" : 1,
                         "coupon" : "25OFF",
                         "position" : 3,
                         "url" : "https://www.example.com/product/path",
                         "imageURL" : "https://www.example.com/product/path.jpg"
                    ]
 FS.event(name: "Subscribed" , properties: eventProperties)

 // SaaS product subscription:
 eventProperties = [
                      "uid": '750948353',
                      "planName": 'Professional',
                      "planPriceReal": 299,
                      "planUsersInt": 10,
                      "daysInTrial_int": 42,
                      "featurePacks": ['MAPS', 'DEV', 'DATA'],
                   ]
 FS.event(name: "Subscribed" , properties: eventProperties)
*/
+ (void)event:(NSString *)name properties:(NSDictionary<NSString *, id> *)properties;
+ (void)setTagName:(UIView *)view tagName:(NSString *)tagName;
+ (void)setAttribute:(UIView *)view attributeName:(NSString *)name attributeValue:(NSString *)value;
+ (void)removeAttribute:(UIView *)view attributeName:(NSString *)name;
+ (void)addClass:(UIView *)view className:(NSString *)name;
+ (void)removeClass:(UIView *)view className:(NSString *)name;
+ (void)addClasses:(UIView *)view classNames:(NSArray<NSString *> *)names;
+ (void)removeClasses:(UIView *)view classNames:(NSArray<NSString *> *)names;
+ (void)removeAllClasses:(UIView *)view;
+ (void)shutdown;
+ (void)restart;
+ (NSString* _Nullable) currentSessionURL:(BOOL)now;
NS_ASSUME_NONNULL_END

@end
