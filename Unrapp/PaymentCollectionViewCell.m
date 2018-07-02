//
//  PaymentCollectionViewCell.m
//  Unrapp
//
//  Created by Durish on 10/11/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "PaymentCollectionViewCell.h"
#import "UIImageLoader.h"
@interface PaymentCollectionViewCell()
@property BOOL cancelsTask;
@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;
@end
@implementation PaymentCollectionViewCell

- (void) setImageURL:(NSString *) urlString {
    if ([urlString isEqualToString:@""])
    {
        self.imgCard.image = [UIImage imageNamed:@"logo"];
    }
    else
    {
        NSURL * url = [NSURL URLWithString:urlString];
        self.activeImageURL = url;
        
        self.task = [[UIImageLoader defaultLoader] loadImageWithURL:url
                     
                                                           hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                               
                                                               //use cached image
                                                               self.imgCard.image = image;
                                                               
                                                               
                                                           } sendingRequest:^(BOOL didHaveCachedImage) {
                                                               
                                                               if(!didHaveCachedImage) {
                                                                   //a cached image wasn't available, a network request is being sent, show spinner.
                                                                   
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
                                                               
                                                               
                                                               //if image was downloaded, use it.
                                                               if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
                                                                   //NSLog(@"Image Downloaded.");
                                                                   self.imgCard.image = image;
                                                                   
                                                               }
                                                               else if (error)
                                                               {
                                                                   //NSLog(@"There was an error");
                                                                   self.imgCard.image = [UIImage imageNamed:@"logo"];
                                                                   
                                                               }
                                                           }];
    }
}
@end
