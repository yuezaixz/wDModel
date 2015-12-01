//
//  WDDBService.m
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "WDDBService.h"
#import "FMDatabase.h"


//Notice. 该封装表的创建以及升级都需要在 init upgrade 中实现


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
        
        NSString *userSQL = @"create table if not exists user (user_id integer not null primary key autoincrement,";
        userSQL = [userSQL stringByAppendingString:@"name varchar(100),sex integer)"];
        if([db open]){
            [db executeUpdate:userSQL];
        }
        [db close];
        [self upgrade];
    }
    return self;
}
//数据模型升级
- (void)upgrade{
    NSUserDefaults *udf = [NSUserDefaults standardUserDefaults];
    NSInteger version = 0;//初始化版本号
    if([udf objectForKey:@"sportdatabaseversion"]){
        version = [[udf objectForKey:@"sportdatabaseversion"] integerValue];
    }
    if (version < 1) {//新的版本号
        NSMutableArray *sqlArray = [NSMutableArray array];
        NSString *userEmailAddSql = @"alter table user add column email varchar(100)";
        
        [sqlArray addObject:userEmailAddSql];
        FMDatabase *db = [self getDB];
        if([db open]){
            [db beginTransaction];
            for(NSString *sql in sqlArray){
                [db executeUpdate:sql];
            }
            version = 1;//新的版本号
            [db commit];
            [db close];
        }else{
            [db close];
        }
    }
    if (version < 2) {//新的版本号
        NSMutableArray *sqlArray = [NSMutableArray array];
        NSString *userWeightAddSql = @"alter table user add column weight double";
        NSString *userParentAddSql = @"alter table user add column parent blob";
        
        [sqlArray addObject:userWeightAddSql];
        [sqlArray addObject:userParentAddSql];
        FMDatabase *db = [self getDB];
        if([db open]){
            [db beginTransaction];
            for(NSString *sql in sqlArray){
                [db executeUpdate:sql];
            }
            version = 2;//新的版本号
            [db commit];
            [db close];
        }else{
            [db close];
        }
    }
    
    
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

+ (NSArray *)executeQuerySql:(NSString *)sql withArgs:(NSDictionary *)args propSetBlock:(NSObject* (^)(NSDictionary *))propSetBlock{
    return [[self sharedInstance] executeQuerySql:sql withArgs:args propSetBlock:propSetBlock];
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



- (NSArray *)executeQuerySql:(NSString *)sql withArgs:(NSDictionary *)args propSetBlock:(NSObject* (^)(NSDictionary *))propSetBlock{
    FMDatabase *db = [self getDB];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if([db open]){
        FMResultSet *resultSet = nil;
        if (args) {
            resultSet = [db executeQuery:sql withParameterDictionary:args];
        } else {
            resultSet = [db executeQuery:sql];
        }
        while ([resultSet next]) {
            [result addObject:propSetBlock([resultSet resultDictionary])];
        }
        
        [db close];
    }else{
        [db close];
    }
    return result;
}

@end
