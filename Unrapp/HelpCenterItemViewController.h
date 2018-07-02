//
//  HelpCenterItemViewController.h
//  Unrapp
//
//  Created by Robert Durish on 6/7/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

@interface HelpCenterItemViewController : UIViewController
    @property NSDictionary* myData;
    @property (weak, nonatomic) IBOutlet YTPlayerView *videoPlayer;

@end
