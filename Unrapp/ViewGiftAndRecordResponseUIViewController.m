//
//  ViewGiftAndRecordResponseUIViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 4/30/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "ViewGiftAndRecordResponseUIViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "GiftReceipents.h"
//#import <Parse/Parse.h>
#import "SVProgressHUD.h"
#import "UIImageLoader.h"
#import "MDScratchImageView.h"
#import "CEMovieMaker.h"
#import <AVFoundation/AVFoundation.h>
#import <PhotosUI/PhotosUI.h>

#define randomNum(min,max) ((arc4random() % (max-min+1)) + min)

#define QUALITY AVAssetExportPresetMediumQuality
#define VIDEO_SIZE CGSizeMake(320, 480)

@interface ViewGiftAndRecordResponseUIViewController ()  <RosyWriterVideoProcessorDelegate, MDScratchImageViewDelegate>
{
    RosyWriterVideoProcessor *videoProcessor;
	UIBackgroundTaskIdentifier backgroundRecordingID;
    NSTimer *screenShotTimer;
    NSTimer *countDownTimer;
    UIImageView *recordImage;
    UILabel *recordLabel;
    
    SFCountdownView *sfCountdownView;
    UIView *alertBox;
    UIView *vidPreview;
    AVCaptureSession *sessionPreview;
    AVCaptureDeviceInput *input;
    UIImageView *swipeHint;
    UIImageView *giftCard;
    NSString *nameValue;
    UILabel *whoLabel;
    
    NSURLSessionDataTask * task;
}

@property (nonatomic, strong) CEMovieMaker *movieMaker;
@end

@implementation ViewGiftAndRecordResponseUIViewController

