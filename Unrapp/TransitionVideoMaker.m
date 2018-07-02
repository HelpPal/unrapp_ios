//
//  TransationVideoMaker.m
//  TriangleImage
//
//  Created by Lucky on 11/11/15.
//  Copyright © 2015 Lucky. All rights reserved.
//

#import "TransitionVideoMaker.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

#define FRAMECNT_PER_SECOND (24.0)

#define QUALITY AVAssetExportPresetMediumQuality
#define VIDEO_SIZE CGSizeMake(320, 480)


@implementation TransitionVideoMaker
@synthesize delegate;
- (id) init{
    self = [super init];
    if(self)
    {
        backgroundPath = nil;
        overlayPath = nil;

        splashVideo = @"";
        transitionVideo = @"";
        thumbnail = nil;
        backgoundVideoPath = @"";
        pipVideoPath = @"";
        previousVideo = @"";
        pipBackVideo = @"";
        composeVideoPath = @"";
        waterImagePath = @"";
        waterMarkVideoPath = @"";
        TMP_PATH_FORMAT_CROP_IMAGE = @"";
        TMP_PATH_FORMAT_MOTION_IMAGE = @"";
        return self;
    }
    return nil;
}



- (id) initWith:(UIImage *)bgImgPath OverlayImagePath:(UIImage *)overlayImgPath WaterImagePath:(UIImage *)waterImgPath backgroundVideo:(NSString *)backVideo pipVideo:(NSString *)pipVideo composeVideo:(NSString *)composeVideo {
    
    self = [super init];
    
    if (self) {
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        screenWidth = screenRect.size.width;
        screenHeight = screenRect.size.height;

        backgroundPath = bgImgPath;
        overlayPath = overlayImgPath;
        
        NSData *waterImgData = UIImagePNGRepresentation(waterImgPath);
        waterImagePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"waterImage.png"];
        [waterImgData writeToFile:waterImagePath atomically:YES];
        
        backgoundVideoPath = backVideo;
        pipVideoPath = pipVideo;
        composeVideoPath = composeVideo;
        
        waterMarkVideoPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"waterMarkVideo.mp4"];
        splashVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"splash", @".mp4"];
        transitionVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"transition", @".mp4"];
        
        previousVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"previousVideo", @".mp4"];
        pipBackVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"pipBackVideo", @".mp4"];
        
        TMP_PATH_FORMAT_MOTION_IMAGE = [NSTemporaryDirectory() stringByAppendingString:@"motionImage%d.png"];
        TMP_PATH_FORMAT_CROP_IMAGE = [NSTemporaryDirectory() stringByAppendingString:@"pieceImage%d.png"];
        
        
        isComposedPreviousVideo = FALSE;
        
        return self;
    }
    
    return nil;
    
    
}

- (id) initWith:(UIImage *) bgImgPath OverlayImagePath:(UIImage *) overlayImgPath WaterImagePath:(UIImage *) waterImgPath reactionVideo:(NSString *) rVideo backgroundVideo:(NSString *) backVideo composeVideo:(NSString *)composeVideo
{
    self = [super init];
    
    if (self) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        screenWidth = screenRect.size.width;
        screenHeight = screenRect.size.height;

        backgroundPath = bgImgPath;
        overlayPath = overlayImgPath;
        
        NSData *waterImgData = UIImagePNGRepresentation(waterImgPath);
        waterImagePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"waterImage.png"];
        [waterImgData writeToFile:waterImagePath atomically:YES];
        
        backgoundVideoPath = backVideo;
        pipVideoPath = @"";
        composeVideoPath = composeVideo;
        
        waterMarkVideoPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"waterMarkVideo.mp4"];
        splashVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"splash", @".mp4"];
        transitionVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"transition", @".mp4"];
        
        previousVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"previousVideo", @".mp4"];
        pipBackVideo = rVideo;
        
        TMP_PATH_FORMAT_MOTION_IMAGE = [NSTemporaryDirectory() stringByAppendingString:@"motionImage%d.png"];
        TMP_PATH_FORMAT_CROP_IMAGE = [NSTemporaryDirectory() stringByAppendingString:@"pieceImage%d.png"];
        
        isComposedPreviousVideo = FALSE;
        
        
        return self;
    }
    
    return nil;
}

