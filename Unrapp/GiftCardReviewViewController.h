//
//  GiftCardReviewViewController.h
//  Unrapp
//
//  Created by Durish on 4/26/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"
#import "DownPicker.h"

@interface GiftCardReviewViewController : UIViewController

@property (strong, nonatomic) DownPicker *downPicker;
@property (weak, nonatomic) IBOutlet GBPathImageView *GCimg;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UITextView *txtTerms;
    @property (weak, nonatomic) IBOutlet UITextField *txtPrice;

@property IBOutlet UIActivityIndicatorView * indicator;
@end
