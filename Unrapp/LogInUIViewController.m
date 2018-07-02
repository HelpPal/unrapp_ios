//
//  LogInUIViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 2/28/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "LogInUIViewController.h"

#import "SVProgressHUD.h"
#import "MKInputBoxView.h"
#import "UIControl+NextControl.h"
#import "WebService.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SignUpUIViewController.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LogInUIViewController ()

@end

@implementation LogInUIViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.usernameUITextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"CheckUserLogin"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationForgot:)
                                                name:@"ForgotPassword"
                                              object:nil];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"forgot"])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"CheckUserLogin"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ForgotPassword"
                                                  object:nil];
}
     
-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"CheckUserLogin"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
            // Login Credentials are valid.
            
            //Store user variable.
            WSUser *u = [[WSUser alloc] init];
            NSMutableDictionary *dictUser = [dict objectForKey:@"User"];
            u.userID = [dictUser objectForKey:@"userID"];
            u.username = [dictUser objectForKey:@"username"];
            u.userImage = [dictUser objectForKey:@"userImage"];
            u.firstName = [dictUser objectForKey:@"firstName"];
            u.lastName = [dictUser objectForKey:@"lastName"];
            u.location = [dictUser objectForKey:@"location"];
            u.email = [dictUser objectForKey:@"email"];
            u.tagline = [dictUser objectForKey:@"tagline"];
            u.zipcode = [dictUser objectForKey:@"zipcode"];
            u.phone = [dictUser objectForKey:@"phone"];
            u.APIKey = [dictUser objectForKey:@"UserAPIKey"];
            u.disabled = [[dictUser objectForKey:@"disabled"] boolValue];
            u.following = [dictUser objectForKey:@"following"];
            u.followers = [dictUser objectForKey:@"followers"];
            [WebService storeLoggedIn:u];
            
            // Register Registration with facebook.
            [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration];
            
            // User logged in
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD dismiss];
                
                // Register for Push Notitications, if running iOS 8
                if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                    UIUserNotificationTypeBadge |
                                                                    UIUserNotificationTypeSound);
                    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                             categories:nil];
                    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                }
            
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            
        }
        else
        {
            
            // The login failed. Check error to see why.
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:
                 [NSString stringWithFormat:@"Log In Failed! Please try again. Error: %@",
                  [dict objectForKey:@"Message"]]];
            }];
            
            
        }
    }
}

-(void)wsNotificationForgot:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"ForgotPassword"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
}

#pragma mark - Text Field Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[textField resignFirstResponder];
    //return YES;
    
    
    [textField transferFirstResponderToNextControl];
    return NO;
}

#pragma mark - Actions

- (IBAction)forgotButtonSelected:(id)sender
{
    MKInputBoxView *inputBoxView = [MKInputBoxView boxOfType:EmailInput];
    [inputBoxView setBlurEffectStyle:UIBlurEffectStyleLight];
    [inputBoxView setTitle:@"Forgot your password?"];
    [inputBoxView setMessage:@"Please enter your email and we will send instructions to reset your password."];
    [inputBoxView setSubmitButtonText:@"SUBMIT"];
    [inputBoxView setCancelButtonText:@"CANCEL"];
    
    inputBoxView.onSubmit = ^(NSString *value1, NSString *value2) {
        
        [SVProgressHUD showWithStatus:@"Checking Email.."];
        
        [WebService ForgotPasswordFor:value1];
        
        
    };
    
    [inputBoxView show];
}

- (IBAction)logInButtonSelected:(id)sender
{
    [SVProgressHUD showWithStatus:@"Logging In ..."];
    
    NSString *username = [self.usernameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [WebService check:username and:password];
    
    [self.view endEditing:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString: @"facebook"])
    {
        SignUpUIViewController *dest = (SignUpUIViewController *)[segue destinationViewController];
        if (firstName || lastName || email)
        {
            dest.firstName = firstName;
            dest.lastName = lastName;
            dest.email = email;
        }
        
    }
}

- (IBAction)facebookClick:(id)sender {
    [SVProgressHUD showWithStatus:@"Requesting Facebook Info..."];
    [self grabFacebookInfoForScreen];
}

-(void)grabFacebookInfoForScreen
{
    FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
    [loginManager logInWithReadPermissions:@[@"public_profile",@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error == nil && result.isCancelled == NO)
        {
            [self fetchUserInfo];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Oooops...Something went wrong."];
        }
    }];
    
    
    
}
-(void)fetchUserInfo
{
    if ([FBSDKAccessToken currentAccessToken])
    {
        NSLog(@"Token is available : %@",[[FBSDKAccessToken currentAccessToken]tokenString]);
        
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, email"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (!error)
             {
                 NSLog(@"result is:%@",result);
                 firstName = [result valueForKey:@"first_name"];
                 lastName = [result valueForKey:@"last_name"];
                 email = [result valueForKey:@"email"];
                 [SVProgressHUD dismiss];
                 [self performSegueWithIdentifier:@"facebook" sender:self];
             }
             else
             {
                 NSLog(@"Error %@",error);
                 [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             }
         }];
        
    }
    
}

@end
