//
//  ProfilePictureViewController.h
//  Unrapp
//
//  Created by Robert Durish on 3/18/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"

@interface ProfilePictureViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate>
{
    UIImagePickerController *imagePicker;
}
@property (weak, nonatomic) IBOutlet GBPathImageView *profilePicture;

@end