- (id) initWith:(UIImage *) bgImgPath OverlayImagePath:(UIImage *) overlayImgPath
{
    self = [super init];
    
    if (self) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        screenWidth = screenRect.size.width;
        screenHeight = screenRect.size.height;
        
        backgroundPath = [self MakeVideoBGImage:bgImgPath :VIDEO_SIZE];
        overlayPath = overlayImgPath;
        
        waterImagePath = @"";
        
        backgoundVideoPath = @"";
        pipVideoPath = @"";
        composeVideoPath = @"";
        
        waterMarkVideoPath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"waterMarkVideo.mp4"];
        splashVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"splash", @".mp4"];
        transitionVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"transition", @".mp4"];
        
        previousVideo = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"previousVideo", @".mp4"];
        pipBackVideo = @"";
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"thumb", @".png"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        thumbnail = [UIImage imageNamed:@"splash"];
        [UIImagePNGRepresentation(thumbnail) writeToFile:filePath atomically:YES];
        
//        [UIImagePNGRepresentation([UIImage imageNamed:@"splash"]) writeToFile:filePath atomically:YES];
//        thumbnail = filePath;
        
        TMP_PATH_FORMAT_MOTION_IMAGE = [NSTemporaryDirectory() stringByAppendingString:@"motionImage%d.png"];
        TMP_PATH_FORMAT_CROP_IMAGE = [NSTemporaryDirectory() stringByAppendingString:@"pieceImage%d.png"];
        
        isComposedPreviousVideo = FALSE;
        
        return self;
    }
    
    return nil;
}

#define rad(angle) ((angle) / 180.0 * M_PI)
- (CGAffineTransform)orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}

- (UIImage *)normalizedImage:(UIImage *) img {
    if (img.imageOrientation == UIImageOrientationUp) return img;
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    [img drawInRect:(CGRect){0, 0, img.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage *) MakeVideoBGImage:(UIImage *) img :(CGSize) targetSize{
    UIImage *normalizedImage = [self normalizedImage:img];
//    NSLog(@"original direction %ld scale %f", (long)normalizedImage.imageOrientation, normalizedImage.scale);

    float rate1 = targetSize.width / targetSize.height;
    float rate2 = normalizedImage.size.width / normalizedImage.size.height;
    
    float w = targetSize.width;
    float h = targetSize.height;
    if (rate1 >= rate2)
        w = h * normalizedImage.size.width / normalizedImage.size.height;
    else
        h = w * normalizedImage.size.height / normalizedImage.size.width;
    
    float x = targetSize.width / 2 - w / 2;
    float y = targetSize.height / 2 - h / 2;
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, normalizedImage.scale);
    [img drawInRect:CGRectMake(x, y, w, h)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (CGImageRef) MyCreateCGImageFromFile:(NSString*) path
{
    // Get the URL for the pathname passed to the function.
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageRef        myImage = NULL;
    CGImageSourceRef  myImageSource;
    CFDictionaryRef   myOptions = NULL;
    CFStringRef       myKeys[2];
    CFTypeRef         myValues[2];
    
    // Set up options if you want them. The options here are for
    // caching the image in a decoded form and for using floating-point
    // values if the image format supports them.
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef)kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef)kCFBooleanTrue;
    // Create the dictionary
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2,
                                   &kCFTypeDictionaryKeyCallBacks,
                                   & kCFTypeDictionaryValueCallBacks);
    // Create an image source from the URL.
    myImageSource = CGImageSourceCreateWithURL((CFURLRef)url, myOptions);
    CFRelease(myOptions);
    // Make sure the image source exists before continuing
    if (myImageSource == NULL){
        fprintf(stderr, "Image source is NULL.");
        return  NULL;
    }
    // Create an image from the first item in the image source.
    myImage = CGImageSourceCreateImageAtIndex(myImageSource,
                                              0,
                                              NULL);
    
    CFRelease(myImageSource);
    // Make sure the image exists before continuing
    if (myImage == NULL){
        fprintf(stderr, "Image not created from image source.");
        return NULL;
    }
    
    return myImage;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
    CGFloat angle = 0.0;
    
    switch (orientation) {
        case AVCaptureVideoOrientationPortrait:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        default:
            break;
    }
    
    return angle;
}



