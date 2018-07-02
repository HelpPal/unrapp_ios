//
//  GiftCardTableViewCell.h
//  Unrapp
//
//  Created by Durish on 4/25/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"

@interface GiftCardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet GBPathImageView *giftUIImage;
@property (weak, nonatomic) IBOutlet UILabel *nameUILabel;
@property IBOutlet UIActivityIndicatorView * indicator;

- (void) setImageURL:(NSString *) urlString;

@end
