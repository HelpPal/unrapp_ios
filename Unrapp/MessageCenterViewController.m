//
//  MessageCenterViewController.m
//  Unrapp
//
//  Created by Robert Durish on 2/21/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "MessageCenterViewController.h"

#import "SVProgressHUD.h"
#import "GiftReceipents.h"
#import "FriendsTableViewCell.h"
#import "JSBadgeView.h"
//#import "CHBadgeView.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import <Pushwoosh/PushNotificationManager.h>
#import <AVFoundation/AVFoundation.h>
#import "MPCoachMarks.h"

@interface MessageCenterViewController ()

@end

@implementation MessageCenterViewController

NSString *viewToShow = @"RECEIVED";
NSMutableArray *myGifts;
int ngc = 0;
int nrc = 0;
//UIRefreshControl *refreshControl;

int startX, startY, startW, startH;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumDismissTimeInterval:2.0];
    
    NSLog(@"Did Load");
    
    
    //refreshControl = [[UIRefreshControl alloc] init];
    //[refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    //[self.myTableView addSubview:refreshControl];
    
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    startW = self.myTableView.frame.size.width;
    startH = self.myTableView.frame.size.height;
    startX = self.myTableView.frame.origin.x;
    startY = 189; //self.myTableView.bounds.origin.y;
    
    //NSLog(@"Height: %i", startH);
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    //self.title = @"Back";
    
    UIViewController *v = [[UIViewController alloc] init];
    v.title = @"Send Gift";
    UITabBarItem *b = [[UITabBarItem alloc] initWithTitle:@"Send Gift" image:[UIImage imageNamed:@"gift_off"] selectedImage:[UIImage imageNamed:@"gift_on"]];
    
    [v setTabBarItem:b];
    
    NSMutableArray * vcs = [NSMutableArray
                            arrayWithArray:[self.tabBarController viewControllers]];
    [vcs addObject:v];
    [self.tabBarController setViewControllers:vcs];
    
    self.tabBarController.delegate = self;
    
    
    
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if ([viewController.title isEqualToString:@"Send Gift"])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Select Gift Type"
                                      delegate:self
                                      cancelButtonTitle: @"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles: @"Take Picture", @"Send Gift Card",@"Photo Gallery", nil];
        
        [actionSheet showInView:self.view];
        return NO;
    }
    else
        return YES;
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    NSNumber *b = [NSNumber numberWithBool:[WebService getLoggedInUser].disabled];
    
    if ([buttonTitle isEqualToString:@"Take Picture"]) {
        
        
        [self.tabBarController setSelectedIndex:0];
        
        if ([b boolValue])
        {
            [SVProgressHUD showErrorWithStatus:@"Please enable your account to send items."];
        }
        else
        {
        // Save the image gift before selecting the receipents
        GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
        [selectedGiftImage setGiftImage:nil];
        [selectedGiftImage setIsTakePicture:YES];
        [selectedGiftImage setIsChoosePicture:NO];
        
        [self performSegueWithIdentifier:@"TakePicture2" sender:self];
        }
    }
    if ([buttonTitle isEqualToString:@"Photo Gallery"]) {
        
        
        [self.tabBarController setSelectedIndex:0];
        
        if ([b boolValue])
        {
            [SVProgressHUD showErrorWithStatus:@"Please enable your account to send items."];
        }
        else
        {
        // Save the image gift before selecting the receipents
        GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
        // Choose Picture
        [selectedGiftImage setGiftImage:nil];
        [selectedGiftImage setIsTakePicture:NO];
        [selectedGiftImage setIsChoosePicture:YES];
        
        [self performSegueWithIdentifier:@"ChoosePicture2" sender:self];
        }
        
    }
    if ([buttonTitle isEqualToString:@"Send Gift Card"]) {
        
        
        [self.tabBarController setSelectedIndex:0];
        
        if ([b boolValue])
        {
            [SVProgressHUD showErrorWithStatus:@"Please enable your account to send items."];
        }
        else
        {
            // Save the image gift before selecting the receipents
            GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
            // Choose Picture
            [selectedGiftImage setGiftImage:nil];
            [selectedGiftImage setIsTakePicture:NO];
            [selectedGiftImage setIsChoosePicture:NO];
            
            [self performSegueWithIdentifier:@"gcPush" sender:self];
        }
        
        
    }
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}

