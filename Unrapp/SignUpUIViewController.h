//
//  SignUpUIViewController.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 2/28/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"

@interface SignUpUIViewController : UIViewController <UITextFieldDelegate,CustomIOS7AlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneUITextField;
@property (weak, nonatomic) IBOutlet UITextField *firstnameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *password2TextField;
//@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField2;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

-(IBAction)saveButtonSelected:(id)sender;
@property (strong,nonatomic) NSString *firstName;
@property (strong,nonatomic) NSString *lastName;
@property (strong,nonatomic) NSString *email;
@end