- (NSString *) getThumbnail:(NSString *)videoPath {
    NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
    
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:videoUrl options:nil];
    
    AVAssetImageGenerator* generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:sourceAsset];
    
    //Get the 1st frame 3 seconds in
    int frameTimeStart = 0;
    int frameLocation = 1;
    
    CGImageRef frameRef = [generator copyCGImageAtTime:CMTimeMake(frameTimeStart,frameLocation) actualTime:nil error:nil];
    
    UIImage *thumbImage = [UIImage imageWithCGImage:frameRef];
    
    thumbImage = [self imageRotatedByDegrees:thumbImage deg:90];
    
    NSData *pngData = UIImagePNGRepresentation(thumbImage);
    NSString *filePath = [NSString stringWithFormat:@"%@%@%@", NSTemporaryDirectory(), @"thumb", @".png"]; //Add the file name
    
    [UIImagePNGRepresentation([UIImage imageWithData:pngData]) writeToFile:filePath atomically:YES];
    
    return filePath;
    
}

- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void) start{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"Starting");
        [self MakeVideo];
        NSLog(@"Done");
    });
}

- (void) makeStartOfVideo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"Starting Start of Video Method");
        [self makeSplashVideo];
        [self makeTransitionVideo];
        NSLog(@"Done with Start of Video Method");
    });
}


- (UIImage *)maskImage:(UIImage *)originalImage toPath:(UIBezierPath *)path {
    UIGraphicsBeginImageContextWithOptions(originalImage.size, NO, 0);
    [path addClip];
    [originalImage drawAtPoint:CGPointZero];
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return maskedImage;
}

- (void) saveFourPieceImages:(UIImage *) orgImage
{
    NSLog(@"saveFourPieceImages");
    float posInfo[PIECE_CNT][3][2] = {  {{0, 0}, {1, 0}, {0.5, 0.5}},
        {{0, 1}, {1, 1}, {0.5, 0.5}},
        {{1, 0}, {1, 1}, {0.5, 0.5}},
        {{0, 0}, {0, 1}, {0.5, 0.5}}};
    
    UIBezierPath *trianglePath = [UIBezierPath new];
    float plusX = 0.0, plusY = 0.0;
    for (int i = 0; i < PIECE_CNT; i++){
        if(i != 0)  [trianglePath removeAllPoints];
        if(i < 2){
            plusX = 1;
            if( i == 0)
                plusY = 2;
            else
                plusY = -2;
        }
        [trianglePath moveToPoint:(CGPoint){posInfo[i][0][0] * orgImage.size.width - plusX, posInfo[i][0][1] * orgImage.size.height}];
        [trianglePath addLineToPoint:(CGPoint){posInfo[i][1][0] * orgImage.size.width + plusX, posInfo[i][1][1] * orgImage.size.height}];
        [trianglePath addLineToPoint:(CGPoint){posInfo[i][2][0] * orgImage.size.width, posInfo[i][2][1] * orgImage.size.height + plusY}];

        croppedPath[i] = [self maskImage:orgImage toPath:trianglePath];
        plusX = 0.0, plusY = 0.0;
    }
}



