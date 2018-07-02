//
//  ChangePasswordViewController.m
//  Unrapp
//
//  Created by Robert Durish on 3/16/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"

@interface ResetPasswordViewController ()

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"ResetPassword"
                                              object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ResetPassword"
                                                  object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)cancelTouch:(id)sender {
    [[NSUserDefaults standardUserDefaults]
     setObject:nil forKey:@"forgot"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
   [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)saveTouched:(id)sender {
    [SVProgressHUD showWithStatus:@"Changing Password..."];
    
    NSString *newpassword1 = [self.nPasswordUITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *newpassword2 = [self.nPassword2UITextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [WebService ResetPasswordWithNewPassword:newpassword1 matchingPassword:newpassword2 usingKey:[[NSUserDefaults standardUserDefaults] objectForKey:@"forgot"]];
    
}
-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"ResetPassword"];
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
                [SVProgressHUD showSuccessWithStatus:
                 [dict objectForKey:@"Message"]];
                //[self dismissViewControllerAnimated:YES completion:nil];
                
                [[NSUserDefaults standardUserDefaults]
                 setObject:nil forKey:@"forgot"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
        else
        {
            // Operation failed. Check error to see why.
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:
                 [dict objectForKey:@"Message"]];
            }];
        }
    }
}
@end
