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
//    NSArray *models = [WDUser fetch:@{@"email":@"450620338@qq.com"} sortField:nil isAsc:YES];
    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSLog(@"%@",models);
    
    
//    WDUser *user2 = (WDUser *)[WDUser fetchOne:@{@"email":@"1sakdfj@efjkf.com"}];
//    user2.email = @"aaaaa.com";
//    user2.weight = @(55.5);
//    user2.parent = [NSKeyedArchiver archivedDataWithRootObject:@[@{@"father":@"A",@"age":@58},@{@"mother":@"B",@"age":@52}]];
//    [user2 update];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
