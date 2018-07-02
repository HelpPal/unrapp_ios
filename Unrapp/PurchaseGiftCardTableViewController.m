//
//  PurchaseGiftCardTableViewController.m
//  Unrapp
//
//  Created by Durish on 4/27/17.
//  Copyright © 2017 George R. Cain Jr. All rights reserved.
//

#import "PurchaseGiftCardTableViewController.h"
#import "GiftReceipents.h"
#import "CheckoutBodyTableViewCell.h"
#import "CheckoutHeaderTableViewCell.h"
//#import "WebService.h"
#import "SVProgressHUD.h"
#import "PaymentsCollectionViewController.h"

@interface PurchaseGiftCardTableViewController ()

@end
NSDictionary *data;
NSMutableArray *people;
NSString *each;
NSString *fee;
@implementation PurchaseGiftCardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.backBarButtonItem setTintColor:[UIColor whiteColor]];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    GiftReceipents* gift = [GiftReceipents getInstance];
    data = [gift getGiftCardToView];
    people = [gift getSelectedGiftReceipents];
    each = [gift getGiftValue];
    fee = [gift getGiftCardFee];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)purchaseClicked:(id)sender {
    NSString * storyboardName = @"iPhone";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
    PaymentsCollectionViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"PaymentCollectionViewController"];
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    //vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    //vc.view.frame = CGRectMake(0, ([[UIScreen mainScreen] bounds].size.height / 3) * 2, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height / 3);
    //[self performSegueWithIdentifier:@"payNow" sender:self];
    //return;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    v.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    
    
    // Make Array
    double total =  [[each substringFromIndex:1] doubleValue];
    //total = (total * (int)people.count) + ([fee doubleValue] * people.count);
    
    NSMutableArray *array = [[NSMutableArray alloc] init];


    int pertotal =  [[each substringFromIndex:1] intValue];
    for (NSDictionary *item in people) {
        NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
        [tmp setObject: [NSString stringWithFormat:@"%@ - %@", [item objectForKey:@"username"], [data objectForKey:@"name"] ] forKey:@"itemName"];
        [tmp setObject:[NSString stringWithFormat:@"%d", pertotal] forKey:@"itemPrice"];
        [tmp setObject:[data objectForKey:@"id"] forKey:@"GiftCardID"];
        [tmp setObject:[data objectForKey:@"gbid"] forKey:@"GiftBitID"];

        [array addObject:tmp];
    }

    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
    [tmp setObject: @"Unrapp Fee (FEE WAIVED)" forKey:@"itemName"];
    [tmp setObject:[NSString stringWithFormat:@"%f", ([@"0" doubleValue] * people.count)] forKey:@"itemPrice"];
    [tmp setObject:@"0" forKey:@"GiftCardID"];
    [tmp setObject:@"0" forKey:@"GiftBitID"];

    [array addObject:tmp];
    
    vc.passedItems = array;
    vc.passedPrice = total;
    vc.passedData = data;
    vc.passedEach = each;
    vc.passedPeople = people;
    
    [self.navigationController pushViewController:vc animated:YES];
    return;
    
    [self addChildViewController:vc];
    [v addSubview:vc.view];
    [self.view addSubview:v];
    [vc didMoveToParentViewController:self];
}

-(void) viewDidAppear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(wsNotification:)
//                                                name:@"getPaymentClientToken"
//                                              object:nil];
//
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                        selector:@selector(wsNotificationPurchase:)
//                                                name:@"makePaymentTransaction"
//                                              object:nil];
//
//    [[NSNotificationCenter defaultCenter]addObserver:self
//                                            selector:@selector(wsNotificationSendGift:)
//                                                name:@"InsertGiftCardGift"
//                                              object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"getPaymentClientToken"
//                                                  object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"makePaymentTransaction"
//                                                  object:nil];
//
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:@"InsertGiftCardGift"
//                                                  object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else
        return people.count + 1;
}

