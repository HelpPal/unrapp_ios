//
//  SettingsUITableViewController.m
//  Unrapp
//
//  Created by Administrator on 5/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "SettingsUITableViewController.h"
#import "UIImageLoader.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "UIControl+NextControl.h"

@interface SettingsUITableViewController ()

@end

extern UIImage *userImage;
@implementation SettingsUITableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    //self.passwordUITextField.delegate = self;
    self.emailAddressUITextField.delegate = self;
    self.phoneUITextField.delegate = self;
    self.zipUITextField.delegate = self;
    self.firstnameUITextField.delegate = self;
    self.lastnameUITextField.delegate = self;
    self.taglineUITextField.delegate = self;
    self.locationUITextField.delegate = self;
    
    WSUser *user = [WebService getLoggedInUser];
    
    
    self.usernameUITextField.text = user.username;
    self.emailAddressUITextField.text = user.email;
    self.phoneUITextField.text = user.phone;
    self.zipUITextField.text = user.zipcode;
    self.firstnameUITextField.text = user.firstName;
    self.lastnameUITextField.text = user.lastName;
    self.taglineUITextField.text = user.tagline;
    self.locationUITextField.text = user.location;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    NSString *tmp = [WebService getLoggedInUser].userImage;
    
    NSURL * url = [NSURL URLWithString:tmp];
    [[UIImageLoader defaultLoader] loadImageWithURL:url
     
                                           hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                               
                                               
                                               //use cached image
                                               self.myImage.image = image;
                                               NSLog(@"Using Cache.");
                                               
                                           } sendingRequest:^(BOOL didHaveCachedImage) {
                                               
                                           } requestCompleted:^(NSError *error, UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                               
                                               //request complete.
                                               NSLog(@"Complete");
                                               
                                               //if image was downloaded, use it.
                                               if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
                                                   NSLog(@"Image Downloaded.");
                                                   self.myImage.image = image;
                                               }
                                               else if (error)
                                               {
                                                   NSLog(@"There was an error");
                                                   self.myImage.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
                                               }
                                           }];
    
    // Make Rounded..
    
    
    [self.myImage setPathColor:[UIColor lightGrayColor]];
    [self.myImage setBorderColor:[UIColor lightGrayColor]];
    [self.myImage setPathWidth:2.0];
    [self.myImage setPathType:GBPathImageViewTypeCircle];
    [self.myImage draw];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"UpdateProfile"
                                              object:nil];
}

-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"UpdateProfile"];
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
            // Update current user object...
            [WebService storeLoggedIn:[self getFormUserObject]];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UpdateProfile"
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
    [textField transferFirstResponderToNextControl];
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView setContentInset: UIEdgeInsetsMake(0, 0, 260, 0)];
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tableView setContentInset: UIEdgeInsetsMake(0, 0, 0, 0)];
}

#pragma mark - Action Methods

- (IBAction)logOutButtonSelected:(id)sender
{
    [SVProgressHUD showWithStatus:@"Logging Out ..."];
    [WebService logOutUser];
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (WSUser*)getFormUserObject
{
    NSString *emailAddress = [self.emailAddressUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneNumber = [self.phoneUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *postalCode = [self.zipUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *firstname = [self.firstnameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *lastname = [self.lastnameUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSString *location = [self.locationUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tagline = [self.taglineUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    // Clean phone number to be only digits
    phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                   componentsJoinedByString:@""];
    
    
    WSUser *currentUser = [WebService getLoggedInUser];
    
    currentUser.email = [emailAddress lowercaseString];
    currentUser.phone = phoneNumber;
    currentUser.zipcode = postalCode;
    currentUser.firstName = firstname;
    currentUser.lastName = lastname ;
    currentUser.location = location;
    currentUser.tagline = tagline;
    
    return currentUser;
}

- (IBAction)saveButtonSelected:(id)sender
{
    [SVProgressHUD showWithStatus:@"Saving ..."];
    
    [WebService UpdateWSUser:[self getFormUserObject]];
    
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

- (IBAction)cancelButtonSelected:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
