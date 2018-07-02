//
//  GiftCardReviewViewController.m
//  Unrapp
//
//  Created by Durish on 4/26/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "GiftCardReviewViewController.h"
#import "GiftReceipents.h"
#import "UIImageLoader.h"
#import "SVProgressHUD.h"

@interface GiftCardReviewViewController ()

@property BOOL cancelsTask;
@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;
@end

@implementation GiftCardReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GiftReceipents* s = [GiftReceipents getInstance];
    NSDictionary *data = [s getGiftCardToView];
    self.lblName.text = [data objectForKey:@"name"];
    self.txtTerms.text = [data objectForKey:@"terms"];
    [self setImageURL:[data objectForKey:@"image_url"]];
    
    NSString *prices = [data objectForKey:@"prices_in_cents"];
    NSString *minCents = [data objectForKey:@"min_price_in_cents"];
    NSString *maxCents = [data objectForKey:@"max_price_in_cents"];
    
    // Make Max Price $100
    if ([maxCents intValue] > 10000)
        maxCents = @"10000";
    
    // create the array of data
    NSMutableArray* dataArray = [[NSMutableArray alloc] init];
    
    if ([maxCents isEqualToString:@"0"] && [minCents isEqualToString:@"0"])
    {
        dataArray = [[prices componentsSeparatedByString:@";"] mutableCopy];
        for (int i = 0; i < [dataArray count]; i++) {
            NSString *tmp = [dataArray objectAtIndex:i];
            if ([tmp intValue] / 100 <= 100)
            [dataArray setObject:[@"$" stringByAppendingString:[NSString stringWithFormat:@"%d", [tmp intValue] / 100]] atIndexedSubscript:i];
        }
    }
    else
    {
        for (int i = [minCents intValue]; i <= [maxCents intValue]; i = i+500) {
            if (i < 500)
            {
                for (int x = i; x < 500; x = x + 100) {
                    [dataArray addObject:[@"$" stringByAppendingString:[NSString stringWithFormat:@"%d", x / 100]]];
                }
                i = 500;
                [dataArray addObject:[@"$" stringByAppendingString:[NSString stringWithFormat:@"%d", i / 100]]];
                
            }
            else
            {
                [dataArray addObject:[@"$" stringByAppendingString:[NSString stringWithFormat:@"%d", i / 100]]];
                
            }
        }
    }
    
    if ([dataArray count] == 1)
    {
        self.txtPrice.text = [dataArray objectAtIndex:0];
    }
    
    // bind yourTextField to DownPicker
    self.downPicker = [[DownPicker alloc] initWithTextField:self.txtPrice withData:dataArray];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
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

- (void) setImageURL:(NSString *) urlString {
    if ([urlString isEqualToString:@""])
    {
        [self.indicator stopAnimating];
        self.indicator.hidden = TRUE;
        self.GCimg.image = [UIImage imageNamed:@"giftcard.png"];
        [self.GCimg setPathColor:[UIColor lightGrayColor]];
        [self.GCimg setBorderColor:[UIColor lightGrayColor]];
        [self.GCimg setPathWidth:2.0];
        [self.GCimg setPathType:GBPathImageViewTypeCircle];
        [self.GCimg draw];
    }
    else
    {
        NSURL * url = [NSURL URLWithString:urlString];
        self.activeImageURL = url;
        
        self.task = [[UIImageLoader defaultLoader] loadImageWithURL:url
                     
                                                           hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                               
                                                               //hide indicator as we have a cached image available.
                                                               self.indicator.hidden = TRUE;
                                                               
                                                               //use cached image
                                                               self.GCimg.image = image;
                                                               [self.GCimg setPathColor:[UIColor lightGrayColor]];
                                                               [self.GCimg setBorderColor:[UIColor lightGrayColor]];
                                                               [self.GCimg setPathWidth:2.0];
                                                               [self.GCimg setPathType:GBPathImageViewTypeCircle];
                                                               [self.GCimg draw];
                                                               //NSLog(@"Using Cache.");
                                                               
                                                           } sendingRequest:^(BOOL didHaveCachedImage) {
                                                               
                                                               if(!didHaveCachedImage) {
                                                                   //a cached image wasn't available, a network request is being sent, show spinner.
                                                                   [self.indicator startAnimating];
                                                                   self.indicator.hidden = FALSE;
                                                               }
                                                               
                                                           } requestCompleted:^(NSError *error, UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                               
                                                               //request complete.
                                                               //NSLog(@"Complete");
                                                               //check if url above matches self.activeURL.
                                                               //If they don't match this cells image is going to be different.
                                                               if (!error)
                                                                   if(!self.cancelsTask && ![self.activeImageURL.absoluteString isEqualToString:url.absoluteString]) {
                                                                       NSLog(@"request finished, but images don't match.");
                                                                       return;
                                                                   }
                                                               
                                                               //hide spinner
                                                               self.indicator.hidden = TRUE;
                                                               [self.indicator stopAnimating];
                                                               
                                                               //if image was downloaded, use it.
                                                               if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
                                                                   //NSLog(@"Image Downloaded.");
                                                                   self.GCimg.image = image;
                                                                   [self.GCimg setPathColor:[UIColor lightGrayColor]];
                                                                   [self.GCimg setBorderColor:[UIColor lightGrayColor]];
                                                                   [self.GCimg setPathWidth:2.0];
                                                                   [self.GCimg setPathType:GBPathImageViewTypeCircle];
                                                                   [self.GCimg draw];
                                                               }
                                                               else if (error)
                                                               {
                                                                   //NSLog(@"There was an error");
                                                                   self.GCimg.image = [UIImage imageNamed:@"giftcard.png"];
                                                                   [self.GCimg setPathColor:[UIColor lightGrayColor]];
                                                                   [self.GCimg setBorderColor:[UIColor lightGrayColor]];
                                                                   [self.GCimg setPathWidth:2.0];
                                                                   [self.GCimg setPathType:GBPathImageViewTypeCircle];
                                                                   [self.GCimg draw];
                                                               }
                                                           }];
    }
}
- (IBAction)NextClick:(id)sender {
    if (![self.txtPrice.text isEqualToString:@""])
    {
        GiftReceipents* gift = [GiftReceipents getInstance];
        [gift setGiftValue:_txtPrice.text];
        [self performSegueWithIdentifier:@"pickRecipients" sender:self];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"Please select a gift card value below"];
    }
}

@end
