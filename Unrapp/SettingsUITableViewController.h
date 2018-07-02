//
//  SettingsUITableViewController.h
//  Unrapp
//
//  Created by Administrator on 5/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"

@interface SettingsUITableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameUITextField;
//@property (weak, nonatomic) IBOutlet UITextField *passwordUITextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressUITextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneUITextField;
@property (weak, nonatomic) IBOutlet UITextField *zipUITextField;
@property (weak, nonatomic) IBOutlet UITextField *firstnameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameUITextField;
//@property (weak, nonatomic) IBOutlet UITextField *verifyPasswordUITextField;
@property (weak, nonatomic) IBOutlet UITextField *locationUITextField;
@property (weak, nonatomic) IBOutlet UITextField *taglineUITextField;
@property (weak, nonatomic) IBOutlet GBPathImageView *myImage;

- (IBAction)logOutButtonSelected:(id)sender;
- (IBAction)saveButtonSelected:(id)sender;
- (IBAction)cancelButtonSelected:(id)sender;



@end
