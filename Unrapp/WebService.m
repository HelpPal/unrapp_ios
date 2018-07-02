//
//  WebService.m
//  Unrapp
//
//  Created by Durish on 7/20/16.
//  Copyright © 2016 George R. Cain Jr. All rights reserved.
//

#define HTTP_HOST "https://unrapp.com/admin/ws/UnrappWS.asmx"
#define UPLOAD_PATH "https://unrapp.com/admin/ws/FileUpload.ashx"

#import "WebService.h"

@implementation WebService

    static NSURLSessionConfiguration *config;
    static NSURLSession *session;
    static NSMutableDictionary *dictData;
    static NSMutableDictionary *rawData;
    static WSUser *CurrentUser;

+(void)initialize
{
    config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    dictData = [[NSMutableDictionary alloc] init];
    rawData = [[NSMutableDictionary alloc] init];
}

#pragma mark - App Session
+(WSUser*) getLoggedInUser
{
    if (CurrentUser.username == nil)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"UnrappUser_123"])
        {
            NSData *encodedObject = [defaults objectForKey:@"UnrappUser_123"];
            WSUser *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
            CurrentUser = object;
            return object;
        }
        else
            return nil;
    }
    else
        return CurrentUser;
}
+(void) storeLoggedIn:(WSUser*)User
{
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:User];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"UnrappUser_123"];
    [defaults synchronize];
    CurrentUser = User;
}
+(void) logOutUser
{
    CurrentUser = nil;
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:CurrentUser];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:@"UnrappUser_123"];
    [defaults synchronize];
}


#pragma mark - User Data Management
+(void)registerUser:(NSString*)Username  Password:(NSString*)Password Password2:(NSString*)PasswordConfirm FirstName:(NSString*)FirstName LastName:(NSString*)LastName Email:(NSString*)Email PhoneNumber:(NSString*)PhoneNumber
{
    NSString *url = [NSString stringWithFormat:@"%s/SignUp", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{Username:\"%@\",Password:\"%@\",VerifyPassword:\"%@\",FirstName:\"%@\",LastName:\"%@\",PhoneNumber:\"%@\",Email:\"%@\"}",
                             Username,
                             Password,
                             PasswordConfirm,
                             FirstName,
                             LastName,
                             PhoneNumber,
                             Email];
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"SignUp"];
    [postDataTask resume];
}

+(void)check:(NSString *)Username and:(NSString *)Password
{
    NSString *url = [NSString stringWithFormat:@"%s/CheckUserLogin", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{username:\"%@\",password:\"%@\"}",
                             Username,
                             Password];
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"CheckUserLogin"];
    [postDataTask resume];
    
}

+(void)changePassword:(NSString *)OldPassword withNewPassword:(NSString*)Password1 matchingPassword:(NSString*)Password2
{
    NSString *url = [NSString stringWithFormat:@"%s/ChangePassword", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,Password:\"%@\", PasswordNew1:\"%@\", PasswordNew2:\"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             OldPassword,
                             Password1,
                             Password2];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"ChangePassword"];
    [postDataTask resume];
    
}

+(void)UploadUserImage:(NSString *)ImageURL
{
    NSString *url = [NSString stringWithFormat:@"%s/UploadUserImage", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,ImageURL:\"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ImageURL];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"UploadUserImage"];
    [postDataTask resume];
}

+(void)blockUser:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/BlockUser", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,BlockedUserID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"BlockUser"];
    [postDataTask resume];
}

+(void)refreshUser
{
    NSString *url = [NSString stringWithFormat:@"%s/RefreshUserLogin", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"RefreshUserLogin"];
    [postDataTask resume];
}

