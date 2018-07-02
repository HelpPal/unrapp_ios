//
//  PaymentCollectionViewCell.h
//  Unrapp
//
//  Created by Durish on 10/11/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblCardNum;
@property (weak, nonatomic) IBOutlet UIImageView *imgCard;
- (void) setImageURL:(NSString *) urlString;
@end
