//
//  AppDelegate.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 2/28/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Pushwoosh/PushNotificationManager.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, PushNotificationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