MDScratchImageView *scratchImageView;
NSMutableArray *imagesArray;

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
    
    // Hide the back buttons to allow for response interactions
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    // Initialize the class responsible for managing AV capture session and asset writer
    videoProcessor = [[RosyWriterVideoProcessor alloc] init];
    videoProcessor.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    imagesArray = [[NSMutableArray alloc] init];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100)
    {
        if (buttonIndex == 1){
            // Send to settings...
            @try {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
            @catch (NSException *exception) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Alert"
                                                               message: @"Please update your settings in the settings application."
                                                              delegate: self
                                                     cancelButtonTitle:nil
                                                     otherButtonTitles:@"OK",nil];
                [alert show];
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else if (alertView.tag == 200)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/unrapp/id955133442?mt=8"]];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)viewDidUnload
{
	[super viewDidUnload];
    
	[self cleanup];
}

- (NSNumber *)appVersionNumber {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSNumber *n =  [NSNumber numberWithDouble:[[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue]];
    
    return n;
}

bool viewOnly = YES;
bool lesserVersion = NO;

-(void)got:(UIImage*)image1 with:(NSDictionary*)giftToView
{
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    //UIImage *image1 = [UIImage imageWithData:imageData1];
    
    self.giftImageView.image = image1;
    [selectedGiftToView setGiftImage:self.giftImageView.image];
    
    nameValue = [@"From: " stringByAppendingString:[giftToView objectForKey:@"SenderUsername"]];
    
    [SVProgressHUD dismiss];
    
    if ([giftToView objectForKey:@"isNewGift"] == [NSNumber numberWithBool:YES])
    {
        if ([[giftToView objectForKey:@"FileType"] isEqualToString:@"GIFTCARD"])
        {
            if (giftCard == nil)
            {
            giftCard = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"giftcard.png"]];
            giftCard.frame = CGRectMake(55, 4, 32, 32);
            giftCard.contentMode = UIViewContentModeScaleAspectFill;
            [self.navigationController.navigationBar addSubview:giftCard];
            }
        }
        viewOnly = NO;
        // Hide Done button as we need to wait for video stuff to complete.
        _doneUIBarButtonItem.enabled = NO;
        
        int randNum = randomNum(1,16);
        
        NSString *wrappingPaperName = [NSString stringWithFormat:@"paper%i",randNum];
        [selectedGiftToView setWrappingImage:[UIImage imageNamed:wrappingPaperName]];
        
        // Updated to work for all screen sizes...-RD
        scratchImageView = [[MDScratchImageView alloc] initWithFrame:CGRectMake(0,0,
                                                                                [[UIScreen mainScreen] bounds].size.width,
                                                                                [[UIScreen mainScreen] bounds].size.height)];
        
        [scratchImageView setImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:wrappingPaperName ofType:@"png"]]
                            radius:[@"75" intValue]];
        scratchImageView.delegate = self;
        
        
        [self.view addSubview:scratchImageView];
        
        
        // Init Countdown -RD.
        sfCountdownView = [[SFCountdownView alloc] initWithFrame:CGRectMake(0,0,
                                                                            [[UIScreen mainScreen] bounds].size.width,
                                                                            [[UIScreen mainScreen] bounds].size.height)];
        
        // sets the delegate
        sfCountdownView.delegate = self;
        // background alpha value
        sfCountdownView.backgroundAlpha = 0.2;
        // the color of the counter
        sfCountdownView.countdownColor = [UIColor blueColor];
        // countdown start value
        sfCountdownView.countdownFrom = 3;
        // finish text to display
        sfCountdownView.finishText = @"UNRAPP!";
        // necessary to refresh alpha and countdown color
        [sfCountdownView updateAppearance];
        
        
        
        [self.view addSubview:sfCountdownView];
        
        NSNumber *appV = giftToView[@"appVersion"];
        
        if (!appV)
            appV = [NSNumber numberWithDouble:0.0];
        
        if ([[self appVersionNumber] compare:appV] == NSOrderedSame || [[self appVersionNumber] compare:appV] == NSOrderedDescending)
        {
            lesserVersion = NO;
            alertBox = [[UIView alloc]
                        initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width * 0.1,
                                                 [[UIScreen mainScreen] bounds].size.height * 0.1 + 40,
                                                 [[UIScreen mainScreen] bounds].size.width * 0.8,
                                                 ([[UIScreen mainScreen] bounds].size.height * 0.8) - 40)];
            
            alertBox.backgroundColor = [UIColor whiteColor];
            
            UILabel *alertMsg = [[UILabel alloc]
                                 initWithFrame:CGRectMake(10,
                                                          0,
                                                          [alertBox bounds].size.width - 20,
                                                          [alertBox bounds].size.height * 0.30)];
            alertMsg.text = @"Video recording of your reaction will start upon unrapping your gift.";
            alertMsg.adjustsFontSizeToFitWidth = YES;
            alertMsg.minimumFontSize = 8.0f;
            alertMsg.textAlignment = UITextAlignmentCenter;
            alertMsg.numberOfLines = 5;
            
            [alertBox addSubview:alertMsg];
            
            vidPreview = [[UIImageView alloc] initWithFrame:CGRectMake(10,
                                                                       ([alertBox bounds].size.height * 0.25) + 10,
                                                                       [alertBox bounds].size.width - 20,
                                                                       [alertBox bounds].size.height - ([alertBox bounds].size.height * 0.30) - 30 - 10)];
            
            [alertBox addSubview:vidPreview];
            //----- SHOW LIVE CAMERA PREVIEW -----
            sessionPreview = [[AVCaptureSession alloc] init];
            sessionPreview.sessionPreset = AVCaptureSessionPresetMedium;
            
            AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:sessionPreview];
            
            captureVideoPreviewLayer.frame = vidPreview.bounds;
            [vidPreview.layer addSublayer:captureVideoPreviewLayer];
            
            NSArray *possibleDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
            AVCaptureDevice *device = [possibleDevices lastObject];
            
            NSError *error = nil;
            
            input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
            if (!input) {
                // Handle the error appropriately.
                NSLog(@"ERROR: trying to open camera: %@", error);
            }
            else
            {
            [sessionPreview addInput:input];
            
            [sessionPreview startRunning];
            NSLog(@"SessionPreview Started!!!!!!!!");
                
                
                READY = NO;
                // Start to make the Splash Video...
                TransitionVideoMaker *transition = [[TransitionVideoMaker alloc] initWith:[selectedGiftToView getGiftImage] OverlayImagePath:[selectedGiftToView getWrappingImage]];
                transition.delegate = self;
                [transition makeStartOfVideo];
            }
            
            
            UIButton *okayBtn = [[UIButton alloc] initWithFrame:CGRectMake(([alertBox bounds].size.width / 3) + 10,
                                                                           [alertBox bounds].size.height - 40,
                                                                           ((([alertBox bounds].size.width / 3) * 2) - 20),                                                                                30)];
            
            
            [okayBtn setBackgroundImage:[UIImage imageNamed:@"btnDrkBlue"] forState:UIControlStateNormal];
            [okayBtn setTitle:@"OK, Continue" forState:UIControlStateNormal];
            [okayBtn.titleLabel sizeToFit];
            
            [okayBtn addTarget:self action:@selector(closeAlertBox) forControlEvents:UIControlEventTouchUpInside];
            
            [alertBox addSubview:okayBtn];
            
            UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10,
                                                                             [alertBox bounds].size.height - 40,
                                                                             ([alertBox bounds].size.width / 3) - 10,
                                                                             30)];
            [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
            [cancelBtn setBackgroundImage:[UIImage imageNamed:@"btnTeal"] forState:UIControlStateNormal];
            [cancelBtn.titleLabel sizeToFit];
            
            [cancelBtn addTarget:self action:@selector(cancelNow) forControlEvents:UIControlEventTouchUpInside];
            //[cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [alertBox addSubview:cancelBtn];
            
            [self.view addSubview:alertBox];
            
            
            
            
        }
        else
        {
            lesserVersion = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"This unrapp was send with a version higher than you have, to open you must update, would you like to update now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            alert.tag = 200;
            alert.delegate = self;
            [alert show];
        }
        
    }
    else
    {
        viewOnly = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    giftCard.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    //this will also be used for if download thread is done
    viewOnly = YES;
    
    [SVProgressHUD showWithStatus:@"Loading Gift ..."];
    
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
    
    
    //////
    NSURL * url = [NSURL URLWithString:[giftToView objectForKey:@"giftURL"]];
    
    task = [[UIImageLoader defaultLoader] loadImageWithURL:url
     hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
         [self got:image with:giftToView];
        
    } sendingRequest:^(BOOL didHaveCachedImage) {
        // Doesn't Matter...
    } requestCompleted:^(NSError *error, UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
        //if image was downloaded, use it.
        if(!error) {
            if (image)
                [self got:image with:giftToView];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Unable to gather gift image, try again later."];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    //////
}

-(void) viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear SessionPreview Started is %d", sessionPreview.isRunning);

    if (!sessionPreview.isRunning && !viewOnly && !lesserVersion)
    {
        // Show Alert
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Unrapp needs access to your Camera in order to record your reaction to this gift, would you like to update these settings to allow us access?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 100;
        alert.delegate = self;
        [alert show];
    }
    else if (!viewOnly)
    {
            bool OK2CONTINUE = YES;
            // Check for Video Permission
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if(authStatus == AVAuthorizationStatusAuthorized) {
                // do your logic
                
            } else if(authStatus == AVAuthorizationStatusDenied){
                // denied
                OK2CONTINUE = NO;
            } else if(authStatus == AVAuthorizationStatusRestricted){
                // restricted, normally won't happen
                OK2CONTINUE = NO;
            } else if(authStatus == AVAuthorizationStatusNotDetermined){
                // not determined?!
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if(granted){
                        NSLog(@"Granted access to %@", AVMediaTypeVideo);
                    } else {
                        NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Unrapp needs access to your Camera in order to record your reaction to this gift, would you like to update these settings to allow us access?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                        alert.tag = 100;
                        alert.delegate = self;
                        [alert show];
                    }
                }];
            } else {
                // impossible, unknown authorization status
                OK2CONTINUE = NO;
            }
            
            if (!OK2CONTINUE) {
                // Show Alert..
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Unrapp needs access to your Camera in order to record your reaction to this gift, would you like to update these settings to allow us access?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                alert.tag = 100;
                alert.delegate = self;
                [alert show];
            }
            else
            {
                //CHECK FOR MICROPHONE ACCESS
                [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                    if (granted) {
                        // Microphone enabled code
                        
                    }
                    else {
                        // Microphone disabled code
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Unrapp needs access to your Microphone in order to record your reaction to this gift, would you like to update these settings to allow us access?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                        alert.tag = 100;
                        alert.delegate = self;
                        [alert show];
                    }
                }];
            }
        }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void) closeAlertBox
{
    [sessionPreview stopRunning];
    [sessionPreview removeInput:input];
 
    sessionPreview = nil;
    
    // Hide the Alert Box -RD
    alertBox.hidden = YES;
    
    // Start the countdown. -RD
    [sfCountdownView start];
}

