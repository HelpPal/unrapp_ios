//
//  PaymentsCollectionViewController.m
//  Unrapp
//
//  Created by Durish on 10/11/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "PaymentsCollectionViewController.h"
#import "WebService.h"
#import "SVProgressHUD.h"
#import "PaymentCollectionViewCell.h"
#import "GiftReceipents.h"
#import <AcceptSDK/AcceptSDK.h>

@interface PaymentsCollectionViewController ()

@end

@implementation PaymentsCollectionViewController

NSMutableArray *myPayments;
static NSString * const reuseIdentifierCard = @"CellCard";
static NSString * const reuseIdentifierAdd = @"CellAdd";
- (IBAction)close:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Register cell classes
    //[self.collectionView registerClass:[PaymentCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierCard];
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifierAdd];
    
    // Do any additional setup after loading the view.
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.collectionView addGestureRecognizer:lpgr];
    
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotification:)
                                                name:@"getCustomerPaymentMethods"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationPurchase:)
                                                name:@"makePaymentTransaction"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationSendGift:)
                                                name:@"InsertGiftCardGift"
                                              object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(wsNotificationDelete:)
                                                name:@"DeleteCustomerPaymentMethod"
                                              object:nil];
    
    [CardIOUtilities preloadCardIO];
    
    [SVProgressHUD showWithStatus:@"Loading..."];
    [WebService getPaymentOptions];
    
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"getCustomerPaymentMethods"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"makePaymentTransaction"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"InsertGiftCardGift"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"DeleteCustomerPaymentMethod"
                                                  object:nil];
}

-(void)wsNotification:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"getCustomerPaymentMethods"];
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
            myPayments = [[dict objectForKey:@"Items"] mutableCopy];
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                if (myPayments)
                {
                    if ([myPayments count] > 0)
                    {
                        selected = [myPayments objectAtIndex:0];
                    }
                }
                [self.collectionView reloadData];
                [SVProgressHUD dismiss];
            }];
            
        }
        else
        {
            
            // The login failed. Check error to see why.
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
                [self.collectionView reloadData];
            }];
            
            
        }
    }
}

-(void)wsNotificationDelete:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"DeleteCustomerPaymentMethod"];
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
                [WebService getPaymentOptions];
            }];
            
        }
        else
        {
            
            // The login failed. Check error to see why.
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
                [self.collectionView reloadData];
            }];
            
            
        }
    }
}

-(void)wsNotificationPurchase:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"makePaymentTransaction"];
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
                [SVProgressHUD showWithStatus:@"Purchase successful sending your gifts!"];
                
                [WebService SendGiftCard:[[self.passedData objectForKey:@"id"] intValue] and:[[self.passedData objectForKey:@"gbid"] intValue] attachedTo:[NSString stringWithFormat:@"%@",[dict objectForKey:@"orderID"]] Worth:[[self.passedEach substringFromIndex:1] doubleValue] toUser:self.passedPeople andShare:NO withVersion:[[self appVersionNumber] doubleValue]];
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

-(void)wsNotificationSendGift:(NSNotification *)notification
{
    NSDictionary *dict = [[notification userInfo]objectForKey:@"InsertGiftCardGift"];
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
                GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
                [selectedGiftImage setGiftImage:nil];
                [selectedGiftImage setGiftValue:@""];
                [selectedGiftImage setIsGiftCard:nil];
                [selectedGiftImage setSelectedGiftCard:nil];
                [selectedGiftImage setSelectedGiftReceipents:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (myPayments == nil)
        return 1;
    else
        return myPayments.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"This %ld == %lu?, Section: %lu", (long)indexPath.row, (unsigned long)myPayments.count), indexPath.section;
    if (indexPath.row == myPayments.count || myPayments == nil)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierAdd forIndexPath:indexPath];
        
        // Configure the cell
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
    else
    {
        PaymentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCard forIndexPath:indexPath];
        NSDictionary *dict = [myPayments objectAtIndex:indexPath.row];
        // Configure the cell
        cell.lblCardNum.text = [dict objectForKey:@"CardNumber"];
        if (![[dict objectForKey:@"artURL"] isEqualToString:@""])
            [cell setImageURL:[dict objectForKey:@"artURL"]];
        
        if (selected)
        {
            if ([dict objectForKey:@"CustomerPaymentID"] == [selected objectForKey:@"CustomerPaymentID"])
            {
                [cell setBackgroundColor:[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1]];
            }
            else
            {
                [cell setBackgroundColor:[UIColor clearColor]];
            }
        }
        else
        {
            [cell setBackgroundColor:[UIColor clearColor]];
        }
        return cell;
    }
}