-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    // Configure the cell...
    if (indexPath.section == 0)
    {
        CheckoutHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
        double total =  [[each substringFromIndex:1] doubleValue];
        total = (total * (int)people.count); // + ([fee doubleValue] * people.count);
        cell.lblTotal.text = [NSString stringWithFormat:@"Total: $%.02f", total];
        return cell;
    }
    else
    {
        CheckoutBodyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BodyCell" forIndexPath:indexPath];
        
        if (indexPath.row < people.count)
        {
        int total =  [[each substringFromIndex:1] intValue];
        NSDictionary *tmp = [people objectAtIndex:indexPath.row];
        cell.lblWhat.text = [NSString stringWithFormat:@"%@ - %@", [tmp objectForKey:@"username"], [data objectForKey:@"name"]];
        cell.lblPrice.text = [NSString stringWithFormat:@"$%d.00", total];
        }
        else
        {
            cell.lblWhat.text = [NSString stringWithFormat:@"Unrapp Fee ($%@) X %lu (FEE WAIVED)",fee,(unsigned long)people.count ];
            cell.lblPrice.text = [NSString stringWithFormat:@"$%.02f",[@"0" doubleValue] * people.count];
        }
        return cell;
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


- (void)showDropIn:(NSString *)clientTokenOrTokenizationKey {
    
    
    
    
//    BTDropInRequest *request = [[BTDropInRequest alloc] init];
//    BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {
//
//        if (error != nil) {
//            NSLog(@"ERROR");
//            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
//        } else if (result.cancelled) {
//            NSLog(@"CANCELLED");
//        } else {
//            // Use the BTDropInResult properties to update your UI
//            // result.paymentOptionType
//            // result.paymentMethod
//            // result.paymentIcon
//            // result.paymentDescription
//            double total =  [[each substringFromIndex:1] doubleValue];
//            total = (total * (int)people.count) + ([fee doubleValue] * people.count);
//
//            NSMutableArray *array = [[NSMutableArray alloc] init];
//
//
//            int pertotal =  [[each substringFromIndex:1] intValue];
//            for (NSDictionary *item in people) {
//                NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
//                [tmp setObject: [NSString stringWithFormat:@"%@ - %@", [item objectForKey:@"username"], [data objectForKey:@"name"] ] forKey:@"itemName"];
//                [tmp setObject:[NSString stringWithFormat:@"%d", pertotal] forKey:@"itemPrice"];
//                [tmp setObject:[data objectForKey:@"id"] forKey:@"GiftCardID"];
//                [tmp setObject:[data objectForKey:@"gbid"] forKey:@"GiftBitID"];
//
//                [array addObject:tmp];
//            }
//
//            NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
//            [tmp setObject: @"Unrapp Fee (FEE WAIVED)" forKey:@"itemName"];
//            [tmp setObject:[NSString stringWithFormat:@"%f", ([@"0" doubleValue] * people.count)] forKey:@"itemPrice"];
//            [tmp setObject:@"0" forKey:@"GiftCardID"];
//            [tmp setObject:@"0" forKey:@"GiftBitID"];
//
//            [array addObject:tmp];
//
//            [WebService makePaymentTransactionFor:total using:result.paymentMethod.nonce passing:array];
//        }
//        [controller dismissViewControllerAnimated:YES completion:nil];
//    }];
//    [self presentViewController:dropIn animated:YES completion:nil];
}

#pragma mark - WebService Return
//-(void)wsNotification:(NSNotification *)notification
//{
//    NSDictionary *dict = [[notification userInfo]objectForKey:@"getPaymentClientToken"];
//    if (!dict)
//    {
//        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//            // Network Error
//            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
//        }];
//    }
//    else
//    {
//        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
//        if ([isSuccessNumber boolValue] == YES)
//        {
//            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//                [self showDropIn:[dict objectForKey:@"Token"]];
//            }];
//        }
//        else
//        {
//            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
//            }];
//        }
//    }
//
//}
//-(void)wsNotificationPurchase:(NSNotification *)notification
//{
//    NSDictionary *dict = [[notification userInfo]objectForKey:@"makePaymentTransaction"];
//    if (!dict)
//    {
//        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//            // Network Error
//            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
//        }];
//    }
//    else
//    {
//        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
//        if ([isSuccessNumber boolValue] == YES)
//        {
//            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//                // Need to send gift next???
//                [SVProgressHUD showWithStatus:@"Purchase successful sending your gifts!"];
//
//                //[WebService SendGiftCard:[[data objectForKey:@"id"] intValue] and:[[data objectForKey:@"gbid"] intValue] attachedTo:[dict objectForKey: @"orderID"] Worth:[[each substringFromIndex:1] doubleValue] toUser:people andShare:YES withVersion:[[self appVersionNumber] doubleValue]];
//
//                [WebService SendGiftCard:[[data objectForKey:@"id"] intValue] and:[[data objectForKey:@"gbid"] intValue] attachedTo:[NSString stringWithFormat:@"%@",[dict objectForKey:@"orderID"]] Worth:[[each substringFromIndex:1] doubleValue] toUser:people andShare:NO withVersion:[[self appVersionNumber] doubleValue]];
//            }];
//        }
//        else
//        {
//            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
//            }];
//        }
//    }
//
//}
//
//-(void)wsNotificationSendGift:(NSNotification *)notification
//{
//    NSDictionary *dict = [[notification userInfo]objectForKey:@"InsertGiftCardGift"];
//    if (!dict)
//    {
//        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//            // Network Error
//            [SVProgressHUD showErrorWithStatus:@"We can not reach our servers, check your internet or try again later."];
//        }];
//    }
//    else
//    {
//        NSNumber * isSuccessNumber = (NSNumber *)[dict objectForKey: @"Success"];
//        if ([isSuccessNumber boolValue] == YES)
//        {
//            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//                GiftReceipents* selectedGiftImage = [GiftReceipents getInstance];
//                [selectedGiftImage setGiftImage:nil];
//                [selectedGiftImage setGiftValue:@""];
//                [selectedGiftImage setIsGiftCard:nil];
//                [selectedGiftImage setSelectedGiftCard:nil];
//                [selectedGiftImage setSelectedGiftReceipents:nil];
//                [self.navigationController popToRootViewControllerAnimated:YES];
//                [SVProgressHUD showSuccessWithStatus:[dict objectForKey:@"Message"]];
//            }];
//        }
//        else
//        {
//            [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//                [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"Message"]];
//            }];
//        }
//    }
//
//}

- (NSNumber *)appVersionNumber {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    
    NSNumber *n =  [NSNumber numberWithDouble:[[infoDict objectForKey:@"CFBundleShortVersionString"] doubleValue]];
    
    return n;
}

@end
