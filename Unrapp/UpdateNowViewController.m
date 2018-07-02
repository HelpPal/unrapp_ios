//
//  UpdateNowViewController.m
//  Unrapp
//
//  Created by Robert Durish on 6/30/16.
//  Copyright © 2016 George R. Cain Jr. All rights reserved.
//

#import "UpdateNowViewController.h"

@interface UpdateNowViewController ()

@end

@implementation UpdateNowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(GoToAppStore) userInfo:nil repeats:NO];
}

-(void)GoToAppStore
{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://itunes.apple.com/us/app/unrapp/id955133442?mt=8"]];
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
