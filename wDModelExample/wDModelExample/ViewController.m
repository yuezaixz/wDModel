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
//    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
//    NSLog(@"%@",models);

    //动态改变属性
//    WDUser *user2 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
//    user2.weight = @67.9;
//    [user2 performSelector:@selector(changeWeight)];
    
//    WDUser *user3 = (WDUser *)[WDUser fetchOne:@{@"user_id":@2}];
//    NSLog(@"parent:%@",[user3 performSelector:@selector(parentField)]);
//    NSLog(@"weight:%@",[user3 performSelector:@selector(weightField)]);
    
//    user2.email = @"aaaaa.com";
//    user2.weight = @(55.5);
//    user2.parent = [NSKeyedArchiver archivedDataWithRootObject:@[@{@"father":@"A",@"age":@58},@{@"mother":@"B",@"age":@52}]];
//    [user2 update];
    
    //测试delete
//    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
//    NSInteger beforeDeleteCount = [models count];
//    
//    //删除方法1,有id值的对象可以这样去调用实例方法去删除
////    WDUser *user4 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
////    [user4 delete];
//    
//    //删除方法2，比较灵活
////    [WDUser delete:@{@"user_id":@(2)}];
//    
//    //删除方法3，清空表，使用需谨慎
////    [WDUser deleteAllData];
//    
//    models = [WDUser fetch:nil sortField:nil isAsc:YES];
//    NSInteger afterDeleteCount = [models count];
//    NSLog(@"删除数据数量：%ld",beforeDeleteCount-afterDeleteCount);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
