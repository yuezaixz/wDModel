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

//这两个方法主要用于内部，返回的类型会是WDBaseModel，所以需要类型强制转换
+ (instancetype)fetchOne:(NSDictionary *)kvDict{
    return [[self fetch:kvDict sortField:nil isAsc:YES] firstObject];
}

+ (NSArray *)fetch:(NSDictionary *)kvDict sortField:(NSString *)sortField isAsc:(BOOL)isAsc{
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"SELECT * FROM %@ ",[[self alloc] tableName]];
    if (kvDict) {
        [sql appendString:@" WHERE "];
        for (NSString *key in [kvDict allKeys]) {
            [sql appendFormat:@" %@=:%@,",key,key];
        }
    }
    [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
    if (sortField) {
        [sql appendFormat:@" ORDER BY %@ ",sortField];
        [sql appendString:isAsc?@"ASC":@"DESC"];
    }
    __weak WDBaseModel *weakSelf = (WDBaseModel *)self;
    return [WDDBService executeQuerySql:sql withArgs:kvDict propSetBlock:^NSObject *(NSDictionary *fieldValueDict){
        
        Class c = [weakSelf class];
        WDBaseModel *modle = [[c alloc] init];
        NSArray *fields = [modle fields];
        NSMutableDictionary *porpValueDict = [[NSMutableDictionary alloc] init];
        for (NSDictionary *field in fields) {
            NSObject *value = [fieldValueDict objectForKey:field[WDBaseFieldKey]];
            if (value) {
                [porpValueDict setObject:value forKey:field[WDBaseFieldProperty]];
            }
        }
        [modle assginToPropertyWithDictionary:porpValueDict];
        return modle;
    }];
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
                [sql appendString:@","];
            }
        }
    }
    [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
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
            if (value) {
                [keyValueDict setObject:value forKey:key];
            }

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
                [keySql appendFormat:@" %@ ,",key];
                [valueSql appendFormat:@" :%@ ,",key];
            }
        }
        
        if (i == 0) {
            [keySql deleteCharactersInRange:NSMakeRange([keySql length]-1, 1)];
            [valueSql deleteCharactersInRange:NSMakeRange([valueSql length]-1, 1)];
            [keySql appendString:@" ) "];
            [valueSql appendString:@" ) "];
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
    [WDDBService executeUpdateSql:sql withArgs:keyValueDict];//TODO 更新当前userId
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

// 通过字符串来创建该字符串的Setter方法，并返回
- (SEL) creatSetterWithPropertyName: (NSString *) propertyName{
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:[[propertyName substringToIndex:1] uppercaseString]];
    [result appendString:[propertyName substringFromIndex:1]];
    
    //2.拼接上set关键字
    propertyName = [NSString stringWithFormat:@"set%@:", result];
    
    //3.返回set方法
    return NSSelectorFromString(propertyName);
}

/************************************************************************
 *把字典赋值给当前实体类的属性
 *参数：字典
 *适用情况：当网络请求的数据的key与实体类的属性相同时可以通过此方法吧字典的Value
 *        赋值给实体类的属性
 ************************************************************************/

-(void)assginToPropertyWithDictionary: (NSDictionary *) data{
    
    if (data == nil) {
        return;
    }
    
    ///1.获取字典的key
    NSArray *dicKey = [data allKeys];
    
    ///2.循环遍历字典key, 并且动态生成实体类的setter方法，把字典的Value通过setter方法
    ///赋值给实体类的属性
    for (int i = 0; i < dicKey.count; i ++) {
        
        ///2.1 通过getSetterSelWithAttibuteName 方法来获取实体类的set方法
        SEL setSel = [self creatSetterWithPropertyName:dicKey[i]];
        
        if ([self respondsToSelector:setSel]) {
            ///2.2 获取字典中key对应的value
            NSString  *value = [NSString stringWithFormat:@"%@", data[dicKey[i]]];
            
            ///2.3 把值通过setter方法赋值给实体类的属性
            [self performSelectorOnMainThread:setSel
                                   withObject:value
                                waitUntilDone:[NSThread isMainThread]];
        }
    }
}

@end
