//
//  ProfileCollectionViewCell.m
//  Unrapp
//
//  Created by Robert Durish on 3/5/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "ProfileCollectionViewCell.h"
#import "UIImageLoader.h"

@interface ProfileCollectionViewCell()

@property BOOL cancelsTask;
@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;

@end
@implementation ProfileCollectionViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //self.friendUIImage.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
    //[self.indicator startAnimating];
    
    // Keeps loading for caching
    self.cancelsTask = FALSE; // Set to true to just stop d/l
}

- (void) prepareForReuse {
    self.imageForProfile.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
    
    if(self.cancelsTask) {
        [self.task cancel];
    }
}

- (void) setImage:(UIImage *)img
{
    self.imageForProfile.image = img;
}
- (void) setImageURL:(NSString *) urlString {
    if ([urlString isEqualToString:@""])
    {
        [self.indicator stopAnimating];
        self.indicator.hidden = TRUE;
        self.imageForProfile.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
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
                                                               self.imageForProfile.image = image;
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
                                                               //        NSLog(@"request finished, but images don't match.");
                                                                       return;
                                                                   }
                                                               
                                                               //hide spinner
                                                               self.indicator.hidden = TRUE;
                                                               [self.indicator stopAnimating];
                                                               
                                                               //if image was downloaded, use it.
                                                               if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
                                                                //   NSLog(@"Image Downloaded.");
                                                                   self.imageForProfile.image = image;
                                                               }
                                                               else if (error)
                                                               {
                                                                //   NSLog(@"There was an error");
                                                                   self.imageForProfile.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
                                                               }
                                                           }];
    }
}
@end
