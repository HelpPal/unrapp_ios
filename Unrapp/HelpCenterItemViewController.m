//
//  HelpCenterItemViewController.m
//  Unrapp
//
//  Created by Robert Durish on 6/7/15.
//  Copyright (c) 2015 George R. Cain Jr. All rights reserved.
//

#import "HelpCenterItemViewController.h"

@interface HelpCenterItemViewController ()

@end

@implementation HelpCenterItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 60)];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newLogo.png"]];
    iv.center = navView.center;
    iv.bounds = CGRectMake(0, 6, 160, 32);
    iv.contentMode = UIViewContentModeScaleAspectFit;
    [navView addSubview:iv];
    
    self.navigationItem.titleView = navView;
    
    // Do any additional setup after loading the view.
    [self.videoPlayer loadWithVideoId:self.myData[@"VideoKey"]];
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

@end
