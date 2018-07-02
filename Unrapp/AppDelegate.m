//
//  AppDelegate.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 2/28/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "AppDelegate.h"

#import <AdobeCreativeSDKCore/AdobeCreativeSDKCore.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "WebService.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import CoreLocation;
@import SystemConfiguration;
@import AVFoundation;
@import ImageIO;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[AdobeUXAuthManager sharedManager] setAuthenticationParametersWithClientID:@"10bcc43066f5465ab6e1f3352f555c2f"
                                                                   clientSecret:@"3e2b0f66-9db4-4734-88f7-989b34023c45"
                                                                   enableSignUp:false];

    
    [UITabBar appearance].tintColor = [UIColor colorWithRed:246 green:69 blue:98 alpha:1];
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:24 green:189 blue:243 alpha:1]];
    
    
    [UITabBar appearance].tintColor = [UIColor colorWithRed:24 green:189 blue:243 alpha:1];
    
    [Fabric with:@[[Crashlytics class]]];

    //-----------PUSHWOOSH PART-----------
    // set custom delegate for push handling, in our case - view controller
    PushNotificationManager * pushManager = [PushNotificationManager pushManager];
    pushManager.delegate = self;
    
    // handling push on app start
    [[PushNotificationManager pushManager] handlePushReceived:launchOptions];
    
    // make sure we count app open in Pushwoosh stats
    [[PushNotificationManager pushManager] sendAppOpen];
    
    // register for push notifications!
    //[[PushNotificationManager pushManager] registerForPushNotifications];
    
    
    //-----FACEBOOK------
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
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
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    [[PushNotificationManager pushManager] handlePushRegistration:deviceToken];
    WSUser *u = [WebService getLoggedInUser];
    [[PushNotificationManager pushManager] setUserId:u.username];
    
    // Create Tag Dictionary
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:u.username forKey:@"Name"];
    
    [[PushNotificationManager pushManager] setTags:dict];
}

// system push notification registration error callback, delegate to pushManager
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[PushNotificationManager pushManager] handlePushRegistrationFailure:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[PushNotificationManager pushManager] handlePushReceived:userInfo];
}

- (void) onPushAccepted:(PushNotificationManager *)pushManager withNotification:(NSDictionary *)pushNotification onStart:(BOOL)onStart {
    NSLog(@"Push notification received");
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation

{
    if([[url host] isEqualToString:@"forgotPassword"]){
        [[NSUserDefaults standardUserDefaults]
         setObject:[[url path] substringFromIndex:1] forKey:@"forgot"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] performSegueWithIdentifier:@"ForgotPasswordPush" sender:nil];
        
        
        }
    else{
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                      openURL:url
                                                            sourceApplication:sourceApplication
                                                                   annotation:annotation
                        ];
        
    }
        return YES;
        
}
@end