- (void) startRecordingProcess
{
    // Setup and start the capture session
    [videoProcessor setupAndStartCaptureSession];
    
    // Start the recording
    [videoProcessor startRecording];
    
    // We keep a reference to this timer since it is repeating to stop during Wipe call or Done call. -RD
    screenShotTimer = [NSTimer scheduledTimerWithTimeInterval:0.03f target:self selector: @selector(takeScreenShot) userInfo:nil repeats:YES];
    // After troubleshooting it seems a picture ever 0.1 sec for this keeps everything in sync better! -RD
    
    [self addImageOnTopOfTheNavigationBar];
    
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(downCount) userInfo:nil repeats:YES];
    
    [NSTimer scheduledTimerWithTimeInterval:9.0f target:self selector:@selector(wipeAll) userInfo:nil repeats:NO];
}

-(void)downCount
{
    int val = [recordLabel.text intValue ];
    val = val - 1;
    recordLabel.text = [NSString stringWithFormat:@"%d",val];
}

- (void)applicationDidBecomeActive:(NSNotification*)notifcation
{
	// For performance reasons, we manually pause/resume the session when saving a recording.
	// If we try to resume the session in the background it will fail. Resume the session here as well to ensure we will succeed.
	[videoProcessor resumeCaptureSession];
}

