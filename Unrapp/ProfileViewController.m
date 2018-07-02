//
//  ProfileViewController.m
//  Unrapp
//
//  Created by Robert Durish on 3/4/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "ProfileViewController.h"

#import "SVProgressHUD.h"
#import "GiftReceipents.h"
#import "ProfileCollectionViewCell.h"
#import "WebService.h"
#import "UIImageLoader.h"
#import "MPCoachMarks.h"

@interface ProfileViewController ()

@property NSURLSessionDataTask * task;
@property NSURL * activeImageURL;
@end

//extern UIImage *userImage;

@implementation ProfileViewController


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
    if(!self.passedUser)
    {
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateDeletionMode:)];
        lp.delegate = self;
        [self.myCollectionView addGestureRecognizer:lp];
        self.logoutBtn.title = @"";
        if (!self.logoutBtn.image)
            self.logoutBtn.image = [UIImage imageNamed:@"giftcardico.png"];
        
        [self getTraining];
    }
    else
    {
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(activateReportMode:)];
        lp.delegate = self;
        [self.myCollectionView addGestureRecognizer:lp];
        
        self.logoutBtn.title= @"Block";
    }
    myGifts = [[NSMutableArray alloc] init];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationBlock:)
                                                name:@"BlockUser"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationGifts:)
                                                name:@"GetProfileGifts"
                                              object:nil];
    
    [self bindPage];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"BlockUser"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"GetProfileGifts"
                                                  object:nil];
}

-(void) bindPage
{
    // Get all of this user's sent gifts
    [SVProgressHUD showWithStatus:@"Retreiving Profile"];
    
    WSUser *currentUser = [[WSUser alloc] init]; //[WebService getLoggedInUser];
    
    if (self.passedUser)
    {
        self.editButton.hidden = YES;
        
        currentUser.userID = [self.passedUser objectForKey:@"userID"];
        currentUser.username = [self.passedUser objectForKey:@"username"];
        currentUser.userImage = [self.passedUser objectForKey:@"userImage"];
        currentUser.firstName = [self.passedUser objectForKey:@"firstName"];
        currentUser.lastName = [self.passedUser objectForKey:@"lastName"];
        currentUser.location = [self.passedUser objectForKey:@"location"];
        currentUser.email = [self.passedUser objectForKey:@"email"];
        currentUser.tagline = [self.passedUser objectForKey:@"tagline"];
        currentUser.zipcode = [self.passedUser objectForKey:@"zipcode"];
        currentUser.phone = [self.passedUser objectForKey:@"phone"];
        //currentUser.APIKey = [self.passedUser objectForKey:@"UserAPIKey"];
        currentUser.disabled = [[self.passedUser objectForKey:@"disabled"] boolValue];
        currentUser.followers = [self.passedUser objectForKey:@"followers"];
        currentUser.following = [self.passedUser objectForKey:@"following"];
        
        
        
    }
    else
    {
        currentUser = [WebService getLoggedInUser];
        self.editButton.hidden = NO;
    }
    
    self.myImage.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
    [self.myImage setPathColor:[UIColor lightGrayColor]];
    [self.myImage setBorderColor:[UIColor lightGrayColor]];
    [self.myImage setPathWidth:2.0];
    [self.myImage setPathType:GBPathImageViewTypeCircle];
    [self.myImage draw];
    
    if (![currentUser.userImage isEqualToString:@""])
    {
        NSURL * url = [NSURL URLWithString:currentUser.userImage];
        self.activeImageURL = url;
       self.task = [[UIImageLoader defaultLoader] loadImageWithURL:url
       hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
           
           //hide indicator as we have a cached image available.
           self.indicator.hidden = TRUE;
           
           //use cached image
           self.myImage.image = image;
           [self.myImage setPathColor:[UIColor lightGrayColor]];
           [self.myImage setBorderColor:[UIColor lightGrayColor]];
           [self.myImage setPathWidth:2.0];
           [self.myImage setPathType:GBPathImageViewTypeCircle];
           [self.myImage draw];
           NSLog(@"Using Cache.");
           
       } sendingRequest:^(BOOL didHaveCachedImage) {
           
           if(!didHaveCachedImage) {
               //a cached image wasn't available, a network request is being sent, show spinner.
               [self.indicator startAnimating];
               self.indicator.hidden = FALSE;
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
           self.indicator.hidden = TRUE;
           [self.indicator stopAnimating];
           
           //if image was downloaded, use it.
           if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
               NSLog(@"Image Downloaded.");
               self.myImage.image = image;
               [self.myImage setPathColor:[UIColor lightGrayColor]];
               [self.myImage setBorderColor:[UIColor lightGrayColor]];
               [self.myImage setPathWidth:2.0];
               [self.myImage setPathType:GBPathImageViewTypeCircle];
               [self.myImage draw];
           }
       }];
        
    }
    
    
    self.myTagline.text = currentUser.tagline;
    self.myLocation.text = currentUser.location;
    self.myName.text = [[currentUser.firstName stringByAppendingString:@" "] stringByAppendingString:currentUser.lastName];
    self.myFollowing.text = [currentUser.following stringValue];
    self.myFollowers.text = [currentUser.followers stringValue];
    
   [WebService getProfileGiftsFor:[currentUser.userID intValue]];
}

