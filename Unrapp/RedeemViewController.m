//
//  RedeemViewController.m
//  Unrapp
//
//  Created by Durish on 7/2/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "RedeemViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"

@interface RedeemViewController ()

@end

@implementation RedeemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// CheckRedeemKey
-(void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"CheckRedeemKey"
                                              object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"CheckRedeemKey"
                                                  object:nil];
}

- (IBAction)Check_Code_Click:(id)sender {
    [SVProgressHUD showWithStatus:@"Checking Redemption Code..."];
    [WebService CheckGiftCode:self.txtCode.text];
}

#pragma mark - WebService Return
-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"CheckRedeemKey"];
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
                
                // Pop View Controller
                [self.navigationController popToRootViewControllerAnimated:YES];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
