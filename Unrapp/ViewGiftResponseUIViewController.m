//
//  ViewGiftResponseUIViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 4/30/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "ViewGiftResponseUIViewController.h"

#import <MediaPlayer/MediaPlayer.h>
#import "SVProgressHUD.h"
#import "GiftReceipents.h"
#import "WebService.h"
//#import "SSZipArchive.h"
#import <Social/Social.h>

@interface ViewGiftResponseUIViewController ()
{
    MPMoviePlayerController *moviePlayerController;
    NSString *sharePath;
}

@end

@implementation ViewGiftResponseUIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.titleView = navView;
   
    
}
- (NSNumber *)appVersionNumber {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSNumber *n =  [NSNumber numberWithDouble:[[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue]];
    
    return n;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    
    [self.navigationItem.backBarButtonItem setTitle:@"Back"];
    
    [SVProgressHUD showWithStatus:@"Loading Response ..."];
    
    GiftReceipents* selectedSentToView = [GiftReceipents getInstance];
    NSDictionary *responseToView = [selectedSentToView getSelectedSentToView];
    
    NSNumber *appV = responseToView[@"appVersionResponse"];
    NSNumber *myVersion = [self appVersionNumber];
    
    if (!appV)
        appV = [NSNumber numberWithDouble:0.0];
    
    if ([myVersion compare:appV] == NSOrderedSame || [myVersion compare:appV] == NSOrderedDescending)
    {
        if (![[responseToView objectForKey:@"responseMessage"] isEqualToString:@""] && [responseToView objectForKey:@"responseMessage"] != nil)
        {
            [self viewMessageSelected];
            
        }
        
        NSURL *responseURL = [NSURL URLWithString:[responseToView objectForKey:@"VideoResponseURL"]];
        
        
           sharePath = [responseURL relativePath];
                 
                     // Instantiate a movie player controller and add it to your view
                     moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:responseURL];
                     [moviePlayerController.view setFrame:self.responseUIView.bounds];  // player's frame must match parent's
                     
                     [self.responseUIView addSubview:moviePlayerController.view];
                     
                     // Configure the movie player controller
                     moviePlayerController.controlStyle = MPMovieControlStyleFullscreen;
                     [moviePlayerController prepareToPlay];
                     
                    [WebService MarkViewedReponse:[[responseToView objectForKey:@"GiftID"] intValue]];
                 
                     // Start the movie
                     if (![[responseToView objectForKey:@"responseMessage"] isEqualToString:@""] && [responseToView objectForKey:@"responseMessage"] != nil)
                     {
                     }
                     else
                     {
                         [moviePlayerController play];
                     }
                
                 [SVProgressHUD dismiss];
                 
        
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"This unrapp response was send with a version higher than you have, to view you must update first, would you like to update now?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 200;
        alert.delegate = self;
        [alert show];
    }
    
    //[responseToView setObject:[NSNumber numberWithBool:NO] forKey:@"isNewResponse"];
    //[responseToView saveInBackground];
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    // Clean up files no longer needed as we are streaming.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)viewMessageSelected
{
    GiftReceipents* selectedSentToView = [GiftReceipents getInstance];
    NSDictionary *responseToView = [selectedSentToView getSelectedSentToView];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response Message"
                                                    message:[responseToView objectForKey:@"responseMessage"]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
- (IBAction)shareResponseBtnClick:(id)sender {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"Share Response"
                                          message:@"Select an Action Below:"
                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *saveAction = [UIAlertAction
                                  actionWithTitle:@"Save to Camera Roll"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action)
                                  {
                                      [self saveToCameraRoll];
                                  }];
    [alertController addAction:saveAction];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        UIAlertAction *facebookAction = [UIAlertAction
                                      actionWithTitle:@"Share to Facebook"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
                                          NSDictionary *giftToView = [selectedGiftToView getSelectedSentToView];
                                          
                                          SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                                          
                                          controller.view.tintColor = [UIColor blueColor];
                                          [controller.view setTintColor:[UIColor blueColor]];
                                          [controller.navigationController.navigationBar setTintColor:[UIColor blueColor]];
                                          
                                          [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"http://unrapp.com/response/", [giftToView objectForKey:@"objectID"],@".html"]]];
                                          [controller setInitialText:@"Check out this response I received on Unrapp!"];
                                          [self presentViewController:controller animated:YES completion:^(void)
                                           {
                                               // We are Done...
                                               [SVProgressHUD showSuccessWithStatus:@"Success!"];
                                               
                                           }];
                                      }];
        [alertController addAction:facebookAction];
    }

    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        UIAlertAction *twitterAction = [UIAlertAction
                                      actionWithTitle:@"Share to Twitter"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action)
                                      {
                                          GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
                                          NSDictionary *giftToView = [selectedGiftToView getSelectedSentToView];
                                          
                                          SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                                          
                                          controller.view.tintColor = [UIColor blueColor];
                                          [controller.view setTintColor:[UIColor blueColor]];
                                          [controller.navigationController.navigationBar setTintColor:[UIColor blueColor]];
                                          
                                          [controller addURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@",@"http://unrapp.com/response/", [giftToView objectForKey:@"objectID"],@".html"]]];
                                          [controller setInitialText:@"Check out this reaction I received on Unrapp!"];
                                          
                                          [self presentViewController:controller animated:YES completion:^(void)
                                           {
                                               // We are Done...
                                               [SVProgressHUD showSuccessWithStatus:@"Success!"];
                                           }];
                                      }];
        [alertController addAction:twitterAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action)
                                   {
                                   }];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void) saveToCameraRoll
{
    UISaveVideoAtPathToSavedPhotosAlbum(sharePath, self, @selector(video:didFinishSavingWithError:contextInfo:), NULL);
}

- (void) video: (NSString *) videoPath didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if (error)
    {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error saving to camera roll. Error: %@",[[error userInfo] objectForKey:@"error"]]];
    }
    else
    {
        [SVProgressHUD showSuccessWithStatus:@"Success!"];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 200)
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

@end
