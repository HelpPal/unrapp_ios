//
//  ShareResponseUITableViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 5/6/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "ShareResponseUITableViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "GiftReceipents.h"
//#import "SSZipArchive.h"
#import <Social/Social.h>

@interface ShareResponseUITableViewController ()
{
    bool allOkay;
}
@end

@implementation ShareResponseUITableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"InsertGiftResponse"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationSpam:)
                                                name:@"SpamGift"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationReport:)
                                                name:@"ReportGift"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationUpload:)
                                                name:@"FileUpload"
                                              object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InsertGiftResponse"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"SpamGift"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ReportGift"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"FileUpload"
                                                  object:nil];
}

extern UIImage *userImage;
bool startedProcess = NO;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _barBtnDone.enabled = NO;
    
    // self.navigationItem.backBarButtonItem = nil;
    // self.navigationItem.hidesBackButton = YES;
    startedProcess = NO;
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.responseMessageUITextView.delegate = self;
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        self.shareTwitterUISwitch.enabled = YES;
        self.shareTwitterUISwitch.on = YES;
    }
    else
    {
        self.shareTwitterUISwitch.enabled = NO;
        self.shareTwitterUISwitch.on = NO;
    }
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        self.shareFacebookUISwitch.enabled = YES;
        self.shareFacebookUISwitch.on = YES;
    }
    else
    {
        self.shareFacebookUISwitch.enabled = NO;
        self.shareFacebookUISwitch.on = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    
    
    if (!startedProcess)
    {
        TransitionVideoMaker *transition = [[TransitionVideoMaker alloc] initWith:[selectedGiftToView getGiftImage] OverlayImagePath:[selectedGiftToView getWrappingImage] WaterImagePath:[UIImage imageNamed:@"logo"] reactionVideo:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreaction.MP4"] backgroundVideo:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gift.MOV"] composeVideo:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreactionpackage.MP4"]];
        transition.delegate = self;
        [transition start];
        startedProcess = YES;
        
        
        [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector: @selector(runEnableDone) userInfo:nil repeats:NO];
        
        NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
        [WebService MarkViewedGift:[[giftToView objectForKey:@"GiftID"] intValue]];
    }
    
}

-(void) runEnableDone
{
    // Show Done button as we needed to wait for video stuff to complete.
    
    _barBtnDone.enabled = YES;
    NSLog(@"RAN DONE?");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

# pragma mark - Text View Delegates

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.responseMessageUITextView.text isEqualToString:@"Enter a response message here ..."])
    {
        self.responseMessageUITextView.text = @"";
    }
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


#pragma marks - Action Methods
- (IBAction)cancelSelected:(id)sender {
    
    // This is now Actions
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Actions"
                                          message:@"Select your action below:"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *spamAction = [UIAlertAction actionWithTitle:@"Spam" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            //Do some thing here
            [self runReport:@"SPAM"];
        }];
    UIAlertAction *inappropriateAction = [UIAlertAction actionWithTitle:@"Report as Inappropriate" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        //Do some thing here
                                        [self runReport:@"REPORT"];
                                    }];
    UIAlertAction *blockAction = [UIAlertAction actionWithTitle:@"Block Sender" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                    {
                                        //Do some thing here
                                        [self runReport:@"BLOCK"];
                                    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:spamAction];
    [alertController addAction:inappropriateAction];
    [alertController addAction:blockAction];
    
    
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)shareSelected:(id)sender
{
    allOkay = true;
    
    if (!self.withSenderUISwitch.on && (self.shareFacebookUISwitch.on || self.shareTwitterUISwitch.on))
    {
        [SVProgressHUD showErrorWithStatus:@"In order to share on Social Media you MUST also share with the sender!"];
    }
    else
    {
        if (self.withSenderUISwitch.on || self.shareFacebookUISwitch.on || self.shareTwitterUISwitch.on)
            [SVProgressHUD showWithStatus:@"Sharing Response..."];
        else
            [SVProgressHUD showWithStatus:@"Finishing..."];
        
        
        if ([self.saveToCameraRollUISwitch isOn] || [self.withSenderUISwitch isOn] || self.shareFacebookUISwitch.on || self.shareTwitterUISwitch.on)
        {
            // Run in background so we can show loading...
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self runSharing];
            });
        }
        else
        {
            [SVProgressHUD dismiss];
            // Alert user that they will not be able to re-record response.
            UIAlertView *noPermissionAlert = [[UIAlertView alloc] initWithTitle: @"Are you sure?" message: @"This will not allow the sender to see your initial reaction, are you sure?" delegate:self cancelButtonTitle: @"OK" otherButtonTitles: @"Cancel", nil];
            [noPermissionAlert show];
        }
    
    }
    
    
    
}

