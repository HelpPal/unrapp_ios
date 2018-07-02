//
//  OrdersTableViewController.m
//  Unrapp
//
//  Created by Durish on 6/18/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "OrdersTableViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "OrdersTableViewCell.h"
#import "OrderDetailTableViewController.h"

@interface OrdersTableViewController ()

@end
NSArray *data;
NSDictionary *selectedData;

@implementation OrdersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
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

- (void)refresh
{
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    data = nil;
    
    [WebService GetGiftCardOrders];
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
                                                name:@"getGiftCardOrders"
                                              object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getGiftCardOrders"
                                                  object:nil];
}

#pragma mark - WebService Return
-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getGiftCardOrders"];
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
                data = [[dict objectForKey:@"Orders"] mutableCopy];
                if (data.count > 0)
                {
                    [self.tableView reloadData];
                    [SVProgressHUD dismiss];
                }
                else
                {
                    [SVProgressHUD showInfoWithStatus:@"You have no Orders at this time!"];
                    
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell" forIndexPath:indexPath];
    
    NSDictionary *dict = [data objectAtIndex:indexPath.row];
    
    // Configure the cell...
    cell.dateLabel.text = [dict objectForKey:@"OrderDate"];
    cell.costLabel.text = [@"$" stringByAppendingString:[[dict objectForKey:@"OrderTotal"] stringValue]];
    
    
    // Define general attributes for the entire text
    NSString *text = [NSString stringWithFormat:@"%@ \nCard(s)",
                      [[dict objectForKey:@"ItemCount"] stringValue]];
    
    
    UIFont *smallFont = [UIFont fontWithName:@"System Font Regular" size:9.0];
    NSDictionary *attribs = @{
                              NSForegroundColorAttributeName: cell.countLabel.textColor,
                              NSFontAttributeName: smallFont
                              };
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:text
                                           attributes:attribs];
    
    // Red text attributes
    UIFont *bigFont = [UIFont fontWithName:@"System Font Regular" size:20.0];
    NSRange bigTextRange = [text rangeOfString:[[dict objectForKey:@"ItemCount"] stringValue]];
    
    [attributedText setAttributes:@{NSFontAttributeName:bigFont}
                            range:bigTextRange];
    
    
    
    cell.countLabel.attributedText = attributedText; //[dict objectForKey:@"ItemCount"];
    //cell.detailTextLabel.text = [dict objectForKey:@"Value"];
    cell.countLabel.layer.cornerRadius = 15.0;
    cell.countLabel.clipsToBounds = true;
    
    return cell;
}

#pragma mark - Navigation
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedData = [data objectAtIndex:indexPath.row];
    
    // By default, allow row to be selected
    return indexPath;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"details" sender:self];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    OrderDetailTableViewController *d = (OrderDetailTableViewController*)[segue destinationViewController];
    if (d)
        d.passedData = selectedData;
}


@end
