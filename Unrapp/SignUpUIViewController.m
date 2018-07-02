//
//  SignUpUIViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 2/28/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "SignUpUIViewController.h"
#import "SVProgressHUD.h"
#import "UIControl+NextControl.h"
#import "WebService.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface SignUpUIViewController ()

@end

@implementation SignUpUIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.usernameUITextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.emailAddressTextField.delegate = self;
    
    
    
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    self.myScrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 430);
    self.myScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
//    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
//    // Optional: Place the button in the center of your view.
//    loginButton.center = self.view.center;
//    loginButton.readPermissions =
//    @[@"public_profile", @"email", @"user_friends"];
    
//    [self.view addSubview:loginButton];
    if (_firstName || _lastName || _email)
    {
        self.firstnameUITextField.text = _firstName;
        self.lastnameUITextField.text = _lastName;
        self.emailAddressTextField.text = _email;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"SignUp"
                                              object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"SignUp"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Text Field Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[textField resignFirstResponder];
    //return YES;
    [textField transferFirstResponderToNextControl];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.myScrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 690);
   // [self.myScrollView scrollRectToVisible:textField.frame animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //self.myScrollView.contentSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 430);
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

-(void)runSignupProcess
{
    [SVProgressHUD showWithStatus:@"Signing Up ..."];
    
    NSString *username = [self.usernameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password2 = [self.password2TextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *emailAddress = [self.emailAddressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneNumber = [self.phoneUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *firstname = [self.firstnameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastname = [self.lastnameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    
    // Clean phone number to be only digits
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                   componentsJoinedByString:@""];
    
    if ([username length] > 0 && [password length] > 0 && [emailAddress length] > 0 && [firstname length] > 0 && [lastname length] > 0)
    {
        [WebService registerUser:username Password:password Password2:password2 FirstName:firstname LastName:lastname Email:emailAddress PhoneNumber:phoneNumber];
        
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"Please fill out all required fields"];
    }
}

#pragma mark - Actions

-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"SignUp"];
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
            // Registration was a success.
            
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
            [WebService storeLoggedIn:u];
            
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
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
            
            
        }
    }
}


bool btnPushed = false;
- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (!btnPushed)
    {
        btnPushed = true;
        [alertView close];
        if (buttonIndex == 0)
        {
            [self runSignupProcess];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Sorry you can not register without agreeing to the Terms."];
        }
        btnPushed = false;
    }
}

-(IBAction)saveButtonSelected:(id)sender
{
    [self.emailAddressTextField resignFirstResponder];
    [self.firstnameUITextField resignFirstResponder];
    [self.lastnameUITextField resignFirstResponder];
    [self.usernameUITextField resignFirstResponder];
    [self.phoneUITextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.password2TextField resignFirstResponder];
    
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    
    //instantiate the web view
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    NSURL *url = [NSURL URLWithString:@"http://unrapp.com/terms.html"];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [webView loadRequest:req];
    
    [alertView setContainerView:webView];
    [alertView setDelegate:self];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"I Agree", @"Cancel", nil]];
    [alertView show];
    
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
            [SVProgressHUD showErrorWithStatus:@"Oooops"];
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
                 _firstnameUITextField.text = [result valueForKey:@"first_name"];
                 _lastnameUITextField.text = [result valueForKey:@"last_name"];
                 _emailAddressTextField.text = [result valueForKey:@"email"];
                 [SVProgressHUD dismiss];
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

