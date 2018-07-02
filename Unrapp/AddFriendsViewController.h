//
//  AddFriendsViewController.h
//  Unrapp
//
//  Created by Robert Durish on 2/17/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface AddFriendsViewController : UIViewController<UISearchBarDelegate,MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *friendsSearchBar;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

- (IBAction)inviteSelected:(id)sender;

@end
