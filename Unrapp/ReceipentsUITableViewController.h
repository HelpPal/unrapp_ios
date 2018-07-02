//
//  ReceipentsUITableViewController.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 3/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceipentsUITableViewController : UITableViewController <UISearchBarDelegate>
{
    NSArray *friends;
    NSArray *filteredFriends;
}
@property (weak, nonatomic) IBOutlet UISearchBar *receipentsSearchBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SendBtn;

- (IBAction)sendButtonSelected:(id)sender;

@end
