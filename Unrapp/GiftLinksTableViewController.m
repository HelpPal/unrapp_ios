//
//  GiftLinksTableViewController.m
//  Unrapp
//
//  Created by Durish on 5/21/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "GiftLinksTableViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "GCLinkTableViewCell.h"

@interface GiftLinksTableViewController ()

@end
NSArray *data;

@implementation GiftLinksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
}

- (void)refresh
{
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    data = nil;
    
    [WebService GetOpenedGiftCards];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refresh];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"getOpenedGiftCards"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationDelete:)
                                                name:@"DeleteGift"
                                              object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getOpenedGiftCards"
                                                  object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DeleteGift"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebService Return
-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getOpenedGiftCards"];
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
                data = [[dict objectForKey:@"Cards"] mutableCopy];
                if (data.count > 0)
                {
                    [self.tableView reloadData];
                    [SVProgressHUD dismiss];
                }
                else
                {
                    [SVProgressHUD showInfoWithStatus:@"You have no Gift Cards at this time!"];
                    
                }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GCLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"giftCell" forIndexPath:indexPath];
    
    NSDictionary *dict = [data objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.MainText.text = [dict objectForKey:@"Name"];
    cell.SubText.text = [dict objectForKey:@"DateSent"];
    //cell.detailTextLabel.text = [dict objectForKey:@"Value"];
    
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[data objectAtIndex:indexPath.row] objectForKey:@"Link"]]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD showWithStatus:@"Deleting Gift ..."];
    
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary *giftToDelete = [data objectAtIndex:indexPath.row];
        [WebService DeleteGift:[[giftToDelete objectForKey:@"GiftID"] intValue] forView:@"CARD"];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
}

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
