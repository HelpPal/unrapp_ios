//
//  AddFriendsViewController.m
//  Unrapp
//
//  Created by Robert Durish on 2/17/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "FriendsTableViewCell.h"
#import "SVProgressHUD.h"
#import "WebService.h"
#import <Social/Social.h>
#import "MPCoachMarks.h"

@interface AddFriendsViewController ()

@end

@implementation AddFriendsViewController

NSArray *friends;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.friendsSearchBar.delegate = self;
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    // Clear previous searches
    friends = nil;
    [self.myTableView reloadData];
    
    self.friendsSearchBar.text=@"";
    
    [self.friendsSearchBar setShowsCancelButton:NO animated:YES];
    [self.friendsSearchBar resignFirstResponder];
    
    [self getTraining];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"SearchUsers"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationPhone:)
                                                name:@"SearchUsersPhone"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationFriendAdd:)
                                                name:@"AddFriend"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationFriendDelete:)
                                                name:@"DeleteFriend"
                                              object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"SearchUsers"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"SearchUsersPhone"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"AddFriend"
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
    if (friends)
        return friends.count;
    else
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddFriends";
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    if (friends)
    {
        
        cell.friendUIImage.hidden = NO;
        cell.locationUILabel.hidden = NO;
        cell.nameUILabel.hidden = NO;
        cell.messageUILabel.hidden = YES;
        cell.actionUILabel.hidden = YES;
        
        NSDictionary *user = [friends objectAtIndex:indexPath.row];
        cell.nameUILabel.text =  [@"" stringByAppendingFormat:@"%@ %@ (%@)", user[@"firstName"], user[@"lastName"], user[@"username"]];
        [cell setImageURL:user[@"userImage"]];
        cell.messageUILabel.hidden=YES;
        cell.locationUILabel.text = user[@"location"];
        NSNumber * isFriend = (NSNumber *)user[@"isFriend"];
        if ([isFriend boolValue])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        cell.friendUIImage.hidden = YES;
        cell.locationUILabel.hidden = YES;
        cell.nameUILabel.hidden = YES;
        cell.actionUILabel.hidden = YES;
        cell.messageUILabel.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (friends)
    {
        [SVProgressHUD showWithStatus:@"Updating ..."];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NSDictionary *user = [friends objectAtIndex:indexPath.row];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            [WebService removeUserFriend:[[user objectForKey:@"userID"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            [WebService addUserFriend:[[user objectForKey:@"userID"] intValue]];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Checking Permissions ..."];
        // Search Phonebook!
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
        // New rules require asking permission for the contact book -RD.
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied || ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
        {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self showAddressBookFriends];
                }
                else
                {
                    [SVProgressHUD dismiss];
                    // Show message.
                    UIAlertView *noPermissionAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Access Contacts" message: @"You must give the app permission to view your contacts to use this feature." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                    [noPermissionAlert show];
                }
            });
            
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
        {
            [self showAddressBookFriends];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Loading..."];
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self showAddressBookFriends];
                }
                else
                {
                    [SVProgressHUD dismiss];
                    // Show message.
                    UIAlertView *noPermissionAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Access Contacts" message: @"You must give the app permission to view your contacts to use this feature." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                    [noPermissionAlert show];
                }
            });
        }
    }
    
    return indexPath;
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
    
    friends = nil;
    [self.myTableView reloadData];
}

-(void)wsNotificationFriendAdd:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"AddFriend"];
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
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [self.myTableView reloadData];
                [SVProgressHUD showErrorWithStatus:
                 [dict objectForKey:@"Message"]];
            }];
        }
    }
}

-(void)wsNotificationFriendDelete:(NSNotification *)notification
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
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showSuccessWithStatus:
                 [dict objectForKey:@"Message"]];
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [self.myTableView reloadData];
                [SVProgressHUD showErrorWithStatus:
                 [dict objectForKey:@"Message"]];
            }];
        }
    }
}

-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"SearchUsers"];
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
                friends = nil;
                friends = [dict objectForKey:@"Users"];
                [self.myTableView reloadData];
                if (friends.count == 0)
                {
                    [SVProgressHUD showErrorWithStatus:@"No Friends match your search, try to invite them!"];
                }
                else
                {
                    [SVProgressHUD dismiss];
                }
                
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

