//
//  FriendsTableViewCell.h
//  Unrapp
//
//  Created by Robert Durish on 2/16/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"

@interface FriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet GBPathImageView *friendUIImage;
@property (weak, nonatomic) IBOutlet UILabel *nameUILabel;
@property (weak, nonatomic) IBOutlet UILabel *locationUILabel;
@property (weak, nonatomic) IBOutlet UILabel *messageUILabel;
@property (weak, nonatomic) IBOutlet UILabel *actionUILabel;
@property IBOutlet UIActivityIndicatorView * indicator;

- (void) setImageURL:(NSString *) urlString;
- (void) setImage:(UIImage *) img;
@end
