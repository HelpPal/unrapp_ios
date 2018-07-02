//
//  GiftCardTableViewCell.m
//  Unrapp
//
//  Created by Durish on 4/25/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "GiftCardTableViewCell.h"
#import "UIImageLoader.h"

@interface GiftCardTableViewCell()

@property BOOL cancelsTask;
@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;

@end

@implementation GiftCardTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setImageURL:(NSString *) urlString {
    if ([urlString isEqualToString:@""])
    {
        [self.indicator stopAnimating];
        self.indicator.hidden = TRUE;
        self.giftUIImage.image = [UIImage imageNamed:@"giftcard.png"];
        [self.giftUIImage setPathColor:[UIColor lightGrayColor]];
        [self.giftUIImage setBorderColor:[UIColor lightGrayColor]];
        [self.giftUIImage setPathWidth:2.0];
        [self.giftUIImage setPathType:GBPathImageViewTypeCircle];
        [self.giftUIImage draw];
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
                                                               self.giftUIImage.image = image;
                                                               [self.giftUIImage setPathColor:[UIColor lightGrayColor]];
                                                               [self.giftUIImage setBorderColor:[UIColor lightGrayColor]];
                                                               [self.giftUIImage setPathWidth:2.0];
                                                               [self.giftUIImage setPathType:GBPathImageViewTypeCircle];
                                                               [self.giftUIImage draw];
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
                                                                   self.giftUIImage.image = image;
                                                                   [self.giftUIImage setPathColor:[UIColor lightGrayColor]];
                                                                   [self.giftUIImage setBorderColor:[UIColor lightGrayColor]];
                                                                   [self.giftUIImage setPathWidth:2.0];
                                                                   [self.giftUIImage setPathType:GBPathImageViewTypeCircle];
                                                                   [self.giftUIImage draw];
                                                               }
                                                               else if (error)
                                                               {
                                                                   //NSLog(@"There was an error");
                                                                   self.giftUIImage.image = [UIImage imageNamed:@"giftcard.png"];
                                                                   [self.giftUIImage setPathColor:[UIColor lightGrayColor]];
                                                                   [self.giftUIImage setBorderColor:[UIColor lightGrayColor]];
                                                                   [self.giftUIImage setPathWidth:2.0];
                                                                   [self.giftUIImage setPathType:GBPathImageViewTypeCircle];
                                                                   [self.giftUIImage draw];
                                                               }
                                                           }];
    }
}

@end
