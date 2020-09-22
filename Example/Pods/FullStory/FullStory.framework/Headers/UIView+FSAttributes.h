#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FSAttributes)
- (void)fsSetTagName:(NSString *)name;
- (void)fsSetAttributeValue:(NSString *)value forAttribute:(NSString *)name;
- (void)fsRemoveAttribute:(NSString *)name;
- (void)fsAddClass:(NSString *)className;
- (void)fsRemoveClass:(NSString *)className;
- (void)fsAddClasses:(NSArray<NSString *> *)classNames;
- (void)fsRemoveClasses:(NSArray<NSString *> *)classNames;
- (void)fsRemoveAllClasses;
@end

NS_ASSUME_NONNULL_END
