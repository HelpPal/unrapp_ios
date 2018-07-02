//
//  ShareResponseUITableViewController.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 5/6/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransitionVideoMaker.h"

@interface ShareResponseUITableViewController : UITableViewController <UITextViewDelegate, UIAlertViewDelegate, VideoMakerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *withSenderUISwitch;
@property (weak, nonatomic) IBOutlet UISwitch *saveToCameraRollUISwitch;
@property (weak, nonatomic) IBOutlet UITextView *responseMessageUITextView;
@property (weak, nonatomic) IBOutlet UISwitch *shareFacebookUISwitch;
@property (weak, nonatomic) IBOutlet UISwitch *shareTwitterUISwitch;

- (IBAction)shareSelected:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barBtnDone;

@end
