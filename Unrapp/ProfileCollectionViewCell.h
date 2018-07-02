//
//  ProfileCollectionViewCell.h
//  Unrapp
//
//  Created by Robert Durish on 3/5/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageForProfile;
@property IBOutlet UIActivityIndicatorView * indicator;

- (void) setImageURL:(NSString *) urlString;

@end
