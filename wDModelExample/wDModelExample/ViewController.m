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
    
    [WDUser deleteAllData];
    [self testCreate];
    [self testFetchOneAndUpdate];
    [self testFetchAll];
    [self testDelete];
    [self testJson];
}

- (void)testCreate{
    {
        WDUser *user2 = [[WDUser alloc] init];
        user2.name = @"汤爸爸";
        user2.email = @"baba@qq.com";
        user2.sex = @(UserSexMale);
        [user2 save];
        WDUser *user3 = [[WDUser alloc] init];
        user3.name = @"汤妈妈";
        user3.email = @"mama@qq.com";
        user3.sex = @(UserSexFemale);
        [user3 save];
        WDUser *user = [[WDUser alloc] init];
        user.name = @"汤莹";
        user.email = @"450620338@qq.com";
        user.sex = @(UserSexFemale);
        user.parent = @[user2.jsonDict,user3.jsonDict];
        user.father = user2.jsonDict;
        [user save];
    }
    {
        WDUser *user = [[WDUser alloc] init];
        user.name = @"吴迪玮";
        user.email = @"xiao303178394@gmail.com";
        user.sex = @(UserSexMale);
        [user save];
    }
}

- (void)testFetchOneAndUpdate{
    WDUser *user = [WDUser fetchOne:@{@"name":@"汤莹"}];
    NSAssert(user != nil ,@"create测试失败");
    NSAssert([user.email isEqualToString:@"450620338@qq.com"], @"fetchOne测试失败");
    NSLog(@"createTime:%@,%@",user.createTime,user);
    NSArray *parents = [user performSelector:@selector(parentField)];
    NSAssert([parents count] == 2, @"lazy及xxxField，setProp 读取 Array测试失败");
    NSLog(@"parent:%@",parents);
    NSAssert([[user.father objectForKey:@"email"] isEqualToString:@"baba@qq.com"], @"setProp 读取 Dictionary测试失败");
    NSLog(@"father:%@",user.father);
    
    user.email = @"xxxx@xx.com";
    [user update];
    
    WDUser *user3 = [WDUser fetchOne:@{@"email":@"xxxx@xx.com"}];
    NSAssert(user3 != nil ,@"update测试失败");
    
    user3.weight = @94.0;
    [user3 performSelector:@selector(changeWeight)];
    user3 = [WDUser fetchOne:@{@"weight":@94.0}];
    NSAssert(user3.weight.doubleValue == 94.0 ,@"changeXxx 测试失败");
}

- (void)testFetchAll{
    NSAssert([[WDUser fetch:nil sortField:nil isAsc:NO] count] == 4, @"fetch all 测试 失败");
    NSAssert([[WDUser fetch:@{@"sex":@(UserSexMale)} sortField:nil isAsc:NO] count] == 2, @"fetch all 带条件 测试 失败");
    NSAssert([[WDUser fetch:@{@"weight>":@90} sortField:nil isAsc:NO] count] == 1, @"fetch all 带表达式条件 测试 失败");
}

- (void)testDelete {
    //测试delete
    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSInteger beforeDeleteCount = [models count];
    
        //删除方法1,有id值的对象可以这样去调用实例方法去删除
    WDUser *user = (WDUser *)[WDUser fetchOne:@{@"weight>":@90}];
    [user delete];
    
    models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSInteger currentCount = [models count];
    NSAssert(beforeDeleteCount-currentCount == 1, @"测试 delete实例方法 失败");
    beforeDeleteCount = currentCount;
    //删除方法2，比较灵活
    [WDUser delete:@{@"sex":@(UserSexFemale)}];
    
    
    models = [WDUser fetch:nil sortField:nil isAsc:YES];
    currentCount = [models count];
    NSAssert(beforeDeleteCount-currentCount == 1, @"测试 delete类方法 失败");
    beforeDeleteCount = currentCount;
    
    

    //删除方法3，清空表，使用需谨慎
    [WDUser deleteAllData];

    models = [WDUser fetch:nil sortField:nil isAsc:YES];
    currentCount = [models count];
    NSAssert(beforeDeleteCount-currentCount == 2, @"测试 deleteAllData类方法 失败");
}

- (void)testJson {
    
    WDUser *user5 = [WDUser modelFromJsonDict:@{@"u_id":@(23),
                                                @"name":@"David_Wooo",
                                                @"email":@"david@paodong.cn",
                                                @"sex":@(UserSexMale),
                                                @"weight":@65.9}];
    [user5 save];

    WDUser *user6 = [WDUser fetchOne:@{@"user_id":@23}];
    NSAssert([user6.name isEqualToString:@"David_Wooo"], @"测试json和反json成功");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
