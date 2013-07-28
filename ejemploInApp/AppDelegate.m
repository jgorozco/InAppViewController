//
//  AppDelegate.m
//  ejemploInApp
//
//  Created by P2503-IMAC on 15/07/13.
//  Copyright (c) 2013 ejemplo. All rights reserved.
//

#import "AppDelegate.h"

#import "PaymentViewController.h"
#define PACK_INAPP1 @"com.inapp.inapp1"
#define PACK_INAPP2 @"com.inapp.inapp2"
#define PACK_INAPP3 @"com.inapp.inapp3"
#define PACK_INAPP4 @"com.inapp.inapp4"
#define PACK_INAPP5 @"com.inapp.inapp5"
#define PACK_INAPP6 @"com.inapp.inapp6"
#define PACK_INAPP7 @"com.inapp.inapp7"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[PaymentViewController alloc] initWithNibName:@"PaymentViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[PaymentViewController alloc] initWithNibName:@"PaymentViewController_iPad" bundle:nil];
    }
    [self.viewController setProducts:[NSArray arrayWithObjects:PACK_INAPP1,PACK_INAPP2,PACK_INAPP3,PACK_INAPP4,PACK_INAPP5,PACK_INAPP6,PACK_INAPP7, nil]];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
