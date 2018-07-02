//
//  ProfilePictureViewController.m
//  Unrapp
//
//  Created by Robert Durish on 3/18/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "ProfilePictureViewController.h"
#import "SVProgressHUD.h"
#import "WebService.h"
#import "UIImageLoader.h"

@interface ProfilePictureViewController ()
@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;

@end

//extern UIImage *userImage;
UIImage *pickedImage;
@implementation ProfilePictureViewController
//@synthesize imagePicker;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    self.navigationController.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    
   
    
    self.profilePicture.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
    [self.profilePicture setPathColor:[UIColor lightGrayColor]];
    [self.profilePicture setBorderColor:[UIColor lightGrayColor]];
    [self.profilePicture setPathWidth:2.0];
    [self.profilePicture setPathType:GBPathImageViewTypeCircle];
    [self.profilePicture draw];
    
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    
    
    
    /////////
   

    /////////
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"UploadUserImage"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationUpload:)
                                                name:@"ImageUpload"
                                              object:nil];
    
     WSUser *currentUser = [WebService getLoggedInUser];
    NSURL * url = [NSURL URLWithString:currentUser.userImage];
    self.activeImageURL = url;
    self.task = [[UIImageLoader defaultLoader] loadImageWithURL:url
                                                       hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                           
                                                           //hide indicator as we have a cached image available.
                                                           //self.indicator.hidden = TRUE;
                                                           
                                                           //use cached image
                                                           self.profilePicture.image = image;
                                                           [self.profilePicture setPathColor:[UIColor lightGrayColor]];
                                                           [self.profilePicture setBorderColor:[UIColor lightGrayColor]];
                                                           [self.profilePicture setPathWidth:2.0];
                                                           [self.profilePicture setPathType:GBPathImageViewTypeCircle];
                                                           [self.profilePicture draw];
                                                           
                                                       } sendingRequest:^(BOOL didHaveCachedImage) {
                                                           
                                                           if(!didHaveCachedImage) {
                                                               //a cached image wasn't available, a network request is being sent, show spinner.
                                                               //[self.indicator startAnimating];
                                                               //self.indicator.hidden = FALSE;
                                                           }
                                                           
                                                       } requestCompleted:^(NSError *error, UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                           
                                                           //request complete.
                                                           NSLog(@"Complete");
                                                           //check if url above matches self.activeURL.
                                                           //If they don't match this cells image is going to be different.
                                                           if (!error)
                                                               if(![self.activeImageURL.absoluteString isEqualToString:url.absoluteString]) {
                                                                   NSLog(@"request finished, but images don't match.");
                                                                   return;
                                                               }
                                                           
                                                           //hide spinner
                                                           //self.indicator.hidden = TRUE;
                                                           //[self.indicator stopAnimating];
                                                           
                                                           //if image was downloaded, use it.
                                                           if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
                                                               NSLog(@"Image Downloaded.");
                                                               self.profilePicture.image = image;
                                                               [self.profilePicture setPathColor:[UIColor lightGrayColor]];
                                                               [self.profilePicture setBorderColor:[UIColor lightGrayColor]];
                                                               [self.profilePicture setPathWidth:2.0];
                                                               [self.profilePicture setPathType:GBPathImageViewTypeCircle];
                                                               [self.profilePicture draw];
                                                           }
                                                           
                                                           UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Select Source:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                                                                   @"Camera",
                                                                                   @"Photo Gallery",
                                                                                   nil];
                                                           popup.tag = 1;
                                                           [popup showInView:[UIApplication sharedApplication].keyWindow];
                                                       }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UploadUserImage"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"ImageUpload"
                                                  object:nil];
}

-(void)wsNotificationUpload:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"ImageUpload"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
            [SVProgressHUD showWithStatus:@"Updating Profile Image"];

            // Call Another WS.
            [WebService UploadUserImage:[dict objectForKey:@"Message"]];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
}

-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"UploadUserImage"];
    if (!dict)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            // Network Error
            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
        }];
    }
    else
    {
        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
        if ([isSuccessNumber boolValue] == YES)
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
                // Pop to Root.
                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
            }];
        }
    }
    
}
- (IBAction)touchSave:(id)sender {
    [SVProgressHUD showWithStatus:@"Uploading Profile Image"];
    // Upload image
    [WebService UploadImage:pickedImage withName:@"userProfile"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - ActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
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
                    break;
                case 1:
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
                    {
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        [self presentViewController:imagePicker animated:NO completion:nil];
                    }
                    else
                    {
                        
                        [SVProgressHUD showErrorWithStatus:@"No Camera Roll Supported."];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                        
                    }
                    break;
                default:
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    break;
            }
            break;
        }
        default:
            break;
    }
}
- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (!pickedImage)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showErrorWithStatus:@"No Image Selected/Found."];
    }
    else
    {
        self.profilePicture.image = pickedImage;
        [self.profilePicture setImage:pickedImage];
        [self.profilePicture setPathColor:[UIColor lightGrayColor]];
        [self.profilePicture setBorderColor:[UIColor lightGrayColor]];
        [self.profilePicture setPathWidth:2.0];
        [self.profilePicture setPathType:GBPathImageViewTypeCircle];
        [self.profilePicture draw];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
