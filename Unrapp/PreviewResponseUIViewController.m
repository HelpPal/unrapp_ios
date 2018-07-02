//
//  PreviewResponseUIViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 5/6/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "PreviewResponseUIViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMoviePlayerController.h>
//#import "GiftReceipents.h"
//#import <Parse/Parse.h>

//#import <MediaPlayer/MediaPlayer.h>

@interface PreviewResponseUIViewController ()
{
    MPMoviePlayerController *moviePlayerController;
}

@end

@implementation PreviewResponseUIViewController

AVPlayer *avplayer;
MPMoviePlayerController* mpPlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
    NSString  *fileName = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreaction.MP4"];
    
    mpPlayer = [[MPMoviePlayerController alloc] initWithContentURL: [NSURL fileURLWithPath:fileName]];
    mpPlayer.fullscreen = YES;
    [mpPlayer prepareToPlay];
    [[mpPlayer view] setFrame:[self.view bounds]]; // Frame must match parent view
    [mpPlayer setControlStyle:MPMovieControlStyleNone];
    //[self.view insertSubview:[mpPlayer view] belowSubview:self.previewResponseUIView];
    [self.view addSubview:[mpPlayer view]];
    mpPlayer.scalingMode = MPMovieScalingModeFill;
    [mpPlayer play];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [avplayer pause];
    [mpPlayer pause];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