-(void)wsNotificationPhone:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"SearchUsersPhone"];
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
                friends = nil;
                friends = [dict objectForKey:@"Users"];
                [self.myTableView reloadData];
                if (friends.count == 0)
                {
                    [SVProgressHUD showErrorWithStatus:@"No Friends match your search, try to invite them!"];
                }
                else
                {
                    [SVProgressHUD dismiss];
                }
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [SVProgressHUD showWithStatus:@"Searching..."];
    
    [WebService searchUsers:searchBar.text];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

- (void) showAddressBookFriends
{
    [SVProgressHUD showWithStatus:@"Checking Phonebook and Searching ..."];
    
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    
    // get and loop through phone numbers - BEGIN
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    NSArray *allContacts = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    for (id record in allContacts)
    {
        ABRecordRef thisContact = (__bridge ABRecordRef)record;
        ABMultiValueRef phoneNumbersRef = ABRecordCopyValue(thisContact, kABPersonPhoneProperty);
        if (ABMultiValueGetCount(phoneNumbersRef) > 0)
        {
            for (int i = 0; i < ABMultiValueGetCount(phoneNumbersRef) ; i++) {
                NSString *phoneNumber = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbersRef, i);
                
                // Clean phone number to be only digits
                phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:
                                [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                               componentsJoinedByString:@""];
                
                // Add to Array for Query!
                [phoneNumbers addObject:phoneNumber];
                [phoneNumbers addObject:[@"1" stringByAppendingString: phoneNumber]];
            }
            
            //NSLog(@"%@",phoneNumber);
        }
    }
    
    // get and loop through phone numbers - END
    
    if (phoneNumbers.count > 0)
    {
        [WebService searchUsersPhone:[phoneNumbers copy]];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"No phone numbers are in your phonebook!"];
    }
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Alert View
- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    NSString *message = @"Hey I want to send you a gift!  Download Unrapp at http://www.unrapp.com so that I can watch you unrapp it!";
    
    if (buttonIndex == 1) //Text
    {
        if(![MFMessageComposeViewController canSendText])
        {
            [SVProgressHUD showErrorWithStatus:@"Your device doesn't support SMS/Text."];
        }
        else
        {
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            
            messageController.messageComposeDelegate = self;
            [messageController setBody:message];
        
            
            // Present message view controller on screen
            [self presentViewController:messageController animated:YES completion:nil];
        }
        
    }
    else if (buttonIndex == 2) //Facebook
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            [controller setInitialText:message];
            
            [self presentViewController:controller animated:YES completion:Nil];
            
        } else
        {
            [SVProgressHUD showErrorWithStatus:@"Facebook is not available on this device. A Facebook account must be set up on your device."];
        }
    }
    else if (buttonIndex == 3) // Twitter
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
            
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            [controller setInitialText:message];
            
            [self presentViewController:controller animated:YES completion:Nil];
            
        } else
        {
            [SVProgressHUD showErrorWithStatus:@"Twitter is not available on this device. A Twitter account must be set up on your device."];
        }
    }
}
//- (void)showAddressBook
//{
//    [SVProgressHUD dismiss];
//    [self performSegueWithIdentifier: @"ShowAddressBook" sender: self];
//}
#pragma mark - Actions

- (IBAction)inviteSelected:(id)sender
{
    // Ask for invites from Address Book v. Facebook
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invitation Type"
                                                    message:@"How would you like to invite friends?"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Text/SMS", @"Facebook", @"Twitter",nil];
    [alert show];
    
}

-(void)getTraining
{
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"MPCoachMarksShownFriendsAdd"];
    if (coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MPCoachMarksShownFriendsAdd"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        CGRect spot = self.myTableView.frame;
        spot = CGRectMake(spot.origin.x, spot.origin.y, spot.size.width, 100);
        
        //Setup Marks...
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:spot],
                                    @"caption" :@"Before you search for friend names, select \"Find Friends Using Your Phonebook\" for easy matching."
                                    },
                                @{
                                    @"rect": [NSValue valueWithCGRect:CGRectMake([[UIScreen mainScreen] bounds].size.width - 70, 20, 60, 40)],
                                    @"caption" :@"Invite new friends to join Unrapp so you can share more gifts!"
                                    }
                                ];
        //CGRectMake(x, y, w, h)
        
        MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
        
        [self.tabBarController.view addSubview:coachMarksView];
        
        // Show coach marks
        [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:1.5f];
    }
}

@end
