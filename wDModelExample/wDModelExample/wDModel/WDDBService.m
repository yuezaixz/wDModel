//
//  WDDBService.m
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "WDDBService.h"
#import "FMDatabase.h"

@interface WDDBService()

@end

@implementation WDDBService

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// 获取数据库路径
- (FMDatabase *)getDB{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:@"runmove.db"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:database_path];
    return db;
}

// 初始化
- (id)init{
    self = [super init];
    if(self){
        FMDatabase *db = [self getDB];
        
        //TODO INIT
        
        [db close];
    }
    return self;
}

- (void)upgrade{
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    NSInteger version = 0;
    if([udf objectForKey:@"sportdatabaseversion"]){
        version = [[udf objectForKey:@"sportdatabaseversion"] integerValue];
    }
    //TODO UPDATE    
//    if (version < 8) {
//        NSMutableArray *sqlArray = [NSMutableArray array];
//        NSString *recordSql = @"alter table running change column weight double";
//        
//        [sqlArray addObject:recordSql];
//        FMDatabase *db = [self getDB];
//        if([db open]){
//            [db beginTransaction];
//            for(NSString *sql in sqlArray){
//                [db executeUpdate:sql];
//            }
//            version = 8;
//            [db commit];
//            [db close];
//        }else{
//            [db close];
//        }
//    }
    
    
    [udf setObject:@(version) forKey:@"sportdatabaseversion"];
    [udf synchronize];
}

@end
