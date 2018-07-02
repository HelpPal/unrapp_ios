//
//  TransationVideoMaker.h
//  TriangleImage
//
//  Created by Lucky on 11/11/15.
//  Copyright © 2015 Lucky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

#import <Foundation/Foundation.h>
@protocol VideoMakerDelegate <NSObject>

- (void) finished;
- (void) failed;
- (void) TransitionComplete;
- (UIImage *) MakeVideoBGImage:(UIImage *) img;
@end

#define PIECE_CNT (4)

@interface TransitionVideoMaker : NSObject
{
    NSString *documentsDirectory;
    NSString   *splashVideo, *transitionVideo;
    UIImage * overlayPath, *backgroundPath;
    UIImage * croppedPath[PIECE_CNT];
    NSString *backgoundVideoPath, *pipVideoPath,*composeVideoPath, *waterImagePath;
    UIImage *thumbnail;
    NSString *previousVideo, *pipBackVideo, * waterMarkVideoPath, *TMP_PATH_FORMAT_CROP_IMAGE, *TMP_PATH_FORMAT_MOTION_IMAGE;
    
    AVURLAsset *Asset1, *Asset2;
    AVURLAsset *backAsset, *pipAsset;
    
    CGFloat screenWidth, screenHeight;
    
    BOOL isComposedPreviousVideo;

}

@property (nonatomic, assign) id <VideoMakerDelegate> delegate;

- (id) init;
- (id) initWith:(UIImage *) bgImgPath OverlayImagePath:(UIImage *) overlayImgPath WaterImagePath:(UIImage *) waterImgPath backgroundVideo:(NSString *) backVideo pipVideo:(NSString *) pipVideo composeVideo:(NSString *)composeVideo;

- (id) initWith:(UIImage *) bgImgPath OverlayImagePath:(UIImage *) overlayImgPath WaterImagePath:(UIImage *) waterImgPath reactionVideo:(NSString *) rVideo backgroundVideo:(NSString *) backVideo composeVideo:(NSString *)composeVideo;

- (id) initWith:(UIImage *) bgImgPath OverlayImagePath:(UIImage *) overlayImgPath;

- (void) start;
- (void) makeStartOfVideo;

@end
