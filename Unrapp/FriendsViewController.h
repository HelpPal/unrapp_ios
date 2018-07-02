//
//  FriendsViewController.h
//  Unrapp
//
//  Created by Robert Durish on 2/16/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *friends;
}
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBtn;

@end
