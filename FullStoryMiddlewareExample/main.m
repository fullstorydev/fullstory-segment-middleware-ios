//
//  main.m
//  FullStoryMiddlewareExample
//
//  Created by FullStory on 9/24/20.
//  Copyright (c) 2020 FullStory. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
<<<<<<< HEAD
    NSString * appDelegateClassName = NSStringFromClass([AppDelegate class]);
=======
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
>>>>>>> ac8e56e (re-structure-project)
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