-(void)wsNotificationGifts:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"GetProfileGifts"];
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
                myGifts = [[dict objectForKey:@"Gifts"] mutableCopy];
                [self.myCollectionView reloadData];
                [SVProgressHUD dismiss];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [myGifts count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProfileCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"profileGift" forIndexPath:indexPath];
    
    //GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    //[selectedGiftToView setSelectedGiftToView:[myGifts objectAtIndex:indexPath.row]];
    
    [cell setImageURL:[[myGifts objectAtIndex:indexPath.row] objectForKey:@"giftURL" ]];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomIOS7AlertView *alertView = [[CustomIOS7AlertView alloc] init];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    
    //GiftReceipents* selectedGiftToView = [GiftReceipents getInstance];
    //[selectedGiftToView setSelectedGiftToView:[myGifts objectAtIndex:indexPath.row]];
    
    NSString *tmp = [[myGifts objectAtIndex:indexPath.row] objectForKey:@"giftURL"];
    
    NSURL * url = [NSURL URLWithString:tmp];
    [[UIImageLoader defaultLoader] loadImageWithURL:url
                 
                                                       hasCache:^(UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                           
                                                           //hide indicator as we have a cached image available.
                                                           self.indicator.hidden = TRUE;
                                                           
                                                           //use cached image
                                                           imgView.image = image;
                                                           NSLog(@"Using Cache.");
                                                           
                                                       } sendingRequest:^(BOOL didHaveCachedImage) {
                                                           
                                                       } requestCompleted:^(NSError *error, UIImageLoaderImage *image, UIImageLoadSource loadedFromSource) {
                                                           
                                                           //request complete.
                                                           NSLog(@"Complete");
                                                           
                                                           //if image was downloaded, use it.
                                                           if(image){ //loadedFromSource == UIImageLoadSourceNetworkToDisk) {
                                                               NSLog(@"Image Downloaded.");
                                                               imgView.image = image;
                                                           }
                                                           else if (error)
                                                           {
                                                               NSLog(@"There was an error");
                                                               imgView.image = [UIImage imageNamed:@"unrapp_icon_80x80.png"];
                                                           }
                                                       }];



    [alertView setContainerView:imgView];
    [alertView setDelegate:self];
    [alertView show];

}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [alertView close];
}
- (IBAction)logoutPushed:(id)sender {
    
    if (!self.passedUser)
    {
//        [SVProgressHUD showWithStatus:@"Logging Out ..."];
//                
//        [WebService logOutUser];
//        
//        [SVProgressHUD dismiss];
//        self.tabBarController.selectedIndex = 0;
        // Now we send to GiftCard Wallet...
        [self performSegueWithIdentifier:@"showGiftcards" sender:self];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Blocking user from sending you any further gifts."];
        [WebService blockUser:[[_passedUser objectForKey:@"userID"] intValue]];
    }
}
-(void)wsNotificationBlock:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"BlockUser"];
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

NSInteger rowNumToDelete;

-(void)activateDeletionMode:(UILongPressGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *ip = [self.myCollectionView indexPathForItemAtPoint:[gr locationInView:self.myCollectionView]];
        rowNumToDelete = ip.row;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Are you sure?"
                                                       message: @"You are about to remove this item from your profile."
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        [alert setTag:1];
        [alert show];
    }
}

-(void)activateReportMode:(UILongPressGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *ip = [self.myCollectionView indexPathForItemAtPoint:[gr locationInView:self.myCollectionView]];
        rowNumToDelete = ip.row;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Are you sure?"
                                                       message: @"You are about to report this item."
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        [alert setTag:2];
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) { // UIAlertView with tag 1 detected
        if (buttonIndex == 1)
        {
            
            // Any action can be performed here
            NSDictionary *p = [myGifts objectAtIndex:rowNumToDelete];
            [WebService RemoveGiftFromProfile:[[p objectForKey:@"GiftID"] intValue]];
            
            [myGifts removeObjectAtIndex:rowNumToDelete];
            
            [self.myCollectionView reloadData];
        }
    } else if (alertView.tag == 2) { // UIAlertView with tag 2 detected
        if (buttonIndex == 1)
        {
            NSDictionary *p = [myGifts objectAtIndex:rowNumToDelete];
            [WebService ReportGift:[[p objectForKey:@"GiftID"] intValue]];
            
            UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle: @"Image Reported"
                                                           message: @"This image has been reported, if found inappropriate a member of our team will address it."
                                                          delegate: self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil];
            [alert1 show];
        }
    }
}

-(void)getTraining
{
    // Show coach marks
    BOOL coachMarksShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"MPCoachMarksShownProfile"];
    if (coachMarksShown == NO) {
        // Don't show again
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MPCoachMarksShownProfile"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Setup Marks...
        NSArray *coachMarks = @[
                                @{
                                    @"rect": [NSValue valueWithCGRect:CGRectMake([[UIScreen mainScreen] bounds].size.width - 50, 20, 40, 40)],
                                    @"caption" :@"Tapping this icon will display your gift cards from friends."
                                    }
                                ];
        
        MPCoachMarks *coachMarksView = [[MPCoachMarks alloc] initWithFrame:self.tabBarController.view.bounds coachMarks:coachMarks];
        
        [self.tabBarController.view addSubview:coachMarksView];
        
        // Show coach marks
        [coachMarksView performSelector:@selector(start) withObject:nil afterDelay:0.5f];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



@end
