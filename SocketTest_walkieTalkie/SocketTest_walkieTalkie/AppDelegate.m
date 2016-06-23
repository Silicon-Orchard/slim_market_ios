//
//  AppDelegate.m
//  SocketTest_walkieTalkie
//
//  Created by salahuddin yousuf on 4/26/16.
//  Copyright © 2016 salahuddin yousuf. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [[NSUserDefaults standardUserDefaults] objectForKey:curr];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ACTIVEUSERLISTKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *myIPAddress = [[MessageHandler sharedHandler] getIPAddress];
    NSArray *Array = [myIPAddress componentsSeparatedByString:@"."];
    //NSString * lastSegment = [Array objectAtIndex:3];
    NSString * threeSegments = [NSString stringWithFormat:@"%@.%@.%@.", [Array objectAtIndex:0], [Array objectAtIndex:1], [Array objectAtIndex:2]];
    [[NSUserDefaults standardUserDefaults] setObject:threeSegments forKey:IPADDRESS_FORMATKEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *uuidForDevice = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_UUID_KEY_FORUSERDEFAULTS];
    if (!uuidForDevice) {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSUUID UUID]UUIDString] forKey:DEVICE_UUID_KEY_FORUSERDEFAULTS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new]
                                       forBarMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [UINavigationBar appearance].translucent = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //send
//    NSString * messgae = [[MessageHandler sharedHandler] leftApplicationMessage];
//    NSArray *ipArray = [[UserHandler sharedInstance] getAllUserIPs];
//    
//    
//    for (NSString *ip in ipArray) {
//        
//        [[asyncUDPConnectionHandler sharedHandler] sendMessage:messgae toIPAddress:ip];
//    }
//     NSLog(@"applicationWillTerminate");
}

@end