+(void)DeleteAccount
{
    NSString *url = [NSString stringWithFormat:@"%s/DeleteAccount", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"DeleteAccount"];
    [postDataTask resume];
}
+(void)ChangeAccountPrivacy:(bool)priv
{
    NSString *url = [NSString stringWithFormat:@"%s/ChangeAccountPrivacy", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,Private:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             priv ? @"true" : @"false"];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"ChangeAccountPrivacy"];
    [postDataTask resume];
}
+(void)UpdateWSUser:(WSUser*)user
{
    NSString *url = [NSString stringWithFormat:@"%s/UpdateProfile", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,Email:\"%@\",PhoneNumber:\"%@\",PostalCode:\"%@\",FirstName:\"%@\",LastName:\"%@\",Location:\"%@\",Tagline:\"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             user.email,
                             user.phone,
                             user.zipcode,
                             user.firstName,
                             user.lastName,
                             user.location,
                             user.tagline];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"UpdateProfile"];
    [postDataTask resume];
}

+(void)ForgotPasswordFor:(NSString *)email
{
    NSString *url = [NSString stringWithFormat:@"%s/ForgotPassword", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{Email:\"%@\"}",
                             email];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"ForgotPassword"];
    [postDataTask resume];
}
+(void)ResetPasswordWithNewPassword:(NSString*)Password1 matchingPassword:(NSString*)Password2 usingKey:(NSString *)key
{
    NSString *url = [NSString stringWithFormat:@"%s/ResetPassword", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];;
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{Key:\"%@\",Password1:\"%@\",Password2:\"%@\"}",
                             key,
                             Password1,
                             Password2];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"ResetPassword"];
    [postDataTask resume];
}

#pragma mark - Gift Management
+(void)getMessageCenterFor:(NSString *)Type and:(BOOL)NewOnly greaterThan:(int)IDNum
{
    NSString *url = [NSString stringWithFormat:@"%s/getMessageCenterGifts", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,Type:\"%@\", onlyNew:%@, lastID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             Type,
                             NewOnly ? @"true" : @"false",
                             IDNum];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getMessageCenterGifts"];
    [postDataTask resume];
    
}
+(void)getProfileGiftsFor:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/GetProfileGifts", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,ProfileID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"GetProfileGifts"];
    [postDataTask resume];
}
+(void)ReportGift:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/ReportGift", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,GiftID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"ReportGift"];
    [postDataTask resume];
}
+(void)SpamGift:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/SpamGift", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,GiftID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"SpamGift"];
    [postDataTask resume];
}

+(void)RemoveGiftFromProfile:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/RemoveFromProfile", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,GiftID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"RemoveFromProfile"];
    [postDataTask resume];
}

+(void)SendPictureGift:(NSString *)ImageURL toUser:(NSArray *)Array andShare:(bool)Share withVersion:(double)Version
{
    NSString *url = [NSString stringWithFormat:@"%s/InsertPictureGift", HTTP_HOST];
    
    NSMutableString *mutableString = [[NSMutableString alloc ]init];
    for (int i = 0; i < [Array count]; i++)
    {
        if (i > 0)
            [mutableString appendString:@","];
        
        [mutableString appendFormat:@"%@", [[Array objectAtIndex:i] stringValue]];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:480.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,RecipientIDs:[%@],ProfileShare: %@, Version: %f, ImageURL: \"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             mutableString,
                             Share ? @"true" : @"false",
                             Version,
                             ImageURL];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"InsertPictureGift"];
    [postDataTask resume];
}

