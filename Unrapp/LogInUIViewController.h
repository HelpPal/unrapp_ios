//
//  LogInUIViewController.h
//  Unrapp
//
//  Created by George R. Cain Jr. on 2/28/14.
//  Copyright (c) 2014 Unrapp All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LogInUIViewController : UIViewController <UITextFieldDelegate>
{
    NSString *firstName;
    NSString *lastName;
    NSString *email;
}
@property (weak, nonatomic) IBOutlet UITextField *usernameUITextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)logInButtonSelected:(id)sender;

@end
