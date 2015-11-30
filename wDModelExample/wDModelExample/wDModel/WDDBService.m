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

+ (BOOL)executeUpdateSql:(NSString *)sql withArgs:(NSDictionary *)args{
    return [[self sharedInstance] executeUpdateSql:sql withArgs:args];
}

+ (BOOL)executeUpdateSqlArray:(NSArray *)sqlArray{
    return [[self sharedInstance] executeUpdateSqlArray:sqlArray];
}

+ (NSDictionary *)executeQuerySql:(NSString *)sql withArgs:(NSDictionary *)args{
    return [[self sharedInstance] executeQuerySql:sql withArgs:args];
}

- (BOOL)executeUpdateSqlArray:(NSArray *)sqlArray{
    FMDatabase *db = [self getDB];
    if([db open]){
        [db beginTransaction];
        for (NSDictionary *sqlDict in sqlArray) {
            if (![db executeUpdate:[sqlDict valueForKey:@"sql"] withParameterDictionary:[sqlDict valueForKey:@"args"]]) {
                //TODO 暂时不考虑批量出错的错误处理
                continue;
            }
        }
        [db commit];
        [db close];
    }else{
        [db close];
    }
    
    return YES;
}

- (BOOL)executeUpdateSql:(NSString *)sql withArgs:(NSDictionary *)args{
    BOOL result = YES;
    FMDatabase *db = [self getDB];
    if([db open]){
        [db beginTransaction];
        if (args) {
            result = [db executeUpdate:sql withParameterDictionary:args];
        } else {
            result = [db executeUpdate:sql];
        }
        [db commit];
        [db close];
    }else{
        [db close];
    }
    return result;
}

- (NSDictionary *)executeQuerySql:(NSString *)sql withArgs:(NSDictionary *)args{
    FMDatabase *db = [self getDB];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    if([db open]){
        FMResultSet *resultSet = nil;
        if (args) {
            resultSet = [db executeQuery:sql withParameterDictionary:args];
        } else {
            resultSet = [db executeQuery:sql];
        }
        while ([resultSet next]) {
            for (int i = 0; i < resultSet.columnCount ; i++) {
                [result setObject:[resultSet objectForColumnIndex:i] forKey:[resultSet columnNameForIndex:i]];
            }
        }
        
        [db close];
    }else{
        [db close];
    }
    return result;
}

@end
