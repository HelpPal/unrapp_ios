//
//  PhoneSettingsUITableViewController.h
//  Unrapp
//
//  Created by Robert Durish on 3/15/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@interface PhoneSettingsUITableViewController : UITableViewController<CustomIOS7AlertViewDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UISwitch *accountStatus;

@end
