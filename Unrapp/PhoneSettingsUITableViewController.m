//
//  PhoneSettingsUITableViewController.m
//  Unrapp
//
//  Created by Robert Durish on 3/15/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "PhoneSettingsUITableViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"

@interface PhoneSettingsUITableViewController ()

@end
extern UIImage *userImage;

@implementation PhoneSettingsUITableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    
    [self.accountStatus setOn:[WebService getLoggedInUser].disabled];
    
    //NSNumber *b = [PFUser currentUser][@"disabled"];
    //[self.accountStatus setOn:[b boolValue]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationDelete:)
                                                name:@"DeleteAccount"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationPrivacy:)
                                                name:@"ChangeAccountPrivacy"
                                              object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DeleteAccount"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ChangeAccountPrivacy"
                                                  object:nil];
}


- (IBAction)doneTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        @try {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        @catch (NSException *exception) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Alert"
                message: @"Please update your settings in the settings application."
                delegate: self
                cancelButtonTitle:nil
                otherButtonTitles:@"OK",nil];
            [alert show];
        }
        
    }
    else if(indexPath.section == 0 && indexPath.row == 4)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Are you sure?"
                                                       message: @"This will delete your account off unrapp.  You can not undo this action, all gifts you have sent will still show in user accounts, if you want something removed from the app please contact team@unrapp.com"
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        alert.tag = 9999;
        [alert show];
    }
    else if (indexPath.section == 0 && indexPath.row == 0)
    {
        // Log Out
        [SVProgressHUD showWithStatus:@"Logging Out ..."];
        [WebService logOutUser];
        [SVProgressHUD dismiss];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        [self showPopupFor:@"TERMS"];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)
    {
        //[self showPopupFor:@"HELP"];
    }
    else if (indexPath.section == 2 && indexPath.row == 2)
    {
        [self showPopupFor:@"VERSION"];
    }
    
}

- (void) showPopupFor:(NSString *)page
{
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    //create the string
    NSMutableString *html = [NSMutableString stringWithString: @"<html><head><title></title></head><body>"];
    
    //continue building the string
    
    //instantiate the web view
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
   
    if ([page isEqualToString:@"VERSION"])
    {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://unrapp.com/about.aspx?v=%@",[self appVersionNumberString]]];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [webView loadRequest:req];
    } else if ([page isEqualToString:@"HELP"])
    {
        [html appendString:@"<h1>Help</h1>"];
        [html appendString:@"<p>Coming Soon....</p>"];
        [html appendString:@"</body></html>"];
        //pass the string to the webview
        [webView loadHTMLString:[html description] baseURL:nil];
    }
    else
    {
        NSURL *url = [NSURL URLWithString:@"http://unrapp.com/terms.html"];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [webView loadRequest:req];
    }
    
    
    
    
    
    
    [alertView setContainerView:webView];
    [alertView setDelegate:self];
    [alertView show];
}

- (NSString *)appVersionNumberString {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    return [NSString stringWithFormat:@"%@(%@)",[infoDict objectForKey:@"CFBundleShortVersionString"],[infoDict objectForKey:@"CFBundleVersion"]];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [alertView close];
}

- (IBAction)privateChanged:(id)sender {
    [SVProgressHUD showWithStatus:@"Updating..."];
    // Set Account Status.
    [WebService ChangeAccountPrivacy:self.accountStatus.isOn];
}

#pragma mark - Alertview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 9999)
    {
        if (buttonIndex == 1)
        {
            [SVProgressHUD showWithStatus:@"Deleting Account"];
            [WebService DeleteAccount];
        }
    }
}

-(void)wsNotificationPrivacy:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"ChangeAccountPrivacy"];
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

-(void)wsNotificationDelete:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"DeleteAccount"];
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
                [WebService logOutUser];
                
                userImage = nil;
                self.tabBarController.selectedIndex = 0;
                
                [self dismissViewControllerAnimated:YES completion:nil];
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

@end
