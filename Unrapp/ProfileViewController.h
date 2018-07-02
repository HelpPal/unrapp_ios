//
//  ProfileViewController.h
//  Unrapp
//
//  Created by Robert Durish on 3/4/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomIOS7AlertView.h"
#import "GBPathImageView.h"

@interface ProfileViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CustomIOS7AlertViewDelegate, UIAlertViewDelegate,UIGestureRecognizerDelegate>
{
    NSMutableArray *myGifts;
}
@property (weak, nonatomic) IBOutlet UICollectionView *myCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *myTagline;
@property (weak, nonatomic) IBOutlet UILabel *myLocation;
@property (weak, nonatomic) IBOutlet UILabel *myName;
@property (weak, nonatomic) IBOutlet UILabel *myFollowing;
@property (weak, nonatomic) IBOutlet UILabel *myFollowers;
@property (weak, nonatomic) IBOutlet GBPathImageView *myImage;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutBtn;
@property IBOutlet UIActivityIndicatorView * indicator;

@property (strong,nonatomic) NSDictionary *passedUser;
@end
