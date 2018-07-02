//
//  WSUser.h
//  Unrapp
//
//  Created by Durish on 7/20/16.
//  Copyright © 2016 George R. Cain Jr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSUser : NSObject<NSCoding>
{
    NSString *userID;
    NSString *username;
    NSString *userImage;
    NSString *firstName;
    NSString *lastName;
    NSString *location;
    NSString *email;
    NSString *tagline;
    NSString *zipcode;
    NSString *phone;
    NSString *APIKey;
    BOOL disabled;
    NSNumber *following;
    NSNumber *followers;
}

@property  (nonatomic, retain)NSString *userID;
@property  (nonatomic, retain)NSString *username;
@property  (nonatomic, retain)NSString *userImage;
@property  (nonatomic, retain)NSString *firstName;
@property  (nonatomic, retain)NSString *lastName;
@property  (nonatomic, retain)NSString *location;
@property  (nonatomic, retain)NSString *email;
@property  (nonatomic, retain)NSString *tagline;
@property  (nonatomic, retain)NSString *zipcode;
@property  (nonatomic, retain)NSString *phone;
@property  (nonatomic, retain)NSString *APIKey;
@property  (nonatomic, assign)BOOL disabled;
@property (nonatomic, retain)NSNumber *following;
@property (nonatomic, retain)NSNumber *followers;

@end
