//
//  FriendsViewController.m
//  Unrapp
//
//  Created by Robert Durish on 2/16/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsTableViewCell.h"
#include "ProfileViewController.h"
#include "WebService.h"

#import "SVProgressHUD.h"
#import "MPCoachMarks.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

UIRefreshControl *refreshControl;
NSDictionary *selectedFriend;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.myTableView addSubview:refreshControl];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // Deselect any selected rows...
    NSIndexPath *ip = self.myTableView.indexPathForSelectedRow;
    if (ip)
    {
        [self.myTableView deselectRowAtIndexPath:ip animated:YES];
    }
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    @try {
        if (friends)
            [friends removeAllObjects];
    } @catch (NSException *exception) {
        //
    } @finally {
        //
    }
    
    
    
    
    [WebService getUserFriends];
    
}

-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getUserFriends"];
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
                friends = [[dict objectForKey:@"Friends"] mutableCopy];
                [self.myTableView reloadData];
                [SVProgressHUD dismiss];
                [self getTraining];
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:
                 [dict objectForKey:@"Message"]];
            }];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"getUserFriends"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationDelete:)
                                                name:@"DeleteFriend"
                                              object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getUserFriends"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DeleteFriend"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Friends";
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *user = [friends objectAtIndex:indexPath.row];
    cell.nameUILabel.text =  [@"" stringByAppendingFormat:@"%@ %@ (%@)", user[@"firstName"], user[@"lastName"], user[@"username"]];
    [cell setImageURL:user[@"userImage"]];
    cell.messageUILabel.hidden=YES;
    cell.locationUILabel.text = user[@"location"];
    
    return cell;
}

#pragma mark - Table View Editing

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:@"Deleting Friend ..."];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary *user = [friends objectAtIndex:indexPath.row];
        [WebService removeUserFriend:[[user objectForKey:@"userID"] intValue]];
    }
}

-(void)wsNotificationDelete:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"DeleteFriend"];
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
            // refresh list..
            [friends removeAllObjects];
            [WebService getUserFriends];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:
                 [dict objectForKey:@"Message"]];
            }];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedFriend = [friends objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"viewProfile" sender:self];
}

#pragma mark - TableView Refresh

-(void)refresh
{
    [SVProgressHUD showWithStatus:@"Refreshing ..."];
    
    [friends removeAllObjects];
    
    [WebService getUserFriends];
    
    [refreshControl endRefreshing];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewProfile"])
    {
        ProfileViewController *dest = (ProfileViewController *)[segue destinationViewController];
        
        dest.passedUser = selectedFriend;
        
    }
}

-(void)getTraining
{
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"MPCoachMarksShownFriends"];
    if (coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MPCoachMarksShownFriends"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Setup Marks...
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:CGRectMake([[UIScreen mainScreen] bounds].size.width - 50, 20, 40, 40)],
                                    @"caption" :@"Tapping this icon will allow you to add friends or search for friends from phonebook."
                                    }
                                ];
        //CGRectMake(x, y, w, h)
        
        MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
        
        [self.tabBarController.view addSubview:coachMarksView];
        
        // Show coach marks
        [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:0.5f];
    }
}


@end
