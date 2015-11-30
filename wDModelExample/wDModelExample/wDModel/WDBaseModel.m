//
//  WDBaseModel.m
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "WDBaseModel.h"
#import "WDDBService.h"

NSString *const WDBaseFieldKey = @"field";
NSString *const WDBaseFieldProperty = @"prop";
NSString *const WDBaseFieldType = @"type";
NSString *const WDBaseFieldIsLazy = @"lazy";

@implementation WDBaseModel


+ (WDBaseModel *)fetchOne:(NSDictionary *)kvDict{
    return [[self alloc] init];
}

+ (NSArray *)fetch:(NSDictionary *)kvDict sortField:(NSString *)sortField{
    return @[];
}

- (NSString *)sqlForUpdate{
    if (![self isValid]) {
        return nil;
    }
    NSMutableArray *fields = [[self fields] mutableCopy];
    NSString *tableName = [self tableName];
    
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"UPDATE %@ SET ",tableName];
    
    for (NSInteger i = [fields count] - 1; i >= 0; i--){
        NSDictionary *field = fields[i];
        NSString *key = field[WDBaseFieldKey];
        
        
        NSString *selector = field[WDBaseFieldProperty];
        if (selector && [self respondsToSelector:NSSelectorFromString(selector)])
        {
            NSObject *value = [(NSObject *)self valueForKey:selector];
            if (value != nil) {//value为空的情况下，就不做插入
                [sql appendFormat:@" %@=:%@ ",key,key];
                if (i != 0) {
                    [sql appendString:@", "];
                }
            }
        }
    }
    NSString *idField = [self fieldForId];
    [sql appendFormat:@" WHERE %@=:%@ ",idField,idField];
    
    return sql;
}

- (NSDictionary *)dictionaryForKeyValue{
    if (![self isValid]) {
        return nil;
    }
    NSMutableArray *fields = [[self fields] mutableCopy];
    
    NSMutableDictionary *keyValueDict = [[NSMutableDictionary alloc] init];
    
    for (NSInteger i = [fields count] - 1; i >= 0; i--){
        NSDictionary *field = fields[i];

        NSString *key = field[WDBaseFieldKey];
        
        
        NSString *selector = field[WDBaseFieldProperty];
        if (selector && [self respondsToSelector:NSSelectorFromString(selector)])
        {
            NSObject *value = [(NSObject *)self valueForKey:selector];
            [keyValueDict setObject:value forKey:key];
        }
        
    }
    
    return keyValueDict;
}

- (NSString *)sqlForInsert{
    if (![self isValid]) {
        return nil;
    }
    NSMutableArray *fields = [[self fields] mutableCopy];
    NSString *tableName = [self tableName];
    
    NSMutableString *keySql = [NSMutableString string];
    [keySql appendFormat:@"INSERT INTO %@ ( ",tableName];
    
    NSMutableString *valueSql = [NSMutableString string];
    [valueSql appendString:@" VALUES( "];
    
    for (NSInteger i = [fields count] - 1; i >= 0; i--){
        NSDictionary *field = fields[i];
        NSString *key = field[WDBaseFieldKey];
        
        
        NSString *selector = field[WDBaseFieldProperty];
        if (selector && [self respondsToSelector:NSSelectorFromString(selector)])
        {
            NSObject *value = [(NSObject *)self valueForKey:selector];
            if (value != nil) {//value为空的情况下，就不做插入
                [keySql appendFormat:@" %@ ",key];
                [valueSql appendFormat:@" :%@ ",key];
                if (i != 0) {
                    [keySql appendString:@" , "];
                    [valueSql appendString:@" , "];
                } else {
                    [keySql appendString:@" ) "];
                    [valueSql appendString:@" ) "];
                }
            }
        }
    }
    [keySql appendString:valueSql];
    return keySql;
}

- (NSArray *)fields{
    return nil;
}

- (NSString *)fieldForId{
    return nil;
}

+ (NSArray *)extraFields{
    return nil;
}
+ (NSArray *)excludedFields{
    return nil;
}
- (NSString *)tableName{
    return nil;
}

- (void)save{
    if (![self isValid]) {
        return;
    }
    NSString *sql = self.sqlForInsert;
    NSDictionary *keyValueDict = self.dictionaryForKeyValue;
    [WDDBService executeUpdateSql:sql withArgs:keyValueDict];
}

- (void)update{//验证id不能为空
    if (![self isValid]) {
        return;
    }
    NSString *sql = self.sqlForUpdate;
    NSDictionary *keyValueDict = self.dictionaryForKeyValue;
    [WDDBService executeUpdateSql:sql withArgs:keyValueDict];
}

#pragma mark - util
- (BOOL)isValid{
    if (![self fields]) {
        NSLog(@"子类请重载 @selector(fields)");
        return NO;
    }
    if (![self tableName]) {
        NSLog(@"子类请重载 @selector(tableName)");
        return NO;
    }
    if (![self fieldForId]) {
        NSLog(@"子类请重载 @selector(fieldForId)");
        return NO;
    }
    return YES;
}

@end
