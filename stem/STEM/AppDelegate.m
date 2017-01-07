//
//  AppDelegate.m
//  Earth 1
//
//  Created by Ian on 9/14/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import "AppDelegate.h"
#import "GameSceneManager.h"
#import "GSIntro.h"
#import "GSMantra.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    CGRect bounds =  [[UIScreen mainScreen] bounds];
    NSLog(@"Start Height = %f", bounds.size.height);

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] != nil){
/*        
        UILocalNotification *notification =
        launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        [self application:application didReceiveLocalNotification:notification];
*/
        
        self.window.rootViewController = [[GameSceneManager alloc] initFromAlarmFired];
        
    } else {
        self.window.rootViewController = [[GameSceneManager alloc] init];
    }
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    NSString *uid = notification.userInfo[@"uid"];
    if ([uid length] > 0){
/*
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:nil
                                   message:@"AppDelegate: Handling the local notification"
                                  delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
        [alert show];
*/
        [(GameSceneManager *)self.window.rootViewController doSceneChange:[GSMantra class]];

    }
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
}

@end