+(void)SendGiftCard:(int)giftCardID and:(int)giftBitID attachedTo:(NSString*)OrderID Worth:(double)value toUser:(NSArray *)Array andShare:(bool)Share withVersion:(double)Version
{
    NSString *url = [NSString stringWithFormat:@"%s/InsertGiftCardGift", HTTP_HOST];
    
    NSMutableString *mutableString = [[NSMutableString alloc ]init];
    for (int i = 0; i < [Array count]; i++)
    {
        if (i > 0)
            [mutableString appendString:@","];
        
        [mutableString appendFormat:@"%@", [[[Array objectAtIndex:i] objectForKey:@"userID" ] stringValue]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:480.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    //int GiftBitID, int GiftCardID, double GiftCardValue, int OrderID)
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,RecipientIDs:[%@],ProfileShare: %@, Version: %f, GiftBitID: %d, GiftCardID: %d, GiftCardValue: %f, OrderID: %@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             mutableString,
                             Share ? @"true" : @"false",
                             Version,
                             giftBitID,
                             giftCardID,
                             value,
                             OrderID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"InsertGiftCardGift"];
    [postDataTask resume];
}

+(void)InsertGiftResponse:(NSString *)responseURL toGift:(int)GiftID andMessage:(NSString *)Msg withVersion:(double)Version
{
    NSString *url = [NSString stringWithFormat:@"%s/InsertGiftResponse", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,GiftID:%d,Message: \"%@\", Version: %f, ResponseURL: \"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             GiftID,
                             Msg,
                             Version,
                             responseURL];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"InsertGiftResponse"];
    [postDataTask resume];
}

+(void)MarkViewedGift:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/MarkGiftViewed", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,GiftID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"MarkGiftViewed"];
    [postDataTask resume];
}

+(void)MarkViewedReponse:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/MarkResponseViewed", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,GiftID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"MarkResponseViewed"];
    [postDataTask resume];
}

+(void)DeleteGift:(int)GiftID forView:(NSString *)view
{
    NSString *url = [NSString stringWithFormat:@"%s/DeleteGift", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,GiftID:%d,View:\"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             GiftID,
                             view];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"DeleteGift"];
    [postDataTask resume];
}

#pragma mark - Gift Cards
+(void)GetVendors
{
    NSString *url = [NSString stringWithFormat:@"%s/getGiftCardVendors2017", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getGiftCardVendors"];
    [postDataTask resume];
}
+(void)GetGiftCardsForVendor:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/getGiftCards", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,VendorID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getGiftCards"];
    [postDataTask resume];
}

+(void)GetOpenedGiftCards
{
    NSString *url = [NSString stringWithFormat:@"%s/getOpenedGiftCards", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getOpenedGiftCards"];
    [postDataTask resume];
}


+(void)GetGiftCardOrders
{
    NSString *url = [NSString stringWithFormat:@"%s/getGiftCardOrders", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getGiftCardOrders"];
    [postDataTask resume];
}
+(void)GetGiftCardOrderItemsfor:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/getGiftCardOrderDetail", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,OrderID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getGiftCardOrderDetail"];
    [postDataTask resume];
}

