//
//  PictureGiftUIViewController.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 3/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AdobeCreativeSDKImage/AdobeCreativeSDKImage.h>

@interface PictureGiftUIViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate, AdobeUXImageEditorViewControllerDelegate>

// @property (weak, nonatomic) IBOutlet UITextView *giftMessageUITextView;

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@end
