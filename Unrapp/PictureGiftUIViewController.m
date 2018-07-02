//
//  PictureGiftUIViewController.m
//  Unrapp
//
//  Created by George R. Cain Jr. on 3/8/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import "PictureGiftUIViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>

#import "GiftReceipents.h"
#import "SVProgressHUD.h"

@interface PictureGiftUIViewController ()

@end

@implementation PictureGiftUIViewController

UIImagePickerController *imagePicker;
UIImage *imagePicked;
bool editingPhoto;
//NSString *videoFilePath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    editingPhoto = NO;
    //self.giftMessageUITextView.delegate = self;
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    imagePicked = nil;
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // Navigation button was pressed. Do some stuff
         GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
        [selectedGiftImage setGiftImage:nil];
        imagePicked = nil;
        editingPhoto = NO;
        [selectedGiftImage setIsTakePicture:NO];
        [selectedGiftImage setIsChoosePicture:NO];
    }
    [super viewWillDisappear:animated];
}


- (void) viewWillAppear:(BOOL)animated {
    
    [super didReceiveMemoryWarning];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
    
    if (selectedGiftImage.getGiftImage != nil)
    {
        //[selectedGiftImage setGiftImage:nil];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        if (imagePicked)
        {
            // Save the image gift before selecting the receipents
            GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
            [selectedGiftImage setGiftImage:imagePicked];
        }
    else if ([selectedGiftImage getIsTakePicture])
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:NO completion:nil];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"No Camera Supported."];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
    else // Camera Roll
    {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.navigationBar.backgroundColor = [UIColor blackColor];
            [self presentViewController:imagePicker animated:NO completion:nil];
        }
        else
        {
            
            [SVProgressHUD showErrorWithStatus:@"No Camera Roll Supported."];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        
    }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Image Picker

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!imagePicked)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    self.previewImageView.image = imagePicked;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    
    // Save the image gift before selecting the receipents
    GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
    [selectedGiftImage setGiftImage:imagePicked];
    
    //if ([self.giftMessageUITextView.text isEqualToString:@"Enter a gift message here ..."])
    //{
        [selectedGiftImage setGiftMessage:@""];
    //}
    //else
    //{
    //    [selectedGiftImage setGiftMessage:self.giftMessageUITextView.text];
    //}
    
    return true;
}

# pragma mark - Text View Delegates

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //if ([self.giftMessageUITextView.text isEqualToString:@"Enter a gift message here ..."])
    //{
    //    self.giftMessageUITextView.text = @"";
    //}
    
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

# pragma mark - Image Customization

- (IBAction)buttonPressed
{
    
    AdobeUXImageEditorViewController *editorController = [[AdobeUXImageEditorViewController alloc] initWithImage:imagePicked];
    
    //Set Tools.
    [AdobeImageEditorCustomization setToolOrder:@[kAdobeImageEditorEffects, kAdobeImageEditorCrop, kAdobeImageEditorText, kAdobeImageEditorDraw, kAdobeImageEditorStickers, kAdobeImageEditorMeme, kAdobeImageEditorBlur, kAdobeImageEditorSplash, kAdobeImageEditorOverlay, kAdobeImageEditorLightingAdjust]];
    
    [editorController setDelegate:self];
    
    editingPhoto = YES;
    
    [self presentViewController:editorController animated:YES completion:nil];
    
}
- (void)photoEditor:(AdobeUXImageEditorViewController *)editor finishedWithImage:(UIImage *)image
{
        if (image)
        {
            //Do something with the resulting UIImage
            imagePicked = image;
            self.previewImageView.image = imagePicked;
    
            GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
            [selectedGiftImage setGiftImage:imagePicked];
        }
        editingPhoto = NO;
    
        //Dismiss the editor
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoEditorCanceled:(AdobeUXImageEditorViewController *)editor
{
    //Dismiss the editor
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