#pragma mark - Redeem Code
+(void)CheckGiftCode:(NSString *)key
{
    NSString *url = [NSString stringWithFormat:@"%s/CheckRedeemKey", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,Key:\"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             key];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"CheckRedeemKey"];
    [postDataTask resume];
}

#pragma mark - Payment Portal
+(void)getPaymentOptions
{
    NSString *url = [NSString stringWithFormat:@"%s/getCustomerPaymentMethods", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getCustomerPaymentMethods"];
    [postDataTask resume];
}
+(void)makePaymentTransactionFor:(double)amount using:(NSString*)nonce and:(NSString*)nonce2 or:(NSString*)CustomerID and:(NSString*)PaymentID passing: (NSArray*) items
{
    NSString *url = [NSString stringWithFormat:@"%s/makePaymentTransaction", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *itemString = @"";
    
    for (NSDictionary *dict in items) {
        if (![itemString isEqualToString:@""])
            itemString = [itemString stringByAppendingString:@","];
        
        itemString = [itemString stringByAppendingFormat:@"{itemName:\"%@\",itemPrice:%@,GiftCardID:%@,GiftBitID:%@}",
                      [dict objectForKey:@"itemName"],
                      [dict objectForKey:@"itemPrice"],
                      [dict objectForKey:@"GiftCardID"],
                      [dict objectForKey:@"GiftBitID"]];
    }
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,paymentAmount:%f,paymentNonce:\"%@\",paymentNonce2:\"%@\",CustomerID:\"%@\",PaymentID:\"%@\",items:[%@]}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             amount,
                             nonce,
                             nonce2,
                             CustomerID,
                             PaymentID,
                             itemString];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"makePaymentTransaction"];
    [postDataTask resume];
}
//DeleteCustomerPaymentMethod
+(void)deletePaymentOptionFor:(NSString*)CustomerID with:(NSString*)PaymentID
{
    NSString *url = [NSString stringWithFormat:@"%s/DeleteCustomerPaymentMethod", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,CustomerPaymentID:%@,CustomerID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             PaymentID,
                             CustomerID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"DeleteCustomerPaymentMethod"];
    [postDataTask resume];
}

#pragma mark - Friend Management
+(void)getUserFriends
{
    NSString *url = [NSString stringWithFormat:@"%s/getUserFriends", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getUserFriends"];
    [postDataTask resume];
}

+(void)getUserFriendsWithSearch:(NSString *)Term
{
    NSString *url = [NSString stringWithFormat:@"%s/getUserFriendsSearch", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,Term:\"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             Term];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getUserFriendsSearch"];
    [postDataTask resume];
}

+(void)removeUserFriend:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/DeleteFriend", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,FriendID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"DeleteFriend"];
    [postDataTask resume];
}

+(void)addUserFriend:(int)ID
{
    NSString *url = [NSString stringWithFormat:@"%s/AddFriend", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,FriendID:%d}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             ID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"AddFriend"];
    [postDataTask resume];
}

+(void)searchUsers:(NSString*)Keyword
{
    NSString *url = [NSString stringWithFormat:@"%s/SearchUsers", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,Keyword:\"%@\"}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             Keyword];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"SearchUsers"];
    [postDataTask resume];
}

+(void)searchUsersPhone:(NSArray*)PhoneNumbers
{
    NSString *url = [NSString stringWithFormat:@"%s/SearchUsersPhone", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSMutableString *mutableString = [[NSMutableString alloc ]init];
    for (int i = 0; i < [PhoneNumbers count]; i++)
    {
        if (i > 0)
            [mutableString appendString:@","];
        
        [mutableString appendFormat:@"\"%@\"", @""];
    }
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@,PhoneNumbers:[%@]}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID,
                             mutableString];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"SearchUsersPhone"];
    [postDataTask resume];
}

#pragma mark - Help Center
+(void)getHelpCenter
{
    NSString *url = [NSString stringWithFormat:@"%s/getHelpCenterQuestions", HTTP_HOST];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:240.0];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    NSString *postDataStr = [NSString stringWithFormat:@"{UserAPIKey:\"%@\",userID:%@}",
                             [self getLoggedInUser].APIKey,
                             [self getLoggedInUser].userID];
    
    NSData *bodyData = [postDataStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:bodyData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"getHelpCenterQuestions"];
    [postDataTask resume];
}

