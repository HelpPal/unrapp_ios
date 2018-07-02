//
//  AddressBookViewController.m
//  Unrapp
//
//  Created by Robert Durish on 2/17/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "AddressBookViewController.h"

#import "SVProgressHUD.h"

@interface AddressBookViewController ()

@end

@implementation AddressBookViewController

- (NSMutableSet *) selectedPeople {
    if (_selectedPeople == nil) {
        _selectedPeople = [[NSMutableSet alloc] init];
    }
    return _selectedPeople;
}

- (NSMutableSet *) selectedINDEX {
    if (_selectedINDEX == nil) {
        _selectedINDEX = [[NSMutableSet alloc] init];
    }
    return _selectedINDEX;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, nil);
    //self.people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    self.people = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByLastName);
    
    self.arrayOfPeople = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
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
    return self.arrayOfPeople.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"people" forIndexPath:indexPath];
    
    ABRecordRef person = CFArrayGetValueAtIndex(self.people, indexPath.row);
    NSString* firstName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                         kABPersonFirstNameProperty);
    NSString* lastName = (__bridge_transfer NSString*)ABRecordCopyValue(person,
                                                                        kABPersonLastNameProperty);
    NSString *name = @"";
    if (lastName.length > 0)
    {
        name = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    }
    else
    {
        name = firstName;
    }
    
    cell.textLabel.text = name;
    
    if ([self.selectedINDEX containsObject:indexPath])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    ABRecordRef person = (__bridge ABRecordRef)([self.arrayOfPeople objectAtIndex:indexPath.row]);
    
    NSString* phone = nil;
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    if (cell.accessoryType == UITableViewCellAccessoryNone)
    {
        if (ABMultiValueGetCount(phoneNumbers) > 0)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            [self.selectedPeople addObject:[phone stringByReplacingOccurrencesOfString:@" " withString:@""]];
            [self.selectedINDEX addObject:indexPath];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"This contact does not have a phone number."];
        }
    }
    else if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (ABMultiValueGetCount(phoneNumbers) > 0)
        {
            phone = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            [self.selectedPeople removeObject:[phone stringByReplacingOccurrencesOfString:@" " withString:@""]];
            [self.selectedINDEX removeObject:indexPath];
        }
    }
    
    NSLog(@"%@", self.selectedPeople);
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - SMS Action

-(IBAction)showSMS:(id)sender
{
    
    if(![MFMessageComposeViewController canSendText])
    {
        [SVProgressHUD showErrorWithStatus:@"Your device doesn't support SMS. Unable to send contact invitation"];
    }
    else
    {
        NSArray *recipents = [self.selectedPeople allObjects];
        
        if (recipents.count > 0)
        {
            //NSString *message = @"I would like to send you a gift using Unrapp, can you please send me your username? If you don't have Unrapp, search in the App Store and just Sign-Up. Thanks.";
            
            NSString *message = @"Hey I want to send you a gift!  Sign up for Unrapp at http://www.unrapp.com so that I can watch you unwrapp it!";
            
            MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
            messageController.messageComposeDelegate = self;
            [messageController setRecipients:recipents];
            [messageController setBody:message];
            
            // Present message view controller on screen
            [self presentViewController:messageController animated:YES completion:nil];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"No contacts selected, please select at least one contact"];
        }
    }
}

# pragma mark - SMS Delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultCancelled)
    {
        NSLog(@"Message cancelled");
        [SVProgressHUD showErrorWithStatus:@"Invitation cancelled?"];
    }
    else if (result == MessageComposeResultSent)
    {
        NSLog(@"Message sent");
        [SVProgressHUD showSuccessWithStatus:@"Invitation sent."];
    }
    else
    {
        NSLog(@"Message failed");
        [SVProgressHUD showErrorWithStatus:@"Invitation failed, please try again"];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
