//
//  PaymentsCollectionViewController.h
//  Unrapp
//
//  Created by Durish on 10/11/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"

@interface PaymentsCollectionViewController : UICollectionViewController<CardIOPaymentViewControllerDelegate, UIGestureRecognizerDelegate,UIAlertViewDelegate>
@property double passedPrice;
@property NSArray *passedItems;
@property NSArray *passedPeople;
@property NSDictionary *passedData;
@property NSString *passedEach;
@end
