//
//  WDBaseModel.m
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "WDBaseModel.h"
#import "WDDBService.h"
#import <objc/runtime.h>

NSString *const WDBaseFieldKey = @"field";
NSString *const WDBaseFieldProperty = @"prop";
NSString *const WDBaseFieldType = @"type";
NSString *const WDBaseFieldIsLazy = @"lazy";

@implementation WDBaseModel

+ (instancetype)modelFromJsonDict:(NSDictionary *)jsonKvDict{
    Class c = [self class];
    WDBaseModel *modle = [[c alloc] init];
    NSArray *fields = [modle fieldsForJson_];
    NSMutableDictionary *porpValueDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *field in fields) {
        if ([field valueForKey:WDBaseFieldIsLazy] && [[field valueForKey:WDBaseFieldIsLazy] boolValue] == YES) {
            continue;
        }
        NSObject *value = [jsonKvDict objectForKey:field[WDBaseFieldKey]];
        if (value) {
            [porpValueDict setObject:value forKey:field[WDBaseFieldProperty]];
        }
    }
    [modle assginToPropertyWithDictionary:porpValueDict];
    
    return modle;
}

- (NSDictionary *)jsonDict {
    NSMutableDictionary *jsonDict = [NSMutableDictionary dictionary];
    
    NSArray *fields = [self fieldsForJson_];
    for (NSDictionary *field in fields) {
        if ([field valueForKey:WDBaseFieldIsLazy] && [[field valueForKey:WDBaseFieldIsLazy] boolValue] == YES) {
            continue;
        }
        
        if ([self respondsToSelector:NSSelectorFromString([field valueForKey:WDBaseFieldProperty])]) {
            NSObject *value = [self performSelector:NSSelectorFromString([field valueForKey:WDBaseFieldProperty])];
            if (value && value != [NSNull null]) {
                [jsonDict setObject:value forKey:field[WDBaseFieldKey]];
            }
        }
    }
    
    return jsonDict;
}

- (NSString *)fieldNameByProp:(NSString *)propName{
    NSArray *fields = [self fieldsForJson_];
    for (NSDictionary *field in fields) {
        if ([propName isEqualToString:field[WDBaseFieldKey]]) {
            return field[WDBaseFieldProperty];
        }
    }
    return nil;
}

- (NSString *)propNameByField:(NSString *)fieldName{
    NSArray *fields = [self fieldsForJson_];
    for (NSDictionary *field in fields) {
        if ([fieldName isEqualToString:field[WDBaseFieldProperty]]) {
            return field[WDBaseFieldKey];
        }
    }
    return nil;
}

//这两个方法主要用于内部，返回的类型会是WDBaseModel，所以需要类型强制转换
+ (instancetype)fetchOne:(NSDictionary *)kvDict{
    return [[self fetch:kvDict sortField:nil isAsc:YES] firstObject];
}

