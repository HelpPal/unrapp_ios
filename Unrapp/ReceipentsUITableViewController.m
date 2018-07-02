//
//  ReceipentsUITableViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 3/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "ReceipentsUITableViewController.h"
#import "WebService.h"

#import "SVProgressHUD.h"
#import "GiftReceipents.h"

@interface ReceipentsUITableViewController ()

@end

@implementation ReceipentsUITableViewController

extern UIImage *userImage;
bool useFilteredFriends;
NSMutableArray *currentlySelectedGiftReceipents;

bool shareToProfile = YES;
bool saveToPhotos = NO;
bool shareAll = NO;
double eachVal = 0.0f;
double max = 100.0f;
bool disabled = NO;
bool giftCard = NO;

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
    
    self.receipentsSearchBar.delegate = self;
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    currentlySelectedGiftReceipents = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //Reset Bools
    shareToProfile = YES;
    saveToPhotos = NO;
    shareAll = NO;
    disabled = NO;
    giftCard = NO;
    eachVal = 0.0f;
    
    GiftReceipents* selectedSentToView = [GiftReceipents getInstance];
    if([selectedSentToView getIsGiftCard])
    {
        _SendBtn.title = @"Next";
        disabled = YES;
        shareToProfile = NO;
        giftCard = YES;
        eachVal = [[[selectedSentToView getGiftValue] substringFromIndex:1] doubleValue];
    }
    else
    {
        _SendBtn.title = @"Send";
    }
    
    selectedSentToView = nil;
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    friends = nil;
    useFilteredFriends = false;
    
    [WebService getUserFriends];
    
    self.receipentsSearchBar.text=@"";
    
    [self.receipentsSearchBar setShowsCancelButton:NO animated:YES];
    [self.receipentsSearchBar resignFirstResponder];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"getUserFriends"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationSearch:)
                                                name:@"getUserFriendsSearch"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationSend:)
                                                name:@"InsertPictureGift"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationUpload:)
                                                name:@"ImageUpload"
                                              object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getUserFriends"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getUserFriendsSearch"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InsertPictureGift"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ImageUpload"
                                                  object:nil];
}
-(void)wsNotificationSend:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"InsertPictureGift"];
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
                GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
                if (saveToPhotos)
                {
                    UIImageWriteToSavedPhotosAlbum([selectedGiftImage getGiftImage], nil, nil, nil);
                }
                [selectedGiftImage setGiftImage:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
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
                [self.tableView reloadData];
                [SVProgressHUD dismiss];
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

-(void)wsNotificationSearch:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getUserFriendsSearch"];
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
                filteredFriends = [[dict objectForKey:@"Friends"] mutableCopy];
                useFilteredFriends = true;
                
                [self.tableView reloadData];
                
                [SVProgressHUD dismiss];
                
                [self.receipentsSearchBar setShowsCancelButton:NO animated:YES];
                [self.receipentsSearchBar resignFirstResponder];
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
    if (useFilteredFriends)
        return filteredFriends.count+3;
    else
        return friends.count+3;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Receipents";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Share Gift Image to Profile (once Unrapped)";
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        if (disabled)
            cell.textLabel.textColor = [UIColor grayColor];
        else
            cell.textLabel.textColor = [UIColor blackColor];
        
        if (shareToProfile)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Save Gift Image to Camera Roll";
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        if (disabled)
            cell.textLabel.textColor = [UIColor grayColor];
        else
            cell.textLabel.textColor = [UIColor blackColor];
        
        if (saveToPhotos)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Select All";
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        if (shareAll)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else
    {
        cell.textLabel.textColor = [UIColor blackColor];
        NSDictionary *user;
        if (useFilteredFriends)
        {
            user = [filteredFriends objectAtIndex:(indexPath.row-3)];
        }
        else
        {
            user = [friends objectAtIndex:(indexPath.row-3)];
        }
    
        cell.textLabel.text =  [@"" stringByAppendingFormat:@"%@ (%@ %@)", user[@"username"], user[@"firstName"], user[@"lastName"]];
        if ([currentlySelectedGiftReceipents containsObject:user])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType  = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (disabled && indexPath.row < 2)
        return indexPath;
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType  = UITableViewCellAccessoryNone;
        if (indexPath.row > 2)
        {
            if (useFilteredFriends)
            {
                [currentlySelectedGiftReceipents removeObject:[filteredFriends objectAtIndex:(indexPath.row-3)]];
            }
            else
            {
                [currentlySelectedGiftReceipents removeObject:[friends objectAtIndex:(indexPath.row-3)]];
            }
        }
        else if (indexPath.row == 0)
        {
            shareToProfile = NO;
        }
        else if (indexPath.row == 1)
            saveToPhotos = NO;
        else
        {
            shareAll = NO;
            [currentlySelectedGiftReceipents removeAllObjects];
        }
    }
    else
    {
        if (indexPath.row > 2)
        {
            if ((([currentlySelectedGiftReceipents count]+1)*eachVal) > max)
            {
                // show No Go
                [SVProgressHUD showErrorWithStatus:@"We're sorry the max purchase is $100, you can not select this friend as well."];
                return nil;
            }
            else
            {
                if (useFilteredFriends)
                {
                    [currentlySelectedGiftReceipents addObject:[filteredFriends objectAtIndex:(indexPath.row-3)]];
                }
                else
                {
                    [currentlySelectedGiftReceipents addObject:[friends objectAtIndex:(indexPath.row-3)]];
                }
            }
        }
        else if (indexPath.row == 0)
        {
            shareToProfile = YES;
        }
        else if (indexPath.row == 1)
        {
            saveToPhotos = YES;
        }
        else
        {
            if (useFilteredFriends)
            {
                if ((([filteredFriends count])*eachVal) > max)
                {
                    // show No Go
                    [SVProgressHUD showErrorWithStatus:@"We're sorry the max purchase is $100, you can not select all your friends."];
                    return nil;
                }
                else
                {
                    shareAll = YES;
                    currentlySelectedGiftReceipents = [filteredFriends mutableCopy];
                }
            }
            else
            {
                if ((([friends count])*eachVal) > max)
                {
                    // show No Go
                    [SVProgressHUD showErrorWithStatus:@"We're sorry the max purchase is $100, you can not select all your friends."];
                    return nil;
                }
                else
                {
                    shareAll = YES;
                    currentlySelectedGiftReceipents = [friends mutableCopy];
                }
            }
            
        }
        cell.accessoryType  = UITableViewCellAccessoryCheckmark;
        
    }
    
    
    [tableView reloadData];
    
    return indexPath;
}