#pragma mark  - Helper Methods

-(void) runReport:(NSString*)action
{
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
    
    
    if ([action isEqualToString: @"SPAM"]) {
        [SVProgressHUD showWithStatus:@"Reporting gift as Spam and removing from your message center."];
        [WebService SpamGift:[[giftToView objectForKey:@"GiftID"] intValue]];
    } else if ([action isEqualToString: @"REPORT"]) {
        NSLog(@"Here we should report this user: %@", giftToView[@"senderUsername"]);
        [SVProgressHUD showWithStatus:@"Reporting gift as Inappropriate and removing from your message center."];
        [WebService ReportGift:[[giftToView objectForKey:@"GiftID"] intValue]];
    } else if ([action isEqualToString: @"BLOCK"]) {
        [SVProgressHUD showWithStatus:@"Blocking user from sending you any further gifts and removing this message from your message center."];
        [WebService blockUser:[[giftToView objectForKey:@"SenderID"] intValue]];
    }

}
- (void)runFacebookShare {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
        NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        controller.view.tintColor = [UIColor blueColor];
        [controller.view setTintColor:[UIColor blueColor]];
        [controller.navigationController.navigationBar setTintColor:[UIColor blueColor]];
        
        [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"http://unrapp.com/response/", [giftToView objectForKey:@"objectID"],@".html"]]];
        [controller setInitialText:@"Check out this gift I received on Unrapp!"];
        [self presentViewController:controller animated:YES completion:^(void)
         {
             if ([self.shareTwitterUISwitch isOn])
             {
                 [self runTwitterShare];
             }
             else
             {
                 // We are Done...
                 [SVProgressHUD showSuccessWithStatus:@"Success!"];
                 [self.navigationController popToRootViewControllerAnimated:YES];
             }
         }];
        
        //[self presentViewController:controller animated:YES completion:Nil];
    } else
    {
        [SVProgressHUD showErrorWithStatus:@"Facebook is not available on this device. A Facebook account must be set up on your device."];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)runTwitterShare {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
        NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        controller.view.tintColor = [UIColor blueColor];
        [controller.view setTintColor:[UIColor blueColor]];
        [controller.navigationController.navigationBar setTintColor:[UIColor blueColor]];
        
        [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"http://unrapp.com/response/", [giftToView objectForKey:@"objectID"],@".html"]]];
        [controller setInitialText:@"Check out this gift I received on Unrapp!"];
        
        [self presentViewController:controller animated:YES completion:^(void)
         {
             // We are Done...
             [SVProgressHUD showSuccessWithStatus:@"Success!"];
             [self.navigationController popToRootViewControllerAnimated:YES];
             
         }];
        //[self presentViewController:controller animated:YES completion:Nil];
    } else
    {
        [SVProgressHUD showErrorWithStatus:@"Twitter is not available on this device. A Twitter account must be set up on your device."];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (NSNumber *)appVersionNumber {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSNumber *n =  [NSNumber numberWithDouble:[[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue]];
    
    return n;
}

-(void) runSharing
{
    while (!ReadyToUpload) {
        // Just Wait....
        NSLog(@"Waiting...");
        [NSThread sleepForTimeInterval:0.5f];
    }
    
    if ([self.saveToCameraRollUISwitch isOn])
    {
        [self saveToCameraRoll];
    }
    
    if ([self.withSenderUISwitch isOn])
    {
        [self shareWithSender];
    }
    
    
}

- (void) RemoveTmpFiles {

    
    // SCREEN SHOT:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"capturedScreen.MOV"]])
    {
        NSString *path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"capturedScreen.MOV"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    // REACTION:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gift.MOV"]])
    {
        NSString *path1 = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gift.MOV"];
        [[NSFileManager defaultManager] removeItemAtPath:path1 error:nil];
    }
    

    
    // Combined Video MP4:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreaction.MP4"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreaction.MP4"] error:nil];
    }
    // Combined Video MP4:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreactionpackage.MP4"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreactionpackage.MP4"] error:nil];
    }
}
- (void) shareWithSender
{
    
    NSData *fileData;
    
    fileData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreactionpackage.MP4"]];
    
    if (fileData)
    {
        [WebService UploadFile:fileData];
    }
    else
    {
        allOkay = false;
        [SVProgressHUD showErrorWithStatus:@"There was an error creating your reaction video, please try again."];
        
        // We are Done...nothing else we can do....
        [self cancelOut];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    }
}

- (void) saveToCameraRoll
{
    NSString *path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreactionpackage.MP4"];
    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
}

- (void) video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    [self RemoveTmpFiles];
    if (error)
    {
        allOkay = false;
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error saving to camera roll. Error: %@",[[error userInfo] objectForKey:@"error"]]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==0)
    {
        
        [self cancelOut];
    }
    else
    {
        [SVProgressHUD dismiss];
    }
    
}

-(void) cancelOut
{
    [SVProgressHUD showWithStatus:@"Closing..."];
    while (!ReadyToUpload) {
        // Wait for READY
        NSLog(@"Waiting...");
        [NSThread sleepForTimeInterval:0.5f];
    }
    [SVProgressHUD dismiss];
    
    //OK
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
    
    // ZIP:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), [giftToView objectForKey:@"objectID"], @"gift.zip"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), [giftToView objectForKey:@"objectID"], @"gift.zip"] error:nil];
    }
    
    // SCREEN SHOT:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"capturedScreen",[giftToView objectForKey:@"objectID"],@".MOV"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"capturedScreen",[giftToView objectForKey:@"objectID"],@".MOV"] error:nil];
    }
    
    // SCREEN SHOT:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"capturedScreen.MOV"]])
    {
        NSString *path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"capturedScreen.MOV"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    
    // REACTION:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gift.MOV"]])
    {
        NSString *path1 = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gift.MOV"];
        [[NSFileManager defaultManager] removeItemAtPath:path1 error:nil];
    }
    
    // Combined Video:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"fullreaction",[giftToView objectForKey:@"objectID"],@".MOV"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"fullreaction",[giftToView objectForKey:@"objectID"],@".MOV"] error:nil];
    }
    
    // Combined Video MP4:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreaction.MP4"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreaction.MP4"] error:nil];
    }
    
    // Combined Video MP4:
    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreactionpackage.MP4"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"fullreactionpackage.MP4"] error:nil];
    }
    
    
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