#pragma marks - Helper Methods

- (void)cleanup
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    // Stop and tear down the capture session
	[videoProcessor stopAndTearDownCaptureSession];
	videoProcessor.delegate = nil;
}

#pragma mark RosyWriterVideoProcessorDelegate

- (void)recordingWillStart
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Disable the idle timer while we are recording
		[UIApplication sharedApplication].idleTimerDisabled = YES;
        
		// Make sure we have time to finish saving the movie if the app is backgrounded during recording
		if ([[UIDevice currentDevice] isMultitaskingSupported])
			backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	});
}

- (void)recordingDidStart
{
}

- (void)recordingWillStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		// Pause the capture session so that saving will be as fast as possible.
		// We resume the sesssion in recordingDidStop:
		[videoProcessor pauseCaptureSession];
        
        // Run enable done after small delay..
        [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector: @selector(runEnableDone) userInfo:nil repeats:NO];
	});
}


- (void)recordingDidStop
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[UIApplication sharedApplication].idleTimerDisabled = NO;
        
		[videoProcessor resumeCaptureSession];
        
		if ([[UIDevice currentDevice] isMultitaskingSupported])
        {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
	});
    
    
}

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer
{
	// Don't make OpenGLES calls while in the background.
}

#pragma mark Action Methods
- (IBAction)doneButtonSelected:(id)sender
{
    // Turns off the timer, if the timer still exists. -RD
    if (screenShotTimer != nil)
    {
        [screenShotTimer invalidate];
        screenShotTimer = nil;
    }
    
    if (countDownTimer != nil)
    {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    
    [self cleanup];
    
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];

    if ([giftToView objectForKey:@"isNewGift"] == [NSNumber numberWithBool:YES])
    {
        NSString  *pipFileName = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"capturedScreen.MOV"];
        NSString *mainFileName = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gift.MOV"];
        

        
        [self composeVideo:pipFileName onVideo:mainFileName];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}

