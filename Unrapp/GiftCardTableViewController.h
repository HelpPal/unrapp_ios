//
//  GiftCardTableViewController.h
//  Unrapp
//
//  Created by Durish on 4/26/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiftCardTableViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
    @property (strong,nonatomic) NSDictionary* passedData;
@end
