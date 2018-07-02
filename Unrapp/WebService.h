//
//  WebService.h
//  Unrapp
//
//  Created by Durish on 7/20/16.
//  Copyright © 2016 George R. Cain Jr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSUser.h"

@interface WebService : NSObject<NSURLSessionDelegate,NSURLSessionTaskDelegate>

+(void)initialize;

#pragma mark - User Data Management
+(void)check:(NSString*)Username  and:(NSString*)Password;
+(void)registerUser:(NSString*)Username  Password:(NSString*)Password Password2:(NSString*)PasswordConfirm FirstName:(NSString*)FirstName LastName:(NSString*)LastName Email:(NSString*)Email PhoneNumber:(NSString*)PhoneNumber;
+(void)changePassword:(NSString *)OldPassword withNewPassword:(NSString*)Password1 matchingPassword:(NSString*)Password2;
+(void)UploadUserImage:(NSString *)ImageURL;
+(void)blockUser:(int)ID;
+(void)refreshUser;
+(void)DeleteAccount;
+(void)ChangeAccountPrivacy:(bool)priv;
+(void)UpdateWSUser:(WSUser*)user;
+(void)ForgotPasswordFor:(NSString *)email;
+(void)ResetPasswordWithNewPassword:(NSString*)Password1 matchingPassword:(NSString*)Password2 usingKey:(NSString *)key;

#pragma mark - App Session
+(WSUser*) getLoggedInUser;
+(void) storeLoggedIn:(WSUser*)User;
+(void) logOutUser;

#pragma mark - Gift Management
+(void)getMessageCenterFor:(NSString *)Type and:(BOOL)NewOnly greaterThan:(int)IDNum;
+(void)getProfileGiftsFor:(int)ID;
+(void)ReportGift:(int)ID;
+(void)RemoveGiftFromProfile:(int)ID;
+(void)SendPictureGift:(NSString *)ImageURL toUser:(NSArray *)Array andShare:(bool)Share withVersion:(double)Version;
+(void)SendGiftCard:(int)giftCardID and:(int)giftBitID attachedTo:(NSString *)OrderID Worth:(double)value toUser:(NSArray *)Array andShare:(bool)Share withVersion:(double)Version;

+(void)InsertGiftResponse:(NSString *)responseURL toGift:(int)GiftID andMessage:(NSString *)Msg withVersion:(double)Version;
+(void)MarkViewedGift:(int)ID;
+(void)SpamGift:(int)ID;
+(void)DeleteGift:(int)GiftID forView:(NSString *)view;
+(void)MarkViewedReponse:(int)ID;

#pragma mark - Gift Cards
+(void)GetVendors;
+(void)GetGiftCardsForVendor:(int)ID;
+(void)GetOpenedGiftCards;
+(void)GetGiftCardOrders;
+(void)GetGiftCardOrderItemsfor:(int)ID;

#pragma mark - Redeem Code
+(void)CheckGiftCode:(NSString*)key;

#pragma Payment Portal
+(void)getPaymentOptions;
+(void)makePaymentTransactionFor:(double)amount using:(NSString*)nonce and:(NSString*)nonce2 or:(NSString*)CustomerID and:(NSString*)PaymentID passing: (NSArray*) items;

+(void)deletePaymentOptionFor:(NSString*)CustomerID with:(NSString*)PaymentID;

#pragma mark - Friend Management
+(void)getUserFriends;
+(void)getUserFriendsWithSearch:(NSString *)Term;
+(void)removeUserFriend:(int)ID;
+(void)addUserFriend:(int)ID;
+(void)searchUsers:(NSString*)Keyword;
+(void)searchUsersPhone:(NSArray*)PhoneNumbers;

#pragma mark - Help Center
+(void)getHelpCenter;

#pragma mark - File Uploads
+(void)UploadImage:(UIImage *)image withName:(NSString *)fileName;
+(void)UploadFile:(NSData *)file;
@end
