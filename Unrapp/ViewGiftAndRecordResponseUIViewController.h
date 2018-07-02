//
//  ViewGiftAndRecordResponseUIViewController.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 4/30/14./Users/robertdurish/Documents/iPhoneDevelopment/unrapp/Unrapp/PictureGiftUIViewController.m
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AVFoundation/AVFoundation.h>
#import "RosyWriterVideoProcessor.h"
#import "SFCountdownView.h"
#import "TransitionVideoMaker.h"

@interface ViewGiftAndRecordResponseUIViewController : UIViewController <SFCountdownViewDelegate,UIAlertViewDelegate,VideoMakerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneUIBarButtonItem;
//@property (weak, nonatomic) IBOutlet UITextView *messageUITextView;
//@property (weak, nonatomic) IBOutlet UILabel *lblWhoSent;

- (IBAction)doneButtonSelected:(id)sender;

@end