#pragma mark - Screen Shot Timer Method
- (void) takeScreenShot
{
    // Grab screen shot of the scratch view frame only, the other method ended up with a cutoff image on iPhone5. -RD
    UIGraphicsBeginImageContext(scratchImageView.frame.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Uncomment below to save screenshots. -RD
    //UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
    
    [imagesArray addObject:viewImage];
    
    if (recordImage.alpha == 1.0)
        recordImage.alpha = 0.8;
    else if (recordImage.alpha == 0.8)
        recordImage.alpha = 0.6;
    else if (recordImage.alpha == 0.6)
        recordImage.alpha = 0.4;
    else if (recordImage.alpha == 0.4)
        recordImage.alpha = 0.2;
    else if (recordImage.alpha == 0.2)
        recordImage.alpha = 0.0;
    else if (recordImage.alpha == 0.0)
        recordImage.alpha = 0.1;
    else if (recordImage.alpha == 0.1)
        recordImage.alpha = 0.3;
    else if (recordImage.alpha == 0.3)
        recordImage.alpha = 0.5;
    else if (recordImage.alpha == 0.5)
        recordImage.alpha = 0.7;
    else if (recordImage.alpha == 0.7)
        recordImage.alpha = 0.9;
    else
        recordImage.alpha = 1.0;
    
}


#pragma mark - Add Recording Image
-(void)addImageOnTopOfTheNavigationBar {
    if (!recordImage)
    {
        recordImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"record"]];
    
        recordImage.frame = CGRectMake(20,
                                       4,
                                       32, 32);
        
        recordImage.contentMode = UIViewContentModeScaleAspectFit;
        recordLabel = [[UILabel alloc] initWithFrame:CGRectMake(32,
                                                                8,
                                                                25, 25)];
        recordLabel.text = @"9";
        recordLabel.textColor = [UIColor whiteColor];
        
        //From Label - x, y, w, h
    
        whoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,
                                                                self.navigationController.navigationBar.bounds.size.height,
                                                                ([[UIScreen mainScreen] bounds].size.width / 2) - 5, 25)];
        whoLabel.text = nameValue;
        whoLabel.textColor = [UIColor whiteColor];
        whoLabel.adjustsFontSizeToFitWidth = YES;
        
        
        
        
        [self.navigationController.navigationBar addSubview:recordImage];
        [self.navigationController.navigationBar addSubview:recordLabel];
        [self.navigationController.navigationBar addSubview:whoLabel];
        
        
    }
}

#pragma marks - Selector for Erasing

- (void) wipeAll
{
    @try
    {
     
        scratchImageView.hidden = YES;
        
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:videoProcessor selector:@selector(stopRecording) userInfo:nil repeats:NO];
        
        // If the timer is active stop it. -RD
        if (screenShotTimer != nil)
        {
            [screenShotTimer invalidate];
            screenShotTimer = nil;
        }
        if (countDownTimer != nil)
        {
            [countDownTimer invalidate];
            countDownTimer = nil;
        }
        
        // Take 1 last screen shot after the wipe -RD
        [self takeScreenShot];
        
        recordImage.hidden = YES;
        recordLabel.hidden = YES;
        
        // Create non-mutable copy. -RD
        NSArray *array = [NSArray arrayWithArray:imagesArray];
        
        // Create File Name of screen capture. -RD
        NSString  *fileName = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"capturedScreen.MOV"];
        
        // Create Video Render Settings. -RD
        NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:((UIImage*)[array objectAtIndex:0]).size.width andHeight:((UIImage*)[array objectAtIndex:0]).size.height];
        
        // Create Movie Maker Object with Render Settings. -RD
        self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings andFileName:fileName];
        
        // Create the Movie. -RD
        [self.movieMaker createMovieFromImages:array withCompletion:^(BOOL success, NSURL *fileURL){
            if (!success) {
                // What should we do if this video doesn't create??
                // George, your call...just putting alert not sure this will even be an issue I've never had it pop up.
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Error Creating Screen Video"
                                                               delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                
            }
        }];
        
    }
    
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@",ex]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    
    
}

