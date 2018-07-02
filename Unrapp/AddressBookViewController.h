//
//  AddressBookViewController.h
//  Unrapp
//
//  Created by Robert Durish on 2/17/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface AddressBookViewController : UIViewController <MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSArray *arrayOfPeople;
//@property (nonatomic, strong) NSArray *arrayOfFilteredPeople;
@property (nonatomic, assign) CFArrayRef people;
@property (nonatomic, strong) NSMutableSet *selectedPeople;
@property (nonatomic, strong) NSMutableSet *selectedINDEX;

-(IBAction)showSMS:(id)sender;

@end