-(void) viewWillAppear:(BOOL)animated
{
    NSLog(@"Will Appear");
    //self.myTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:24 green:189 blue:243 alpha:1]];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"Did Appear");
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"getMessageCenterGifts"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationRefresh:)
                                                name:@"RefreshUserLogin"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationDelete:)
                                                name:@"DeleteGift"
                                              object:nil];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"forgot"])
    {
        
    }
    else
    {
    NSIndexPath *ip = self.myTableView.indexPathForSelectedRow;
    if (ip)
    {
        [self.myTableView deselectRowAtIndexPath:ip animated:YES];
    }
    
    if ([viewToShow isEqualToString:@"RECEIVED"])
    {
        [self touchReceived:nil];
    }
    else if ([viewToShow isEqualToString:@"RESPONSES"])
    {
        [self touchResponses:nil];
    }
    else
    {
        [self touchSend:nil];
    }
    }
    
    
}

-(void)getTraining
{
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"MPCoachMarksShownMSGCenter"];
    if (coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MPCoachMarksShownMSGCenter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        CGRect btnSpot = self.parentViewController.tabBarController.tabBar.frame;
        btnSpot = CGRectMake(btnSpot.origin.x + ((btnSpot.size.width / 4) * 3), btnSpot.origin.y, btnSpot.size.width / 4, btnSpot.size.height);
        //Setup Marks...
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnReceived.frame],
                                    @"caption" :@"Tapping this icon will display your gifts from friends."
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnResponses.frame],
                                    @"caption" :@"Responses tab will show video reactions from friends."
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:_btnSend.frame],
                                    @"caption" :@"Tapping \"Send Gift\" will allow you to send new gifts to friends.",
                                    @"position" :@"LABEL_POSITION_LEFT"
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:btnSpot],
                                    @"caption" :@"Tapping \"Send Gift\" will allow you to send new gifts to friends.",
                                    @"position" :@"LABEL_POSITION_TOP"
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:self.myTableView.frame],
                                    @"caption" :@"Tap a gift from the list below to start Unrapping!"
                                    }
                            ];
        
        MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
        
        [self.tabBarController.view addSubview:coachMarksView];
        
        // Show coach marks
        [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:0.5f];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"Will Disapear");
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getMessageCenterGifts"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"RefreshUserLogin"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DeleteGift"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)wsNotificationDelete:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"DeleteGift"];
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
           [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
            [self refresh];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
}

