//
//  ViewController.m
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "ViewController.h"
#import "WDUser.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //SAVE
//    WDUser *user = [[WDUser alloc] init];
//    user.name = @"汤莹";
//    user.email = @"450620338@qq.com";
//    user.sex = @(UserSexFemale);
//    [user save];
    
    //fetch
//    NSArray *models = [WDUser fetch:@{@"email":@"xiao303178394@gmail.com"} sortField:nil isAsc:YES];
    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSLog(@"%@",models);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
