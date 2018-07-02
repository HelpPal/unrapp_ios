//
//  OrderDetailTableViewController.m
//  Unrapp
//
//  Created by Durish on 6/19/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "OrderDetailTableViewController.h"
#import "CheckoutBodyTableViewCell.h"
#import "CheckoutHeaderTableViewCell.h"
#import "WebService.h"
#import "SVProgressHUD.h"
@interface OrderDetailTableViewController ()

@end


NSArray *data;
@implementation OrderDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

-(void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"getGiftCardOrderDetail"
                                              object:nil];
    [SVProgressHUD showWithStatus:@"Gathering Order Info"];
    [WebService GetGiftCardOrderItemsfor:[[_passedData objectForKey:@"OrderID"] intValue]];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getGiftCardOrderDetail"
                                                  object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        if (data)
            return data.count;
        else
            return 0;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Configure the cell...
    if (indexPath.section == 0)
    {
        CheckoutHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
        cell.lblTotal.text = [NSString stringWithFormat:@"Total: $%.02f", [[_passedData objectForKey:@"OrderTotal"] doubleValue]];
        
        return cell;
    }
    else
    {
        CheckoutBodyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BodyCell" forIndexPath:indexPath];
        
        
            NSDictionary *tmp = [data objectAtIndex:indexPath.row];
            cell.lblWhat.text = [tmp objectForKey:@"Name"];
            cell.lblPrice.text = [NSString stringWithFormat:@"$%.02f", [[tmp objectForKey:@"Value"] doubleValue]];
        return cell;
    }
    
}

#pragma mark - WebService Return
-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getGiftCardOrderDetail"];
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
                data = [dict objectForKey:@"Items"];
                [SVProgressHUD dismiss];
                [self.tableView reloadData];
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