#pragma mark - MDScratchImageViewDelegate

- (void)mdScratchImageView:(MDScratchImageView *)scratchImageView didChangeMaskingProgress:(CGFloat)maskingProgress
{
	// This was not posting progress enough which caused jagged / outof sync video, the screen grabs have been moved to a timer. -RD
    swipeHint.hidden = YES;
}

#pragma mark - Video Combination
- (void) composeVideo:(NSString*)videoPIP onVideo:(NSString*)videoBG
{
    @try {
        NSError *e = nil;
        
        AVURLAsset *backAsset, *pipAsset;
        
        // Load our 2 movies using AVURLAsset
        pipAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPIP] options:nil];
        backAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoBG] options:nil];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoPIP])
        {
            NSLog(@"PIP File Exists!");
        }
        else
        {
            NSLog(@"PIP File DOESN'T Exist!");
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:videoBG])
        {
            NSLog(@"BG File Exists!");
        }
        else
        {
            NSLog(@"BG File DOESN'T Exist!");
        }
        
        float scaleH = VIDEO_SIZE.height / [[[backAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].width;
        float scaleW = VIDEO_SIZE.width / [[[backAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].height;
        
        float scalePIP = (VIDEO_SIZE.width * 0.25) / [[[pipAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width;
        
        // Create AVMutableComposition Object - this object will hold our multiple AVMutableCompositionTracks.
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        
        // Create the first AVMutableCompositionTrack by adding a new track to our AVMutableComposition.
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        // Set the length of the firstTrack equal to the length of the firstAsset and add the firstAsset to our newly created track at kCMTimeZero so video plays from the start of the track.
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, pipAsset.duration) ofTrack:[[pipAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:&e];
        if (e)
        {
            NSLog(@"Error0: %@",e);
            e = nil;
        }
        
        // Repeat the same process for the 2nd track and also start at kCMTimeZero so both tracks will play simultaneously.
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, backAsset.duration) ofTrack:[[backAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:&e];
        
        if (e)
        {
            NSLog(@"Error1: %@",e);
            e = nil;
        }
        
        // We also need the audio track!
        AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, backAsset.duration) ofTrack:[[backAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:&e];
        if (e)
        {
            NSLog(@"Error2: %@",e);
            e = nil;
        }
        
        
        // Create an AVMutableVideoCompositionInstruction object - Contains the array of AVMutableVideoCompositionLayerInstruction objects.
        AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        
        // Set Time to the shorter Asset.
        // Causing issues on ios 11
        //MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, (pipAsset.duration.value > backAsset.duration.value) ? pipAsset.duration : backAsset.duration);
        
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTIME_COMPARE_INLINE(pipAsset.duration, >, backAsset.duration) ? pipAsset.duration : backAsset.duration);
        
        
        // Create an AVMutableVideoCompositionLayerInstruction object to make use of CGAffinetransform to move and scale our First Track so it is displayed at the bottom of the screen in smaller size.
        AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        
        //CGAffineTransform Scale1 = CGAffineTransformMakeScale(0.3f,0.3f);
        CGAffineTransform Scale1 = CGAffineTransformMakeScale(scalePIP, scalePIP);
        
        // Top Left
        CGAffineTransform Move1 = CGAffineTransformMakeTranslation(3.0, 3.0);
        
        [FirstlayerInstruction setTransform:CGAffineTransformConcat(Scale1,Move1) atTime:kCMTimeZero];
        
        // Repeat for the second track.
        AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        
        CGAffineTransform Scale2 = CGAffineTransformMakeScale(scaleW, scaleH);
        CGAffineTransform rotateBy90Degrees = CGAffineTransformMakeRotation( M_PI_2);
        CGAffineTransform Move2 = CGAffineTransformMakeTranslation(0.0, ([[[backAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].height) * -1);
        
        [SecondlayerInstruction setTransform:CGAffineTransformConcat(Move2, CGAffineTransformConcat(rotateBy90Degrees, Scale2)) atTime:kCMTimeZero];
        
        // Add the 2 created AVMutableVideoCompositionLayerInstruction objects to our AVMutableVideoCompositionInstruction.
        MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction, SecondlayerInstruction, nil];
        
        // Create an AVMutableVideoComposition object.
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, 30);
        
        
        // Set the render size to the screen size.
        //        MainCompositionInst.renderSize = [[UIScreen mainScreen] bounds].size;
        MainCompositionInst.renderSize = VIDEO_SIZE;
        
        
        NSString  *fileName = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreaction.MP4"];
        
        // Make sure the video doesn't exist.
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
        {
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        
        // Now we need to save the video.
        NSURL *url = [NSURL fileURLWithPath:fileName];
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:QUALITY];
        exporter.videoComposition = MainCompositionInst;
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeMPEG4;
        
        [SVProgressHUD showWithStatus:@"Processing Reaction..."];
        
        [exporter exportAsynchronouslyWithCompletionHandler:
         ^(void )
         {
             NSLog(@"File Saved as %@!", fileName);
             NSLog(@"Error: %@", exporter.error);
             [self performSelectorOnMainThread:@selector(runProcessingComplete) withObject:nil waitUntilDone:false];
         }];
        
    }
    @catch (NSException *ex) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error 3" message:[NSString stringWithFormat:@"%@",ex]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    
}

-(void) runProcessingComplete
{
    while (!READY) {
        // Wait for READY
        NSLog(@"Waiting...");
        [NSThread sleepForTimeInterval:0.5f];
    }
    [SVProgressHUD dismiss];
    [self performSegueWithIdentifier: @"ShareGiftResponse" sender: self];
}

-(void) runEnableDone
{
    // Show Done button as we needed to wait for video stuff to complete.
    whoLabel.hidden = YES;
    _doneUIBarButtonItem.enabled = YES;
    NSLog(@"RAN DONE.");
}
-(void) cancelNow
{
    [SVProgressHUD showWithStatus:@"Closing Video"];
    while (!READY) {
        // Wait for READY
        NSLog(@"Waiting...");
        [NSThread sleepForTimeInterval:0.5f];
    }
    [SVProgressHUD dismiss];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma CountDown
- (void) countdownFinished:(SFCountdownView *)view
{
    // We will start the recording...
    [self startRecordingProcess];
    //[sfCountdownView stop];
    view.hidden = YES;
    
    swipeHint = [[UIImageView alloc] initWithFrame: CGRectMake(([[UIScreen mainScreen] bounds].size.width / 2) - 64,([[UIScreen mainScreen] bounds].size.height / 2) - 64,
                                                              128,
                                                              128)];
    swipeHint.animationImages = [[NSArray alloc] initWithObjects:[UIImage imageNamed:@"Swipe_Left.png"],[UIImage imageNamed:@"Swipe_Right.png"], nil];
    swipeHint.animationDuration = 0.5;
    swipeHint.animationRepeatCount = 20;
    [self.view addSubview:swipeHint];
    [swipeHint startAnimating];
    
}

bool READY = NO;
- (void) finished{
    
}
- (void) failed{

}
- (void) TransitionComplete
{
    READY = YES;
}


@end
