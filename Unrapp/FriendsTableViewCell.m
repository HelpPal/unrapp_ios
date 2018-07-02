//
//  FriendsTableViewCell.m
//  Unrapp
//
//  Created by Robert Durish on 2/16/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "FriendsTableViewCell.h"
#import "UIImageLoader.h"

@interface FriendsTableViewCell()
@property BOOL cancelsTask;
@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;
@end

@implementation FriendsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //self.friendUIImage.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
    //[self.indicator startAnimating];
    
    // Keeps loading for caching
    self.cancelsTask = FALSE; // Set to true to just stop d/l
}

- (void) prepareForReuse {
    self.friendUIImage.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
    
    if(self.cancelsTask) {
        [self.task cancel];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) setImage:(UIImage *)img
{
    self.friendUIImage.image = img;
    [self.friendUIImage setPathColor:[UIColor lightGrayColor]];
    [self.friendUIImage setBorderColor:[UIColor lightGrayColor]];
    [self.friendUIImage setPathWidth:2.0];
    [self.friendUIImage setPathType:GBPathImageViewTypeCircle];
    [self.friendUIImage draw];
}
- (void) setImageURL:(NSString *) urlString {
    if ([urlString isEqualToString:@""])
    {
        [self.indicator stopAnimating];
        self.indicator.hidden = TRUE;
        self.friendUIImage.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
        [self.friendUIImage setPathColor:[UIColor lightGrayColor]];
        [self.friendUIImage setBorderColor:[UIColor lightGrayColor]];
        [self.friendUIImage setPathWidth:2.0];
        [self.friendUIImage setPathType:GBPathImageViewTypeCircle];
        [self.friendUIImage draw];
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
            self.friendUIImage.image = image;
            [self.friendUIImage setPathColor:[UIColor lightGrayColor]];
            [self.friendUIImage setBorderColor:[UIColor lightGrayColor]];
            [self.friendUIImage setPathWidth:2.0];
            [self.friendUIImage setPathType:GBPathImageViewTypeCircle];
            [self.friendUIImage draw];
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
                self.friendUIImage.image = image;
                [self.friendUIImage setPathColor:[UIColor lightGrayColor]];
                [self.friendUIImage setBorderColor:[UIColor lightGrayColor]];
                [self.friendUIImage setPathWidth:2.0];
                [self.friendUIImage setPathType:GBPathImageViewTypeCircle];
                [self.friendUIImage draw];
            }
            else if (error)
            {
                //NSLog(@"There was an error");
                self.friendUIImage.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
                [self.friendUIImage setPathColor:[UIColor lightGrayColor]];
                [self.friendUIImage setBorderColor:[UIColor lightGrayColor]];
                [self.friendUIImage setPathWidth:2.0];
                [self.friendUIImage setPathType:GBPathImageViewTypeCircle];
                [self.friendUIImage draw];
            }
        }];
    }
}

@end
