//
//  ViewSentViewController.m
//  Unrapp
//
//  Created by Robert Durish on 4/5/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "ViewSentViewController.h"
#import "GiftReceipents.h"
#import "SVProgressHUD.h"
#import "UIImageLoader.h"

@interface ViewSentViewController ()

@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;

@end

@implementation ViewSentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [SVProgressHUD showWithStatus:@"Loading Gift ..."];
    
    GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    NSDictionary *giftToView = [selectedGiftToView getSelectedGiftToView];
    
    NSURL * url = [NSURL URLWithString:[giftToView objectForKey:@"giftURL"]];
    self.activeImageURL = url;
    self.task = [[UIImageLoader defaultLoader] loadImageWithURL:url
                                                       hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                           
                                                           //hide indicator as we have a cached image available.
                                                           //self.indicator.hidden = TRUE;
                                                           
                                                           //use cached image
                                                           self.giftImageView.image = image;
                                                           NSLog(@"Using Cache.");
                                                           [SVProgressHUD dismiss];
                                                           
                                                       } sendingRequest:^(BOOL didHaveCachedImage) {
                                                           
                                                           if(!didHaveCachedImage) {
                                                               //a cached image wasn't available, a network request is being sent, show spinner.
                                                               //[self.indicator startAnimating];
                                                               //self.indicator.hidden = FALSE;
                                                           }
                                                           
                                                       } requestCompleted:^(NSError *error, UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                           
                                                           //request complete.
                                                           NSLog(@"Complete");
                                                           //check if url above matches self.activeURL.
                                                           //If they don't match this cells image is going to be different.
                                                           if (!error)
                                                               if(![self.activeImageURL.absoluteString isEqualToString:url.absoluteString]) {
                                                                   NSLog(@"request finished, but images don't match.");
                                                                   return;
                                                               }
                                                           
                                                           //hide spinner
                                                           //self.indicator.hidden = TRUE;
                                                           //[self.indicator stopAnimating];
                                                           
                                                           //if image was downloaded, use it.
                                                           if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
                                                               NSLog(@"Image Downloaded.");
                                                               self.giftImageView.image = image;
                                                           }
                                                           [SVProgressHUD dismiss];
                                                       }];
    
}
- (IBAction)doneselected:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