-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getMessageCenterGifts"];
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
            
            myGifts = [[dict objectForKey:@"Gifts"] mutableCopy];
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [self.myTableView reloadData];
            }];
            
            ngc = [[dict objectForKey:@"NewGifts"] intValue];
            nrc = [[dict objectForKey:@"NewResponses"] intValue];
            
            // Set Matching Badge Number
            [UIApplication sharedApplication].applicationIconBadgeNumber = (ngc + nrc);
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:(ngc + nrc)];
            
            if (myGifts.count == 0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                    [SVProgressHUD showSuccessWithStatus:@"No Data found."];
                }];
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                    [SVProgressHUD dismiss];
                    
                }];
            }
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
        
        // Get Counts for tabs...
          [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        if (![viewToShow isEqualToString:@"RECEIVED"])
        {
            
            if (!badgeView1)
            {
                badgeView1 = [[JSBadgeView alloc] initWithParentView:self.btnReceived alignment:JSBadgeViewAlignmentCenterLeft];
                
            }
            if (ngc > 0) {
                badgeView1.badgeText = [NSString stringWithFormat:@"%d", ngc ];
//                badgeView1.badgeBorderColor = [UIColor redColor];
//                badgeView1.badgeColor = [UIColor blackColor];
//                badgeView1.badgeBorderWidth =0.5f;
//                badgeView1.drawBadgeBorder = YES;
//                badgeView1.badgeCornerRadius = 4.0;
//                badgeView1.bottomArrowHeight = 10.0f;
//                badgeView1.badgeLabel.text = [NSString stringWithFormat:@"%d", ngc ];
                badgeView1.hidden = NO;
            }
            else
            {
                badgeView1.hidden = YES;
            }
        }
        else
        {
            badgeView1.hidden = YES;
        }
        
        if (![viewToShow isEqualToString:@"RESPONSES"])
        {
            if (!badgeView2)
                
            {
                badgeView2 = [[JSBadgeView alloc] initWithParentView:self.btnResponses alignment:JSBadgeViewAlignmentCenterLeft];
                //badgeView2 = [[CHBadgeView alloc] init];
                //[self.btnResponses addSubview:badgeView2];
            }
                
            if (nrc > 0)
            {
                badgeView2.badgeText = [NSString stringWithFormat:@"%d", nrc ];
//                badgeView2.badgeBorderColor = [UIColor redColor];
//                badgeView2.badgeColor = [UIColor blackColor];
//                badgeView2.badgeBorderWidth =0.5f;
//                badgeView2.drawBadgeBorder = YES;
//                badgeView2.badgeCornerRadius = 4.0;
//                badgeView2.bottomArrowHeight = 10.0f;
//                badgeView2.badgeLabel.text =  [NSString stringWithFormat:@"%d", nrc ];
                badgeView2.hidden = NO;
            }
            else
            {
                badgeView2.hidden = YES;
            }
        }
        else
        {
            badgeView2.hidden = YES;
        }
          }];
    }
    
}

-(void)wsNotificationRefresh:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"RefreshUserLogin"];
    if (!dict)
    {
        //[[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
        //    [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        //}];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
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
            NSLog(@"User Refreshed");
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([viewToShow isEqualToString:@"RECEIVED"])
    {
     //   GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    }
    else if ([viewToShow isEqualToString:@"RECEIVED"])
    {
    //    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    }
    else
    {
        
    }
}


#pragma mark - Action Buttons
- (IBAction)touchReceived:(id)sender {
    self.myTableView.translatesAutoresizingMaskIntoConstraints = NO;
    CGRect frame = self.myTableView.frame;
    frame.origin.y = 189; // new y coordinate
    frame.size.height = [[UIScreen mainScreen] bounds].size.height - 195 - [UITabBar appearance].bounds.size.height - 60; //startH;
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        self.myTableView.frame = frame;
        [self getTraining];
    }];
    self.filterUISegmentedControl.hidden = NO;
    self.btnChoosePic.hidden = YES;
    self.btnTakePic.hidden = YES;
    self.btnGiftCard.hidden = YES;
    if (![viewToShow isEqualToString:@"RECEIVED"])
        [self.filterUISegmentedControl setSelectedSegmentIndex:0];
    
    
    viewToShow = @"RECEIVED";
    [self refresh];
}
- (IBAction)touchResponses:(id)sender {
    self.myTableView.translatesAutoresizingMaskIntoConstraints = NO;
    CGRect frame = self.myTableView.frame;
    frame.origin.y = 189; // new y coordinate
    frame.size.height = [[UIScreen mainScreen] bounds].size.height - 195 - [UITabBar appearance].bounds.size.height - 60; //startH;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        self.myTableView.frame = frame;
    }];
    
    self.filterUISegmentedControl.hidden = NO;
    self.btnChoosePic.hidden = YES;
    self.btnTakePic.hidden = YES;
    self.btnGiftCard.hidden = YES;
    
    if (![viewToShow isEqualToString:@"RESPONSES"])
        [self.filterUISegmentedControl setSelectedSegmentIndex:0];
    
    viewToShow = @"RESPONSES";
    [self refresh];
}
- (IBAction)touchSend:(id)sender {
    self.myTableView.translatesAutoresizingMaskIntoConstraints = NO;
    CGRect frame = self.myTableView.frame;
    frame.origin.y = 265; // new y coordinate
    frame.size.height = [[UIScreen mainScreen] bounds].size.height - 265 - [UITabBar appearance].bounds.size.height - 60; //startH; //(265 - startY);
    
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        self.myTableView.frame = frame;
    }];
    [self.myTableView reloadInputViews];
    
    self.btnChoosePic.hidden = NO;
    self.btnTakePic.hidden = NO;
    self.btnGiftCard.hidden = NO;
    self.filterUISegmentedControl.hidden = YES;
    viewToShow = @"SENT";
    [self refresh];
}