#pragma mark <UICollectionViewDelegate>


NSDictionary *selected;
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == myPayments.count)
    {
        CardIOPaymentViewController *scanViewController = [[CardIOPaymentViewController alloc] initWithPaymentDelegate:self];
        
        [self presentViewController:scanViewController animated:YES completion:nil];
        return NO;
    }
    else
    {
        NSDictionary *dict = [myPayments objectAtIndex:indexPath.row];
        selected = dict;
        
        return YES;
    }
    
    return YES;
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

- (void)collectionView:(UICollectionView *)colView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [colView cellForItemAtIndexPath:indexPath];
    //set color with animation
    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [cell setBackgroundColor:[UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1]];
                     }
                     completion:nil];
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        [self.collectionView reloadData];
    }];
}

- (void)collectionView:(UICollectionView *)colView  didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)userDidCancelPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    NSLog(@"User canceled payment info");
    // Handle user cancellation here...
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(CardIOCreditCardInfo *)info inPaymentViewController:(CardIOPaymentViewController *)scanViewController {
    // The full card number is available as info.cardNumber, but don't log that!
    NSLog(@"Received card info. Number: %@, expiry: %tu/%tu, cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv);
    // Use the card info...
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        [SVProgressHUD showWithStatus:@"Running Transaction."];
    }];
    
    //LIVE
    AcceptSDKHandler *handler = [[AcceptSDKHandler alloc] initWithEnvironment:AcceptSDKEnvironmentENV_LIVE];
    AcceptSDKRequest *request = [[AcceptSDKRequest alloc] init];
    request.merchantAuthentication.name = @"5eLC5kx5bR"; //name
    request.merchantAuthentication.clientKey = @"5JVCKFSK24P6ZRv6LTQLsvTc6C2xvsxZTJN4TwnXQMSpLXv6j6b7Vn5BH9b955ac"; //clientkey
    AcceptSDKHandler *handler2 = [[AcceptSDKHandler alloc] initWithEnvironment:AcceptSDKEnvironmentENV_LIVE];
    AcceptSDKRequest *request2 = [[AcceptSDKRequest alloc] init];
    request2.merchantAuthentication.name = @"5eLC5kx5bR"; //name
    request2.merchantAuthentication.clientKey = @"5JVCKFSK24P6ZRv6LTQLsvTc6C2xvsxZTJN4TwnXQMSpLXv6j6b7Vn5BH9b955ac"; //clientkey
    
    // SANDBOX