+ (NSArray *)fetch:(NSDictionary *)kvDict sortField:(NSString *)sortField isAsc:(BOOL)isAsc{
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"SELECT * FROM %@ ",[[self alloc] tableName_]];
    if (kvDict) {
        [sql appendString:@" WHERE "];
        for (NSString *key in [kvDict allKeys]) {
            [sql appendFormat:@" %@=:%@ and",key,key];
        }
        [sql deleteCharactersInRange:NSMakeRange([sql length]-3, 3)];
    }
    if (sortField) {
        [sql appendFormat:@" ORDER BY %@ ",sortField];
        [sql appendString:isAsc?@"ASC":@"DESC"];
    }
    __weak WDBaseModel *weakSelf = (WDBaseModel *)self;
    return [WDDBService executeQuerySql:sql withArgs:kvDict propSetBlock:^NSObject *(NSDictionary *fieldValueDict){
        
        Class c = [weakSelf class];
        WDBaseModel *modle = [[c alloc] init];
        NSArray *fields = [modle fields_];
        NSMutableDictionary *porpValueDict = [[NSMutableDictionary alloc] init];
        for (NSDictionary *field in fields) {
            if ([field valueForKey:WDBaseFieldIsLazy] && [[field valueForKey:WDBaseFieldIsLazy] boolValue] == YES) {
                continue;
            }
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
    if (![self isUpdateValid]) {
        return nil;
    }
    NSMutableArray *fields = [[self fields_] mutableCopy];
    NSString *tableName = [self tableName_];
    
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
    NSString *idField = [self fieldForId_][WDBaseFieldKey];
    [sql appendFormat:@" WHERE %@=:%@ ",idField,idField];
    
    return sql;
}

- (NSDictionary *)dictionaryForKeyValue{
    if (![self isValid]) {
        return nil;
    }
    NSMutableArray *fields = [[self fields_] mutableCopy];
    
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
    NSMutableArray *fields = [[self fields_] mutableCopy];
    NSString *tableName = [self tableName_];
    
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

- (void)save{
    if (![self isValid]) {
        return;
    }
    NSString *sql = self.sqlForInsert;
    NSDictionary *keyValueDict = self.dictionaryForKeyValue;
    [WDDBService executeUpdateSql:sql withArgs:keyValueDict];//TODO 更新当前userId
}

- (void)update{//验证id不能为空
    if (![self isUpdateValid]) {
        return;
    }
    NSString *sql = self.sqlForUpdate;
    NSDictionary *keyValueDict = self.dictionaryForKeyValue;
    [WDDBService executeUpdateSql:sql withArgs:keyValueDict];
}

- (void)delete{
    NSString *idField = [self.fieldForId_ objectForKey:WDBaseFieldKey];
    NSString *selector = [self.fieldForId_ objectForKey:WDBaseFieldProperty];
    
    if (selector && [self respondsToSelector:NSSelectorFromString(selector)])
    {
        NSObject *value = [(NSObject *)self valueForKey:selector];
        if (value) {
            [[self class] delete:@{idField:value}];
        }
    }
}

+ (void)deleteAllData{
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"DELETE FROM %@ ",[[self alloc] tableName_]];
    [WDDBService executeUpdateSql:sql withArgs:nil];
}

+ (void)delete:(NSDictionary *)kvDict{
    NSMutableString *sql = [NSMutableString string];
    [sql appendFormat:@"DELETE FROM %@ ",[[self alloc] tableName_]];
    if (kvDict) {
        [sql appendString:@" WHERE "];
        for (NSString *key in [kvDict allKeys]) {
            NSObject *value = [kvDict objectForKey:key];
            if (value != nil && !([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])) {
                continue;
            }
            [sql appendFormat:@" %@=:%@,",key,key];
        }
    }
    [sql deleteCharactersInRange:NSMakeRange([sql length]-1, 1)];
    [WDDBService executeUpdateSql:sql withArgs:kvDict];
}

- (NSArray *)fields_{
    if ([self.class conformsToProtocol:@protocol(WDModel)] && [self.class respondsToSelector:@selector(fields)]) {
        return [self.class performSelector:@selector(fields)];
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    
    NSMutableArray *propArray = [NSMutableArray array];
    
    if (properties) {

        for (unsigned int i = 0; i < propertyCount; i++) {
            NSString *propName = [self getPropName:properties[i]];
            
            if (propName) [propArray addObject:@{@"field":propName,@"prop":propName}];
        }
        free(properties);
    }
    return propArray;
}

- (NSArray *)fieldsForJson_{
    if ([self.class conformsToProtocol:@protocol(WDModel)] && [self.class respondsToSelector:@selector(fieldsForJson)]) {
        return [self.class performSelector:@selector(fieldsForJson)];
    }
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    
    NSMutableArray *propArray = [NSMutableArray array];
    
    if (properties) {
        
        for (unsigned int i = 0; i < propertyCount; i++) {
            NSString *propName = [self getPropName:properties[i]];
            
            if (propName) [propArray addObject:@{@"field":propName,@"prop":propName}];
        }
        free(properties);
    }
    return propArray;
}

- (NSString *)getPropName:(objc_property_t)prop{
    NSString *propName = nil;
    const char *name = property_getName(prop);
    if (name) {
        propName = [NSString stringWithUTF8String:name];
    }
    return propName;
}

- (NSDictionary *)fieldForId_{
    if ([self.class conformsToProtocol:@protocol(WDModel)] && [self.class respondsToSelector:@selector(fieldForId)]) {
        return [self.class performSelector:@selector(fieldForId)];
    }
    return @{@"field":@"id",@"prop":@"id"};
}

+ (NSArray *)excludedFields_{
    if ([self.class conformsToProtocol:@protocol(WDModel)] && [self.class respondsToSelector:@selector(excludedFields)]) {
        return [self.class performSelector:@selector(excludedFields)];
    }
    return @[];
}
- (NSString *)tableName_{
    if ([self.class conformsToProtocol:@protocol(WDModel)] && [self.class respondsToSelector:@selector(tableName)]) {
        return [self.class performSelector:@selector(tableName)];
    }
    return [NSString stringWithUTF8String:object_getClassName(self.class)];;
}

#pragma mark - runtime

+(BOOL)resolveInstanceMethod:(SEL)sel{
    NSString *methodName = NSStringFromSelector(sel);
    if ([methodName hasPrefix:@"change"]) {
        class_addMethod([self class], sel, (IMP)ChangeFunction, "v@:");
        return YES;
    } else if ([methodName hasSuffix:@"Field"]) {
        class_addMethod([self class], sel, (IMP)ReadFeild, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

id ReadFeild(id self,SEL _cmd){
    if (![self isValid]) {
        return nil;
    }
    NSString *methodName = NSStringFromSelector(_cmd);
    methodName = [methodName substringToIndex:[methodName length]-5];
    NSArray *fields = [self fields_];
    for (NSDictionary *field in fields) {
        NSString *fieldName = field[WDBaseFieldKey];
        NSString *propName = field[WDBaseFieldProperty];
        NSString *idFieldName = [[self fieldForId_] objectForKey:WDBaseFieldKey];
        NSString *idPropName = [[self fieldForId_] objectForKey:WDBaseFieldProperty];
        if (propName && fieldName && [methodName isEqualToString:propName] &&
            [self respondsToSelector:NSSelectorFromString(propName)] ) {
            
            NSString *idValue = [(NSString *)self valueForKey:idPropName];
            NSDictionary *result = [WDDBService executeQuerySql:[NSString stringWithFormat:@"SELECT %@ FROM %@ where %@=:%@",fieldName,[self tableName_],idFieldName,idFieldName]
                                 withArgs:@{idFieldName:idValue}];
            if ([result.allKeys containsObject:fieldName] && [result objectForKey:fieldName] != [NSNull null]) {
                NSObject *oriData = [result objectForKey:fieldName];
                if ([oriData isKindOfClass:[NSData class]]) {
                    oriData = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)oriData];
                }
                return oriData;
            }
        }
    }
    return nil;
}

void ChangeFunction(id self,SEL _cmd){
    if (![self isUpdateValid]) {
        return;
    }
    
    NSString *methodName = NSStringFromSelector(_cmd);
    methodName = [methodName substringFromIndex:6];
    methodName = [self lowercaseFirstChar:methodName];
    NSArray *fields = [self fields_];
    for (NSDictionary *field in fields) {
        NSString *fieldName = field[WDBaseFieldKey];
        NSString *propName = field[WDBaseFieldProperty];
        NSString *idFieldName = [[self fieldForId_] objectForKey:WDBaseFieldKey];
        NSString *idPropName = [[self fieldForId_] objectForKey:WDBaseFieldProperty];
        if (propName && fieldName && [methodName isEqualToString:propName] &&
            [self respondsToSelector:NSSelectorFromString(propName)] ) {

            NSObject *value = [(NSObject *)self valueForKey:propName];
            NSString *idValue = [(NSString *)self valueForKey:idPropName];
            if (value != nil && value != [NSNull null] && idValue != nil) {//value为空的情况下，就不做插入
                [WDDBService executeUpdateSql:[NSString stringWithFormat:@"UPDATE %@ SET %@=:%@ where %@=:%@",[self tableName_],fieldName,fieldName,idFieldName,idFieldName]
                                     withArgs:@{fieldName:value,idFieldName:idValue}];
            }
            
        }
    }
    
}

#pragma mark - util

- (NSString *)lowercaseFirstChar:(NSString *)input{
    
    NSMutableString *result = [[NSMutableString alloc] init];
    [result appendString:[[input substringToIndex:1] lowercaseString]];
    [result appendString:[input substringFromIndex:1]];
    return result;
}

- (BOOL)isValid{
    if(![self conformsToProtocol:@protocol(WDModel)]){
        return NO;
    }
    return YES;
}

- (BOOL)isUpdateValid{
    if (![self isValid]) {
        return NO;
    }
    //暂时不用验证了
//    id<WDModel> model = (id<WDModel>)self;
//    
//    NSString *idPropName = [model fieldForId][WDBaseFieldProperty];
//    id fieldId = [self valueForKey:idPropName];
//    if (!fieldId || ![fieldId isKindOfClass:[NSString class]]) {
//        NSLog(@"@selector(fieldForId) 定义的id属性值不存在或者类型不为NSString");
//        return NO;
//    }
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
//            NSString  *value = [NSString stringWithFormat:@"%@", data[dicKey[i]]];
            
            ///2.3 把值通过setter方法赋值给实体类的属性
            [self performSelectorOnMainThread:setSel
                                   withObject:data[dicKey[i]]
                                waitUntilDone:[NSThread isMainThread]];
        }
    }
}

@end
