//
//  GiftCardTableViewController.m
//  Unrapp
//
//  Created by Durish on 4/26/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "GiftCardTableViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "GiftCardTableViewCell.h"
#import "GiftReceipents.h"

@interface GiftCardTableViewController ()

@end

@implementation GiftCardTableViewController
NSArray *results;
NSDictionary *data;
BOOL forwarded;

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
    forwarded = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    results = nil;
    
    [WebService GetGiftCardsForVendor:[self.passedData[@"id"] intValue]];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"getGiftCards"
                                              object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getGiftCards"
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - WebService Return
-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getGiftCards"];
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
                results = [[dict objectForKey:@"GiftCardItems"] mutableCopy];
                if (results.count == 1 && !forwarded)
                {
                    data = [results objectAtIndex:0];
                    forwarded = YES;
                    [self performSegueWithIdentifier:@"getDetails" sender:self];
                }
                else
                    [self.tableView reloadData];
                [SVProgressHUD dismiss];
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
    return results.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GiftCardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellCard" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.nameUILabel.text = [results objectAtIndex:indexPath.row][@"name"];
    [cell setImageURL:[results objectAtIndex:indexPath.row][@"image_url"]];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    data = [results objectAtIndex:indexPath.row];
    
    // By default, allow row to be selected
    return indexPath;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Select a Gift Card";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"getDetails" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    GiftReceipents* s = [GiftReceipents getInstance];
    [s setIsGiftCard:YES];
    [s setSelectedGiftCard:data];
    
}
@end
