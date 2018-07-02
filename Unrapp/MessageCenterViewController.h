//
//  MessageCenterViewController.h
//  Unrapp
//
//  Created by Robert Durish on 2/21/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebService.h"

@interface MessageCenterViewController : UIViewController<UITabBarControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnReceived;
@property (weak, nonatomic) IBOutlet UIButton *btnResponses;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UISegmentedControl *filterUISegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePic;
@property (weak, nonatomic) IBOutlet UIButton *btnChoosePic;
@property (weak, nonatomic) IBOutlet UIButton *btnGiftCard;

@end