bool ReadyToUpload = NO;
- (void) finished{
    ReadyToUpload = YES;
    
}
- (void) failed{
    ReadyToUpload = YES;
}

- (void) TransitionComplete
{
    // Not Used...
}

-(void)wsNotificationUpload:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"FileUpload"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
                // Call Other Web Service
            
            GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
            NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
            
            NSString *msg = @"";
            
            if (![self.responseMessageUITextView.text isEqualToString:@"Enter a response message here ..."])
            {
                msg = self.responseMessageUITextView.text;
            }
                        
            [WebService InsertGiftResponse:[dict objectForKey:@"Message"] toGift: [[giftToView objectForKey:@"GiftID"] intValue] andMessage:msg withVersion:[[self appVersionNumber] doubleValue]];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
}

-(void)wsNotificationReport:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"ReportGift"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
                [self cancelOut];
            }];
            
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
}

-(void)wsNotificationSpam:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"SpamGift"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
                [self cancelOut];
            }];
            
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
}


-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"InsertGiftResponse"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
                NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
                
                // ZIP:
                if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), [giftToView objectForKey:@"ObectID"], @"gift.zip"]])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), [giftToView objectForKey:@"ObectID"], @"gift.zip"] error:nil];
                }
                
                // SCREEN SHOT:
                if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"capturedScreen",[giftToView objectForKey:@"ObectID"],@".MOV"]])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"capturedScreen",[giftToView objectForKey:@"ObectID"],@".MOV"] error:nil];
                }
                
                // Combined Video:
                if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"fullreaction",[giftToView objectForKey:@"ObectID"],@".MOV"]])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@%@%@", NSTemporaryDirectory(), @"fullreaction",[giftToView objectForKey:@"ObectID"],@".MOV"] error:nil];
                }
                
                [self RemoveTmpFiles];
                
                //[SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
                
                if (allOkay)
                {
                    bool ifNeedSocial = NO;
                    if ([self.shareFacebookUISwitch isOn])
                    {
                        //[self runFacebookShare];
                        ifNeedSocial = YES;
                    }
                    
                    if ([self.shareTwitterUISwitch isOn])
                    {
                        //[self runTwitterShare];
                        ifNeedSocial = YES;
                    }
                    
                    
                    if (ifNeedSocial)
                    {
                        // Errors shown as they come...
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD dismiss];
                            if ([self.shareFacebookUISwitch isOn])
                            {
                                [self runFacebookShare];
                            }
                            else
                            {
                                [self runTwitterShare];
                            }
                        });
                    }
                    else
                    {
                        // Great!
                        // Perform on Main Thread
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SVProgressHUD showSuccessWithStatus:@"Success!"];
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        });
                    }
                }
            }];
            
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
    
}

@end