#pragma File Uploads
+(void)UploadImage:(UIImage *)image withName:(NSString *)fileName
{
    //Fix Image Rotation!
    image = [self normalizeImage:image];
    
    // creating a NSMutableURLRequest that we can manipulate before sending
    NSURL *theURL = [NSURL URLWithString:@UPLOAD_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1200.0];
    
    // setting the HTTP method
    [request setHTTPMethod:@"POST"];
    
    // we want a JSON response
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // the boundary string.
    NSString *boundary = @"unrapp___unrapp!___unrapp";
    
    // setting the Content-type and the boundary
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    // we need a buffer of mutable data where we will write the body of the request
    NSMutableData *body = [NSMutableData data];
    
    // Append File Type
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"FileType"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"IMAGE"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // creating a NSData representation of the image
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    NSString *fileNameStr = [NSString stringWithFormat:@"%@.jpg", fileName];
    
    // if we have successfully obtained a NSData representation of the image
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"%@\"\r\n", fileNameStr] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
        NSLog(@"no image data!!!");
    
    
    // we close the body with one last boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // assigning the completed NSMutableData buffer as the body of the HTTP POST request
    [request setHTTPBody:body];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"ImageUpload"];
    [postDataTask resume];
}
+(void)UploadFile:(NSData *)file
{
    // creating a NSMutableURLRequest that we can manipulate before sending
    NSURL *theURL = [NSURL URLWithString:@UPLOAD_PATH];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:1200.0];
    
    // setting the HTTP method
    [request setHTTPMethod:@"POST"];
    
    // we want a JSON response
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // the boundary string.
    NSString *boundary = @"unrapp___unrapp!___unrapp";
    
    // setting the Content-type and the boundary
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"private, max-age=0" forHTTPHeaderField:@"Cache-Control"];
    
    // we need a buffer of mutable data where we will write the body of the request
    NSMutableData *body = [NSMutableData data];
    
    // Append File Type
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", @"FileType"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"%@\r\n", @"FILE"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *fileNameStr = [NSString stringWithFormat:@"%@.mp4", @"giftReaction"];
    
    // if we have successfully obtained a NSData representation of the image
    if (file) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"reaction\"; filename=\"%@\"\r\n", fileNameStr] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: video/mp4\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:file];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
        NSLog(@"no file data!!!");
    
    
    // we close the body with one last boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // assigning the completed NSMutableData buffer as the body of the HTTP POST request
    [request setHTTPBody:body];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request];
    [postDataTask setTaskDescription:@"FileUpload"];
    [postDataTask resume];

}


#pragma mark - URL Session Delegates
+(void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveData:(nonnull NSData *)data
{
    NSMutableData *responseData = rawData[@(dataTask.taskIdentifier)];
    if (!responseData) {
        responseData = [NSMutableData dataWithData:data];
        rawData[@(dataTask.taskIdentifier)] = responseData;
    } else {
        [responseData appendData:data];
    }
}

+(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error)
        NSLog(@"Session Error: %@", error);
    
    NSMutableData *responseData = rawData[@(task.taskIdentifier)];
    
    NSLog(@"Web Service Completed: %@", task.taskDescription);
    NSString *tmp = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", tmp);
    
    NSError *e;
    NSJSONSerialization *jData;
    
    if (!error)
    {
        
        jData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&e];
        if (e)
        {
            NSString *tmp = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSString *str = [NSString stringWithFormat:@"{\"Success\":false,\"Message\":\"%@\"}", e.localizedDescription];
            NSLog(@"Response Text: %@", tmp);
            
            NSData *errData = [str dataUsingEncoding:NSUTF8StringEncoding];
            jData = [NSJSONSerialization JSONObjectWithData:errData options:0 error:&e];
            NSLog(@"Json Error: %@", e);
        }
        
    }
    else
    {
        NSString *str = [NSString stringWithFormat:@"{\"Success\":false,\"Message\":\"%@\"}", error.localizedDescription];
        
        NSData *errData = [str dataUsingEncoding:NSUTF8StringEncoding];
        jData = [NSJSONSerialization JSONObjectWithData:errData options:0 error:&e];
        NSLog(@"Network Error: %@", e);

    }
    
    [rawData removeObjectForKey:@(task.taskIdentifier)];
    
    if (!jData)
    {
        [dictData removeObjectForKey:task.taskDescription];
    }
    else if ([jData valueForKey:@"d"] == nil)
    {
        [dictData setObject:jData forKey:task.taskDescription];
    }
    else
    {
        [dictData setObject:[jData valueForKey:@"d"] forKey:task.taskDescription];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:task.taskDescription object:self userInfo:dictData];
}

+ (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

+ (UIImage *)normalizeImage:(UIImage *)image {
    if (image.imageOrientation == UIImageOrientationUp) return image;
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:(CGRect){0, 0, image.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