- (void)createVideo:(int) imgCount Duration:(int) secDur OutputPath:(NSString *) videoOutputPath
{
    NSLog(@"------------ CreateVideo %@", videoOutputPath);
    NSError *error = nil;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr fileExistsAtPath:videoOutputPath])
        if ([fileMgr removeItemAtPath:videoOutputPath error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:videoOutputPath] fileType:AVFileTypeMPEG4 error:&error];
    NSParameterAssert(videoWriter);
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:VIDEO_SIZE.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:VIDEO_SIZE.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
    NSParameterAssert(videoWriterInput);
    NSParameterAssert([videoWriter canAddInput:videoWriterInput]);
    videoWriterInput.expectsMediaDataInRealTime = YES;
    [videoWriter addInput:videoWriterInput];
    
    //Start a session:
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    NSUInteger fps = 5;
    
    BOOL isSingleImg = FALSE;
    double numberOfFramesPerSec = 1;
    
    double snumberOfSecondsPerFrame = 1;
    double sframeDuration = fps * snumberOfSecondsPerFrame;
    if(imgCount == 1)
        isSingleImg = TRUE;
    
    int frameCount = 0, repeatCount = 0;
    
    if(!isSingleImg)
    {
        repeatCount = imgCount;
        numberOfFramesPerSec = FRAMECNT_PER_SECOND;
    }
    else
    {
        repeatCount = secDur;
        //        buffer = [self pixelBufferFromCGImage:[[UIImage imageNamed:pathFormat] CGImage]];
        buffer = [self pixelBufferFromCGImage:backgroundPath.CGImage];
    }
    
    UIImage *lastPieceImgName = backgroundPath;
    for(int i = 0; i < repeatCount; i++)
    {
        if(!isSingleImg) {
            if (i < PIECE_CNT * FRAMECNT_PER_SECOND / 2) {
                int piece = i / (int)(FRAMECNT_PER_SECOND / 2);
                int subindex = i % (int)(FRAMECNT_PER_SECOND / 2);
                UIImage * picImage = [self getComposeImage:lastPieceImgName SecondImagePath:croppedPath[piece] TargetSize:VIDEO_SIZE PieceIndex:piece SubIndex:subindex];

                if (subindex == 11)
                    lastPieceImgName = picImage;
                buffer = [self pixelBufferFromCGImage:[picImage CGImage]];
            }
            else {
                int subindex = i - PIECE_CNT * FRAMECNT_PER_SECOND / 2;
                UIImage * picImage = [self getComposeImage:thumbnail SecondImagePath:lastPieceImgName TargetSize:VIDEO_SIZE PieceIndex:5 SubIndex:subindex];
                buffer = [self pixelBufferFromCGImage:[picImage CGImage]];
            }
        }
        //        buffer = [self pixelBufferFromCGImage:[[UIImage imageNamed:[NSString stringWithFormat:pathFormat, i]] CGImage]];
        BOOL append_ok = NO;
        int j = 0;
        int jLimit = FRAMECNT_PER_SECOND;
        
        if(isSingleImg)
            jLimit = (int)fps;
        while (!append_ok && j < jLimit)
        {
            if (adaptor.assetWriterInput.readyForMoreMediaData)
            {
                
                CMTime frameTime;
                if(!isSingleImg)
                    frameTime = CMTimeMake(frameCount,(int32_t) numberOfFramesPerSec);
                else
                    frameTime = CMTimeMake(frameCount*sframeDuration,(int32_t) fps);
                append_ok = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                
                if(!isSingleImg && (buffer))
                    CVBufferRelease(buffer);
                [NSThread sleepForTimeInterval:0.05];
            }
            else
            {
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            [delegate failed];
            return;
        }
        frameCount++;
    }
    
    if(isSingleImg)
        CVBufferRelease(buffer);
    
    [videoWriterInput markAsFinished];
    
    [videoWriter finishWritingWithCompletionHandler:^{
        if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted) {
//            UISaveVideoAtPathToSavedPhotosAlbum(videoOutputPath, nil, nil, nil);//testtest
//            NSLog(@"Complete Successfully : %@", videoOutputPath);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Failed!!!");
            });
        }
    }];
    videoWriter = nil;
    videoWriterInput = nil;
}


- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
//    NSLog(@"pixelBufferFromCGImage");
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    NSDictionary *options = @{
                              (__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey: @(NO),
                              (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @(NO)
                              };
    CVPixelBufferRef pixelBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height,
                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
                                                 (CGBitmapInfo) kCGImageAlphaNoneSkipFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}

- (void) composeImage:(UIImage *) firstPath SecondImagePath:(UIImage *) secondPath TargetSize:(CGSize) targetSize OutputFileName:(NSString *) outputPath PieceIndex:(int) pIndex SubIndex:(int) sIndex lastimage:(UIImage **) plastPieceImgName{
//    UIImage *firstImg    = [UIImage imageNamed:firstPath];
    UIImage *firstImg    = firstPath;
    UIImage *secondImg   = secondPath;
//    UIImage *secondImg   = [UIImage imageNamed:secondPath];
    
    UIGraphicsBeginImageContext( targetSize );
    
    [firstImg drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    
    if (pIndex == 0)
        [secondImg drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height / 11.0 * sIndex) blendMode:kCGBlendModeNormal alpha:1.0];
    else if (pIndex == 1)
        [secondImg drawInRect:CGRectMake(0, targetSize.height / 11.0 * (11 - sIndex), targetSize.width ,targetSize.height / 11.0 * sIndex ) blendMode:kCGBlendModeNormal alpha:1.0];
    else if (pIndex == 2)
        [secondImg drawInRect:CGRectMake(targetSize.width  / 11.0 * (11 - sIndex), 0, targetSize.width  / 11.0 * sIndex , targetSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    else if (pIndex == 3)
        [secondImg drawInRect:CGRectMake(0, 0, targetSize.width / 11.0 * sIndex,targetSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    else{ //Second Motion
        float targetRatio = 5.0; // 1/5
        float secondMotionScale = 1.0 / (FRAMECNT_PER_SECOND / (targetRatio - 1.0) * targetRatio) * (FRAMECNT_PER_SECOND / (targetRatio - 1.0) * (targetRatio + 1) - sIndex - FRAMECNT_PER_SECOND / (targetRatio - 1.0));
        [secondImg drawInRect:CGRectMake(0, 0, targetSize.width * secondMotionScale, targetSize.height  * secondMotionScale) blendMode:kCGBlendModeNormal alpha:1.0];
    }

    [self removeFile:outputPath];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [UIImagePNGRepresentation(newImage) writeToFile:outputPath atomically:YES];
    if (sIndex == 11 && plastPieceImgName)
        *plastPieceImgName = newImage;
    UIGraphicsEndImageContext();
}

- (UIImage *) getComposeImage:(UIImage *) firstPath SecondImagePath:(UIImage *) secondPath TargetSize:(CGSize) targetSize PieceIndex:(int) pIndex SubIndex:(int) sIndex{

    UIImage *firstImg    = firstPath;
    UIImage *secondImg   = secondPath;
    
    UIGraphicsBeginImageContext( targetSize );
    
    [firstImg drawInRect:CGRectMake(0,0,targetSize.width,targetSize.height)];
    
    if (pIndex == 0)
        [secondImg drawInRect:CGRectMake(0, 0, targetSize.width, targetSize.height / 11.0 * sIndex) blendMode:kCGBlendModeNormal alpha:1.0];
    else if (pIndex == 1)
        [secondImg drawInRect:CGRectMake(0, targetSize.height / 11.0 * (11 - sIndex), targetSize.width ,targetSize.height / 11.0 * sIndex ) blendMode:kCGBlendModeNormal alpha:1.0];
    else if (pIndex == 2)
        [secondImg drawInRect:CGRectMake(targetSize.width  / 11.0 * (11 - sIndex), 0, targetSize.width  / 11.0 * sIndex , targetSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    else if (pIndex == 3)
        [secondImg drawInRect:CGRectMake(0, 0, targetSize.width / 11.0 * sIndex,targetSize.height) blendMode:kCGBlendModeNormal alpha:1.0];
    else{ //Second Motion
        float targetRatio = 5.0; // 1/5
        float secondMotionScale = 1.0 / (FRAMECNT_PER_SECOND / (targetRatio - 1.0) * targetRatio) * (FRAMECNT_PER_SECOND / (targetRatio - 1.0) * (targetRatio + 1) - sIndex - FRAMECNT_PER_SECOND / (targetRatio - 1.0));
        [secondImg drawInRect:CGRectMake(0, 0, targetSize.width * secondMotionScale, targetSize.height  * secondMotionScale) blendMode:kCGBlendModeNormal alpha:1.0];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


- (void) generateMotionTempFiles:(UIImage *) bgImagePath thumbPath:(UIImage *)thumb
{
    //First Motion
    
    //NSString *lastPieceImgName = bgImagePath;
    UIImage *lastPieceImgName = bgImagePath;
    for (int i = 0; i < 4; i++){
        for (int j = 0; j < FRAMECNT_PER_SECOND / 2; j++) {
            [self composeImage:lastPieceImgName SecondImagePath:croppedPath[i] TargetSize:VIDEO_SIZE OutputFileName:[NSString stringWithFormat:TMP_PATH_FORMAT_MOTION_IMAGE, (int)(i * FRAMECNT_PER_SECOND / 2 + j)] PieceIndex:i SubIndex:j lastimage:&lastPieceImgName];
        }
    }
    //Second Motion
    
    for (int i = 0; i < FRAMECNT_PER_SECOND; i ++) {
        [self composeImage:thumb SecondImagePath:lastPieceImgName TargetSize:VIDEO_SIZE OutputFileName:[NSString stringWithFormat:TMP_PATH_FORMAT_MOTION_IMAGE, (int)(4 * FRAMECNT_PER_SECOND / 2 + i)] PieceIndex:5 SubIndex:i lastimage:nil];
        [NSThread sleepForTimeInterval:0.1];

    }
    
}

- (void) removeFile:(NSString *) filePath{
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if ([fileMgr fileExistsAtPath:filePath]) {
        NSLog(@"FileExist %@", filePath);
        if ([fileMgr removeItemAtPath:filePath error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    }
}

- (void) removeTmpFiles{
    NSLog(@"Start removeTempFiles");
    
    //Remove CropedPiece Image
    for (int i = 0; i < PIECE_CNT; i++) {
        [self removeFile:[NSString stringWithFormat:TMP_PATH_FORMAT_CROP_IMAGE, i]];
    }
    
    //Remove motionTemp Files
    for (int i = 0; i < PIECE_CNT * FRAMECNT_PER_SECOND / 2 + FRAMECNT_PER_SECOND; i++) {
        [self removeFile:[NSString stringWithFormat:TMP_PATH_FORMAT_MOTION_IMAGE, i]];
    }
}

- (void) removeTempVideos {
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:splashVideo]) {
        NSError* error;
        if ([fileManager removeItemAtPath:splashVideo error:&error] == NO) {
            NSLog(@"Could not delete old recording:%@", [error localizedDescription]);
        }
    }
    
    if ([fileManager fileExistsAtPath:transitionVideo]) {
        NSError* error;
        if ([fileManager removeItemAtPath:transitionVideo error:&error] == NO) {
            NSLog(@"Could not delete old recording:%@", [error localizedDescription]);
        }
    }
    
    if ([fileManager fileExistsAtPath:previousVideo]) {
        NSError* error;
        if ([fileManager removeItemAtPath:previousVideo error:&error] == NO) {
            NSLog(@"Could not delete old recording:%@", [error localizedDescription]);
        }
    }
    
}

- (void) MakeVideo{
    [self makePreviousVideo];
    
}

- (void) makePreviousVideo {
    NSLog(@"makePreviousVideo Start...");
    [self mergeVideo:splashVideo onVideo:transitionVideo finalVideo:previousVideo];
    NSLog(@"makePreviousVideo End...");
    
}

- (void) makePipBackVideo {
    NSLog(@"makePipBackVideo Start...");
    [self composeVideo:pipVideoPath onVideo:backgoundVideoPath fileName:pipBackVideo];
    NSLog(@"makePipBackVideo End...");
    
}

- (void) makeComposeVideo {
    NSLog(@"makeComposeVideo Start...");
    [self addWaterImageToVideo:pipBackVideo ImagePath:waterImagePath ExportPath:waterMarkVideoPath];
    NSLog(@"makeComposeVideo End...");
    
}

- (void) makeSplashVideo {
    // Create 2Second Video with Background Image
    [self saveFourPieceImages:overlayPath];
    [self createVideo:1 Duration:2 OutputPath:splashVideo];
}

- (void) makeTransitionVideo {
    [NSThread sleepForTimeInterval:1];

    [self createVideo:PIECE_CNT * FRAMECNT_PER_SECOND / 2 + FRAMECNT_PER_SECOND Duration:3 OutputPath:transitionVideo];
    
    [delegate TransitionComplete];
}

- (void) addWaterImageToVideo:(NSString *) videoPath ImagePath:(NSString *) imgPath ExportPath:(NSString *) exportPath{
    
    NSLog(@"addWaterImageToVideo Start...");
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
    {
        NSLog(@"File Exists!");
    }
    else
    {
        NSLog(@"File DOESN'T Exist!");
    }
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo  preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                   ofTrack:clipVideoTrack
                                    atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    }
    
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    AVAssetTrack *track = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    CGSize videoSize = CGSizeApplyAffineTransform(track.naturalSize, track.preferredTransform);
    
    CGSize logoSize = CGSizeMake(videoSize.width * 0.3, videoSize.height * 0.2);
    
    UIImage *myImage = [UIImage imageNamed:imgPath];
    CALayer *aLayer = [CALayer layer];
    aLayer.contents = (id)myImage.CGImage;
    aLayer.frame = CGRectMake(videoSize.width - logoSize.width * 1.05, logoSize.height * 0.05, logoSize.width, logoSize.height); //Needed for proper display. We are using the app icon (57x57). If you use 0,0 you will not see it
    aLayer.opacity = 1.0; //Feel free to alter the alpha here
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:aLayer];
    
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    float scaleW = 1.0f;//VIDEO_SIZE.width / [[[videoAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].width;
    float scaleH = 1.0f; //VIDEO_SIZE.height / [[[videoAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].height;
    
    CGAffineTransform Scale = CGAffineTransformMakeScale(scaleW, scaleH);
    CGAffineTransform Move = CGAffineTransformMakeTranslation(0.0, 0.0);
    
    [layerInstruction setTransform:CGAffineTransformConcat(Scale, Move) atTime:kCMTimeZero];
    
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    
    AVMutableVideoComposition* videoComp = [AVMutableVideoComposition videoComposition];
    videoComp.renderSize = VIDEO_SIZE;
    videoComp.instructions = [NSArray arrayWithObject: instruction];
    videoComp.frameDuration = CMTimeMake(1, 30);
    videoComp.animationTool = [AVVideoCompositionCoreAnimationTool      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:QUALITY];
    _assetExport.videoComposition = videoComp;
    
    //Add the file name
    NSURL    *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    
    _assetExport.outputFileType = AVFileTypeMPEG4;
    _assetExport.outputURL = exportUrl;
    _assetExport.shouldOptimizeForNetworkUse = YES;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         if (_assetExport.error)
             NSLog(@"AddWater Error: %@", _assetExport.error);
         
         [self mergeVideo:previousVideo onVideo:waterMarkVideoPath finalVideo:composeVideoPath];
     }
     ];
    
    videoAsset = nil;
    
    
    NSLog(@"addWaterImageToVideo End...");
}

- (void) mergeVideo:(NSString*)firstVideo onVideo:(NSString*)secondVideo finalVideo:(NSString*)finalVideo
{

    
    @try {
        NSURL *path1 = [NSURL fileURLWithPath:firstVideo];
        
        NSURL *path2 = [NSURL fileURLWithPath:secondVideo];
        
        Asset1 = [[AVURLAsset alloc] initWithURL:path1 options:nil];
        Asset2 = [[AVURLAsset alloc] initWithURL:path2 options:nil];
        
        
        if (Asset1 !=nil && Asset2!=nil)
        {
            // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
            AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
            
            // 2 - Video track
            AVMutableCompositionTrack *firstTrack =
            [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                        preferredTrackID:kCMPersistentTrackID_Invalid];
            
            [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, Asset1.duration)
                                ofTrack:[Asset1 tracksWithMediaType:AVMediaTypeVideo].firstObject
                                 atTime:kCMTimeZero
                                  error:nil];
            
            [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, Asset2.duration)
                                ofTrack:[Asset2 tracksWithMediaType:AVMediaTypeVideo].firstObject
                                 atTime:CMTimeAdd(kCMTimeZero, Asset1.duration)
                                  error:nil];
            
            if ([[Asset1 tracksWithMediaType:AVMediaTypeAudio] count] != 0 || [[Asset2 tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
                AVMutableCompositionTrack *audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                
                __block BOOL mediaReady = YES;
                if ([[Asset1 tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
                    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, Asset1.duration) ofTrack:[[Asset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
                }
                else // Add a blank track???
                {
                    
                    AVURLAsset *blank = [AVURLAsset URLAssetWithURL:[NSBundle.mainBundle URLForResource:@"empty" withExtension:@"mp3"] options:nil];
                    //AVURLAsset *blank = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:[NSBundle.mainBundle pathForResource:@"0917" ofType:@"wav"]] options:nil];
                    if (blank != nil)
                    {
                        if ([blank isPlayable])
                        {
                            mediaReady = NO;
                            NSString *tracksKey = @"tracks";
                            
                            [blank loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
                             ^{
                                 NSError *error;
                                 AVKeyValueStatus status = [blank statusOfValueForKey:tracksKey error:&error];
                                 if (status == AVKeyValueStatusLoaded) {
                                     // The asset is ready at this point
                                     //NSArray *tmp = [blank tracks];
                                     NSArray *tmp = [blank tracksWithMediaType:AVMediaTypeAudio];
                                     
                                     if ([tmp count])
                                     {
                                         [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, Asset1.duration) ofTrack:[tmp objectAtIndex:0] atTime:kCMTimeZero error:nil];
                                     }
                                     
                                 }
                                 mediaReady = YES;
                             }];
                            
                            while (!mediaReady)
                            {
                                NSLog(@"Waiting...");
                                [NSThread sleepForTimeInterval:0.5f];
                            }
                        }
                        
                    }
                    
                    else
                    {
                        NSLog(@"Not Playable");
                    }
                }
                
                
                if ([[Asset2 tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
                    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, Asset2.duration) ofTrack:[[Asset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:CMTimeAdd(kCMTimeZero, Asset1.duration) error:nil];
                }
            }
            
            //convert video size to VIDEO_SIZE
            
            float scale_x1 = VIDEO_SIZE.width / [[Asset1 tracksWithMediaType:AVMediaTypeVideo].firstObject naturalSize].width;
            float scale_x2 = VIDEO_SIZE.width / [[Asset2 tracksWithMediaType:AVMediaTypeVideo].firstObject naturalSize].width;
            float scale_y1 = VIDEO_SIZE.height / [[Asset1 tracksWithMediaType:AVMediaTypeVideo].firstObject naturalSize].height;
            float scale_y2 = VIDEO_SIZE.height / [[Asset2 tracksWithMediaType:AVMediaTypeVideo].firstObject naturalSize].height;
            
            float scaleW = (scale_x1 > scale_x2) ? scale_x2 : scale_x1;
            float scaleH = (scale_y1 > scale_y2) ? scale_y2 : scale_y1;
            NSLog(@"scale_x1=%f scale_x2 = %f scale_y1 = %f scale_y2=%f scaleW=%f scaleH = %f", scale_x1, scale_x2, scale_y1, scale_y2, scaleW, scaleH);
            
            
            AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
            
            CGAffineTransform Scale = CGAffineTransformMakeScale(scaleW, scaleH);
            CGAffineTransform Move = CGAffineTransformMakeTranslation(0.0, 0.0);
            
            [layerInstruction setTransform:CGAffineTransformConcat(Scale, Move) atTime:kCMTimeZero];
            
            // Create an AVMutableVideoComposition object.
            AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
            MainCompositionInst.instructions = [NSArray arrayWithObject:layerInstruction];
            MainCompositionInst.frameDuration = CMTimeMake(1, 30);
            
            // Set the render size to the screen size.
            MainCompositionInst.renderSize = VIDEO_SIZE;
            
            // 4 - Get path
            NSURL *url = [NSURL fileURLWithPath:finalVideo];
            
            // Make sure the video doesn't exist.
            if ([[NSFileManager defaultManager] fileExistsAtPath:finalVideo])
            {
                [[NSFileManager defaultManager] removeItemAtPath:finalVideo error:nil];
            }
            
            // 5 - Create exporter
            AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                              presetName:QUALITY];
            exporter.outputURL=url;
            exporter.outputFileType = AVFileTypeMPEG4;
            exporter.shouldOptimizeForNetworkUse = YES;
            [exporter exportAsynchronouslyWithCompletionHandler:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (exporter.error)
                        NSLog(@"Merge Video Error: %@", exporter.error);
                    
                    if (isComposedPreviousVideo) {
                        [self mergeExportDidFinish:exporter];
                        
                    } else {
                        isComposedPreviousVideo = TRUE;
                        if ([pipVideoPath isEqualToString:@""])
                            [self makeComposeVideo];
                        else
                            [self makePipBackVideo];
                    }
                });
            }];
        }
        
        
    }
    @catch (NSException *ex) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error 1" message:[NSString stringWithFormat:@"%@",ex]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        }];
    }
    
    
}

-(void)mergeExportDidFinish:(AVAssetExportSession*)session {
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
                        [self removeTempVideos];
                        [delegate finished];
    }
    else
    {
        [delegate failed];
    }
    
    Asset1 = nil;
    Asset2 = nil;
    
    
}


- (void) composeVideo:(NSString*)videoPIP onVideo:(NSString*)videoBG fileName:(NSString*)fileName
{
    @try {
        NSError *e = nil;
        
        // Load our 2 movies using AVURLAsset
        pipAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoPIP] options:nil];
        backAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoBG] options:nil];
        
        //float largeScale = screenHeight / [[[backAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].width;
        
        float scaleH = VIDEO_SIZE.height / [[[backAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].width;
        float scaleW = VIDEO_SIZE.width / [[[backAsset tracksWithMediaType:AVMediaTypeVideo ] objectAtIndex:0] naturalSize].height;
        
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
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, (pipAsset.duration.value > backAsset.duration.value) ? pipAsset.duration : backAsset.duration);
        
        // Create an AVMutableVideoCompositionLayerInstruction object to make use of CGAffinetransform to move and scale our First Track so it is displayed at the bottom of the screen in smaller size.
        AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        
        CGAffineTransform Scale1 = CGAffineTransformMakeScale(0.3f,0.3f);
        
        
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
        
        // Make sure the video doesn't exist.
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
        {
            [[NSFileManager defaultManager] removeItemAtPath:fileName error:nil];
        }
        
        // Now we need to save the video.
        NSURL *url = [NSURL fileURLWithPath:pipBackVideo];
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                          presetName:QUALITY];
        exporter.videoComposition = MainCompositionInst;
        exporter.outputURL=url;
        exporter.outputFileType = AVFileTypeMPEG4;
        [exporter exportAsynchronouslyWithCompletionHandler:^{
            if (exporter.error)
                NSLog(@"Compose Video Error: %@", exporter.error);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self makeComposeVideo];
            });
        }];
        
        pipAsset = nil;
        backAsset = nil;
        
        
    }
    @catch (NSException *ex) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error 3" message:[NSString stringWithFormat:@"%@",ex]
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        }];
    }
    
    
}


@end