#pragma mark - TableView Refresh

-(void)refresh
{
    [SVProgressHUD showWithStatus:@"Refreshing ..."];
    
    friends = nil;
    useFilteredFriends = false;
    
    [WebService getUserFriends];
    
    self.receipentsSearchBar.text=@"";
    
    [self.receipentsSearchBar setShowsCancelButton:NO animated:YES];
    [self.receipentsSearchBar resignFirstResponder];
    
    [self.refreshControl endRefreshing];
}

#pragma mark - Search Bar Actions

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    useFilteredFriends = false;
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [SVProgressHUD showWithStatus:@"Searching ..."];
    
    [WebService getUserFriendsWithSearch:searchBar.text];
}

#pragma mark - Actions

- (IBAction)sendButtonSelected:(id)sender
{
    
    if (currentlySelectedGiftReceipents.count == 0)
    {
        [SVProgressHUD showErrorWithStatus:@"No Recipients Selected."];
    }
    else
    {
        GiftReceipents* selectedSentToView = [GiftReceipents getInstance];
        if([selectedSentToView getIsGiftCard])
        {
            [selectedSentToView setSelectedGiftReceipents:currentlySelectedGiftReceipents];
            
            [self performSegueWithIdentifier:@"gotoReview" sender:self];
        }
        else
            [self uploadGift];
    }
    
}

#pragma mark - Actions Helpers

- (void) uploadGift
{
    [SVProgressHUD showWithStatus:@"Sending Gift ..."];
    
    GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
    
    // Get the image
    UIImage *image = [selectedGiftImage getGiftImage];
    [WebService UploadImage:image withName:@"giftImage"];
    
    
}

-(void)wsNotificationUpload:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"ImageUpload"];
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
            NSArray *selectedGiftReceipents = currentlySelectedGiftReceipents;
            
            NSMutableArray *userIDs = [[NSMutableArray alloc] init];
            for (NSDictionary *user in selectedGiftReceipents)
            {
                [userIDs addObject: user[@"userID"]];
            }
            
            // Send Gift...
            [WebService SendPictureGift:[dict objectForKey:@"Message"] toUser:userIDs andShare:shareToProfile withVersion:[[self appVersionNumber] doubleValue]];
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

- (NSNumber *)appVersionNumber {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSNumber *n =  [NSNumber numberWithDouble:[[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue]];
    
    return n;
}


@end
