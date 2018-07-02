//
//  WSUser.m
//  Unrapp
//
//  Created by Durish on 7/20/16.
//  Copyright © 2016 George R. Cain Jr. All rights reserved.
//

#import "WSUser.h"


@implementation WSUser
@synthesize userID;
@synthesize username;
@synthesize userImage;
@synthesize firstName;
@synthesize lastName;
@synthesize location;
@synthesize email;
@synthesize tagline;
@synthesize zipcode;
@synthesize phone;
@synthesize APIKey;
@synthesize disabled;
@synthesize followers;
@synthesize following;

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.userImage forKey:@"userImage"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.tagline forKey:@"tagline"];
    [encoder encodeObject:self.zipcode forKey:@"zipcode"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.APIKey forKey:@"APIKey"];
    [encoder encodeObject:[NSNumber numberWithBool:self.disabled] forKey:@"disabled"];
    [encoder encodeObject:self.following forKey:@"following"];
    [encoder encodeObject:self.followers forKey:@"followers"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        NSLog(@"%@", [decoder decodeObjectForKey:@"userID"]);
        
        self.userID = [decoder decodeObjectForKey:@"userID"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.userImage = [decoder decodeObjectForKey:@"userImage"];
        self.firstName = [decoder decodeObjectForKey:@"firstName"];
        self.lastName = [decoder decodeObjectForKey:@"lastName"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.tagline = [decoder decodeObjectForKey:@"tagline"];
        self.zipcode = [decoder decodeObjectForKey:@"zipcode"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.APIKey = [decoder decodeObjectForKey:@"APIKey"];
        self.disabled = [[decoder decodeObjectForKey:@"disabled"] boolValue];
        self.following = [decoder decodeObjectForKey:@"following"];
        self.followers = [decoder decodeObjectForKey:@"followers"];
    }
    return self;
}
@end