//    AcceptSDKHandler *handler = [[AcceptSDKHandler alloc] initWithEnvironment:AcceptSDKEnvironmentENV_TEST];
//    AcceptSDKRequest *request = [[AcceptSDKRequest alloc] init];
//    request.merchantAuthentication.name = @"9z2L9GRmczB"; //name
//    request.merchantAuthentication.clientKey = @"8V7fkF7p7BUh4cZLA7f2PsRkVsgNd2Hru39Xq5xSnT9Z96ucgc8Fuhaf4AAC2v2P"; //clientkey
//    AcceptSDKHandler *handler2 = [[AcceptSDKHandler alloc] initWithEnvironment:AcceptSDKEnvironmentENV_TEST];
//    AcceptSDKRequest *request2 = [[AcceptSDKRequest alloc] init];
//    request2.merchantAuthentication.name = @"9z2L9GRmczB"; //name
//    request2.merchantAuthentication.clientKey = @"8V7fkF7p7BUh4cZLA7f2PsRkVsgNd2Hru39Xq5xSnT9Z96ucgc8Fuhaf4AAC2v2P"; //clientkey
//
    
    
    request.securePaymentContainerRequest.webCheckOutDataType.token.cardNumber = info.cardNumber; //cardnumber
    request.securePaymentContainerRequest.webCheckOutDataType.token.expirationMonth = [NSString stringWithFormat:@"%tu", info.expiryMonth];
    request.securePaymentContainerRequest.webCheckOutDataType.token.expirationYear = [NSString stringWithFormat:@"%tu", info.expiryYear];
    request.securePaymentContainerRequest.webCheckOutDataType.token.cardCode = info.cvv;
    request2.securePaymentContainerRequest.webCheckOutDataType.token.cardNumber = info.cardNumber; //cardnumber
    request2.securePaymentContainerRequest.webCheckOutDataType.token.expirationMonth = [NSString stringWithFormat:@"%tu", info.expiryMonth];
    request2.securePaymentContainerRequest.webCheckOutDataType.token.expirationYear = [NSString stringWithFormat:@"%tu", info.expiryYear];
    request2.securePaymentContainerRequest.webCheckOutDataType.token.cardCode = info.cvv;
    
    [handler getTokenWithRequest:request successHandler:^(AcceptSDKTokenResponse * _Nonnull token) {
        [handler2 getTokenWithRequest:request2 successHandler:^(AcceptSDKTokenResponse * _Nonnull token2) {
            NSLog(@"success 1: %@", token.getOpaqueData.getDataValue);
            NSLog(@"success 2: %@", token2.getOpaqueData.getDataValue);
        [WebService makePaymentTransactionFor:self.passedPrice using:token.getOpaqueData.getDataValue and:token2.getOpaqueData.getDataValue or:@"" and:@"" passing:self.passedItems];
        } failureHandler:^(AcceptSDKErrorResponse * _Nonnull error) {
            NSLog(@"ACCEPT ERROR! %@", error.description);
            
            NSLog(@"ACCEPT ERROR! %@", error.getMessages.getMessages[0].getText);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showErrorWithStatus:@"Please try again."];
            }];
        }];
    } failureHandler:^(AcceptSDKErrorResponse * _Nonnull error) {
        NSLog(@"ACCEPT ERROR! %@", error.description);
        
        NSLog(@"ACCEPT ERROR! %@", error.getMessages.getMessages[0].getText);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
            [SVProgressHUD showErrorWithStatus:@"Please try again."];
        }];
              }];
    
    
    
    
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSNumber *)appVersionNumber {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSNumber *n =  [NSNumber numberWithDouble:[[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue]];
    
    return n;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    CGPoint p = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
    if (indexPath == nil){
        NSLog(@"couldn't find index path");
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Are you sure?"
                                                       message: @"You are about to remove this payment method from your account."
                                                      delegate: self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"OK",nil];
        
        [alert setTag:indexPath.row];
        [alert show];
        
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        if (buttonIndex == 1)
        {
            NSDictionary *dict = [myPayments objectAtIndex:alertView.tag];
            [WebService deletePaymentOptionFor:[dict valueForKey:@"CustomerID"] with:[dict valueForKey:@"CustomerPaymentID"]];
            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
                [SVProgressHUD showWithStatus:@"Deleting Payment Method."];
            }];
        }
}
- (IBAction)PayClicked:(id)sender {
    [WebService makePaymentTransactionFor:self.passedPrice using:@"" and:@"" or:[selected valueForKey:@"CustomerID"] and:[selected valueForKey:@"CustomerPaymentID"] passing:self.passedItems];
    [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
        [SVProgressHUD showWithStatus:@"Running Transaction."];
    }];
}
@end