-(void) setButtonForScreen
{
    if ([viewToShow isEqualToString:@"RECEIVED"])
    {
        [self.btnReceived setImage:[UIImage imageNamed:@"messagecenter_received_on.png"] forState:UIControlStateNormal];
        [self.btnResponses setImage:[UIImage imageNamed:@"messagecenter_responses_off.png"] forState:UIControlStateNormal];
        [self.btnSend setImage:[UIImage imageNamed:@"messagecenter_send_off.png"] forState:UIControlStateNormal];
    }
    else if ([viewToShow isEqualToString:@"RESPONSES"])
    {
        [self.btnReceived setImage:[UIImage imageNamed:@"messagecenter_received_off.png"] forState:UIControlStateNormal];
        [self.btnResponses setImage:[UIImage imageNamed:@"messagecenter_responses_on.png"] forState:UIControlStateNormal];
        [self.btnSend setImage:[UIImage imageNamed:@"messagecenter_send_off.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.btnReceived setImage:[UIImage imageNamed:@"messagecenter_received_off.png"] forState:UIControlStateNormal];
        [self.btnResponses setImage:[UIImage imageNamed:@"messagecenter_responses_off.png"] forState:UIControlStateNormal];
        [self.btnSend setImage:[UIImage imageNamed:@"messagecenter_send_on.png"] forState:UIControlStateNormal];
    }
}

- (IBAction)touchRefresh:(id)sender {
    [self refresh];
}

- (void) logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    WSUser *u = [WebService getLoggedInUser];
    [CrashlyticsKit setUserIdentifier:u.userID];
    [CrashlyticsKit setUserEmail:u.email];
    [CrashlyticsKit setUserName:u.username];
}

#pragma mark - Load Data
#pragma mark - TableView Refresh
JSBadgeView *badgeView1;
JSBadgeView *badgeView2;

-(void)refresh
{
    if ([WebService getLoggedInUser])
    {
        [SVProgressHUD showWithStatus:@"Loading"];
        
        [WebService refreshUser];
        
        //Set Crashalytics Info..
        [self logUser];
        
        [self setButtonForScreen];
        
    if ([viewToShow isEqualToString:@"RECEIVED"])
    {
        // Get all of this user's gifts
        [SVProgressHUD showWithStatus:@"Retreiving Gifts"];
        
        [WebService getMessageCenterFor:viewToShow and:([self.filterUISegmentedControl selectedSegmentIndex] == 0) greaterThan:0];
        
    } else if ([viewToShow isEqualToString:@"RESPONSES"])
    {
        // Get all of this user's gift responses
        [SVProgressHUD showWithStatus:@"Retreiving Responses"];
        
        [WebService getMessageCenterFor:viewToShow and:([self.filterUISegmentedControl selectedSegmentIndex] == 0) greaterThan:0];
    }
    else
    {
        // Get all of this user's sent gifts
        [SVProgressHUD showWithStatus:@"Retreiving Sent"];
        
        [WebService getMessageCenterFor:viewToShow and:([self.filterUISegmentedControl selectedSegmentIndex] == 0) greaterThan:0];
    }
        
        // register for push notifications!
        [[PushNotificationManager pushManager] registerForPushNotifications];
        
}
    else
    {
        
        // User logged in
        [self performSegueWithIdentifier: @"LogIn" sender: self];
        
    }
    //[refreshControl endRefreshing];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([viewToShow isEqualToString:@"RECEIVED"] && [self.filterUISegmentedControl selectedSegmentIndex] == 0)
        return myGifts.count + 1;
    else
        return myGifts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"data";
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    
    if ([viewToShow isEqualToString:@"RECEIVED"])
    {
        if ([self.filterUISegmentedControl selectedSegmentIndex] == 0)
        {
            if (indexPath.row == 0)
            {
                cell.friendUIImage.image = nil;
                cell.nameUILabel.text = @"";
                cell.locationUILabel.text = @"";
                cell.textLabel.text = @"Redeem Unrapp Code";
                cell.backgroundColor = [UIColor whiteColor];
            }
            else
            {
                [cell setImageURL:[[myGifts objectAtIndex:indexPath.row-1] objectForKey:@"SenderImage"]];
                cell.nameUILabel.text = [[myGifts objectAtIndex:indexPath.row-1] objectForKey:@"SenderUsername"];
                cell.locationUILabel.text = [[myGifts objectAtIndex:indexPath.row-1] objectForKey:@"createdAt"];
                
                if ([[[myGifts objectAtIndex:indexPath.row-1] objectForKey:@"FileType"] isEqualToString:@"GIFTCARD"])
                    cell.backgroundColor = [UIColor colorWithRed:252.0/255.0
                                                           green:194.0/255.0 blue:0 alpha:1.0];
                else
                    cell.backgroundColor = [UIColor whiteColor];
                
                
                cell.textLabel.text = @"";
            }
        }
        else
        {
        [cell setImageURL:[[myGifts objectAtIndex:indexPath.row] objectForKey:@"SenderImage"]];
        cell.nameUILabel.text = [[myGifts objectAtIndex:indexPath.row] objectForKey:@"SenderUsername"];
        cell.locationUILabel.text = [[myGifts objectAtIndex:indexPath.row] objectForKey:@"createdAt"];
            
            if ([[[myGifts objectAtIndex:indexPath.row] objectForKey:@"FileType"] isEqualToString:@"GIFTCARD"])
                cell.backgroundColor = [UIColor colorWithRed:252.0/255.0
                                                       green:194.0/255.0 blue:0 alpha:1.0];
            else
                cell.backgroundColor = [UIColor whiteColor];
            
            cell.textLabel.text = @"";
        }
    }
    else if ([viewToShow isEqualToString:@"RESPONSES"])
    {
        [cell setImageURL:[[myGifts objectAtIndex:indexPath.row] objectForKey:@"SenderImage"]];
        cell.nameUILabel.text = [[myGifts objectAtIndex:indexPath.row] objectForKey:@"RecipientUsername"];
        cell.locationUILabel.text = [[myGifts objectAtIndex:indexPath.row] objectForKey:@"ResponseSent"];
        
        if ([[[myGifts objectAtIndex:indexPath.row] objectForKey:@"FileType"] isEqualToString:@"GIFTCARD"])
            cell.backgroundColor = [UIColor colorWithRed:252.0/255.0
                                                   green:194.0/255.0 blue:0 alpha:1.0];
        else
            cell.backgroundColor = [UIColor whiteColor];
        
        cell.textLabel.text = @"";
    }
    else
    {
        [cell.indicator stopAnimating];
        cell.indicator.hidden = YES;
        if ([[myGifts objectAtIndex:indexPath.row] objectForKey:@"isNewGift"] == [NSNumber numberWithBool:YES])
        {
            [cell setImage: [UIImage imageNamed:@"sent.png"]]; // New
        }
        else if ([[[myGifts objectAtIndex:indexPath.row] objectForKey:@"VideoResponseURL"] isEqualToString: @""])
        {
            [cell setImage: [UIImage imageNamed:@"unrapped.png"]]; // Unrapped but no response
        }
        else
        {
            [cell setImage: [UIImage imageNamed:@"responded.png"]];  // Response Sent
        }
        
        cell.nameUILabel.text = [[myGifts objectAtIndex:indexPath.row] objectForKey:@"RecipientUsername"];
        cell.locationUILabel.text = [[myGifts objectAtIndex:indexPath.row] objectForKey:@"createdAt"];
        
        if ([[[myGifts objectAtIndex:indexPath.row] objectForKey:@"FileType"] isEqualToString:@"GIFTCARD"])
            cell.backgroundColor = [UIColor colorWithRed:252.0/255.0
                                                   green:194.0/255.0 blue:0 alpha:1.0];
        else
            cell.backgroundColor = [UIColor whiteColor];
        
        
        cell.textLabel.text = @"";
    }
    
    
    
    
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    
    if ([viewToShow isEqualToString:@"RECEIVED"])
        if ([viewToShow isEqualToString:@"RECEIVED"] && [self.filterUISegmentedControl selectedSegmentIndex] == 0)
        {
            if (indexPath.row > 0)
                [selectedGiftToView setSelectedGiftToView:[myGifts objectAtIndex:indexPath.row-1]];
        }
    else
    {
        [selectedGiftToView setSelectedGiftToView:[myGifts objectAtIndex:indexPath.row]];
    }
    else if ([viewToShow isEqualToString:@"RESPONSES"])
        [selectedGiftToView setSelectedSentToView:[myGifts objectAtIndex:indexPath.row]];
    else
        [selectedGiftToView setSelectedGiftToView:[myGifts objectAtIndex:indexPath.row]];
    
    
    return indexPath;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([viewToShow isEqualToString:@"RECEIVED"])
    {
        if (indexPath.row == 0)
            return NO;
        else
            return YES;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([viewToShow isEqualToString:@"RECEIVED"])
    {
        
        if ([viewToShow isEqualToString:@"RECEIVED"] && [self.filterUISegmentedControl selectedSegmentIndex] == 0 && indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"unrappCode" sender:self];
        }
        else
        {
        
        // Check for Camera Access
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        //CHECK FOR MICROPHONE ACCESS
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
           
        }];
        
            [self performSegueWithIdentifier:@"myGiftSegue" sender:self];
        }
    }
    else if ([viewToShow isEqualToString:@"RESPONSES"])
        [self performSegueWithIdentifier:@"responseSegue" sender:self];
    else
        [self performSegueWithIdentifier:@"viewSent" sender:self];
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:@"Deleting Gift ..."];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if ([viewToShow isEqualToString:@"RECEIVED"])
        {
            NSDictionary *giftToDelete = [myGifts objectAtIndex:indexPath.row - 1];
            [WebService DeleteGift:[[giftToDelete objectForKey:@"GiftID"] intValue] forView:viewToShow];
        }
        else
        {
            NSDictionary *giftToDelete = [myGifts objectAtIndex:indexPath.row];
            [WebService DeleteGift:[[giftToDelete objectForKey:@"GiftID"] intValue] forView:viewToShow];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}


#pragma marks - Action Methods

- (IBAction)filterSelected:(id)sender
{
    [self refresh];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSNumber *b = [NSNumber numberWithBool:[WebService getLoggedInUser].disabled];
    
    
    if ([identifier isEqualToString:@"TakePicture"] || [identifier isEqualToString:@"TakePicture2"])
    {
        if ([b boolValue])
        {
            [SVProgressHUD showErrorWithStatus:@"Please enable your account to send items."];
            return NO;
        }
        // Save the image gift before selecting the receipents
        GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
        [selectedGiftImage setGiftImage:nil];
        [selectedGiftImage setIsTakePicture:YES];
        [selectedGiftImage setIsChoosePicture:NO];
    }
    else if([identifier isEqualToString:@"ChoosePicture"] || [identifier isEqualToString:@"ChoosePicture2"])
    {
        if ([b boolValue])
        {
            [SVProgressHUD showErrorWithStatus:@"Please enable your account to send items."];
            return NO;
        }
        // Save the image gift before selecting the receipents
        GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
        // Choose Picture
        [selectedGiftImage setGiftImage:nil];
        [selectedGiftImage setIsTakePicture:NO];
        [selectedGiftImage setIsChoosePicture:YES];
    }
    return YES;
}

@end
