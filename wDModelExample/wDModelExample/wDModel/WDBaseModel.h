//
//  WDBaseModel.h
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDModel <NSObject>

@optional
/**
 *  返回在数据库中
 *
 *  @return 返回表名字符串,例如 @"user"
 */
+ (NSString *)tableName;
/**
 *  返回数据库中的field和prop对应的关系
 *
 *  @return 格式类似@[@{@"field":@"user_id",@"prop":@"userId"},@{@"field":@"parent",@"prop":@"parent"}]
 */
+ (NSArray *)fields;
/**
 *  返回Model中的字段，但是不需要持久化的属性<br>
 *  注意：该方法功能暂无实现
 *
 *  @return 属性名列表，注意是属性名不是数据库中的field名，格式例如：@[@"userId",@"parent"]
 */
+ (NSArray *)excludedFields;
/**
 *  ID字段
 *
 *  @return 格式类似 @{@"field":@"user_id",@"prop":@"userId"};
 */
+ (NSDictionary *)fieldForId;
/**
 *  返回json格式和prop对应的关系<br>
 *  注意：该方法功能暂无实现
 *
 *  @return 格式类似@[@{@"field":@"user_id",@"prop":@"userId"},@{@"field":@"parent",@"prop":@"parent"}]
 */
+ (NSArray *)fieldsForJson;

@end

@interface WDBaseModel : NSObject

+ (instancetype)fetchOne:(NSDictionary *)kvDict;

+ (instancetype)modelFromJsonDict:(NSDictionary *)jsonKvDict;

+ (NSArray *)fetch:(NSDictionary *)kvDict sortField:(NSString *)sortField isAsc:(BOOL)isAsc;

- (NSString *)sqlForUpdate;

- (NSString *)sqlForInsert;

- (NSDictionary *)dictionaryForKeyValue;

- (void)delete;

+ (void)deleteAllData;

+ (void)delete:(NSDictionary *)kvDict;

- (void)save;
- (void)update;

@end

@interface WDBaseField : NSObject

@property (nonatomic, readonly) NSString *property;
@property (nonatomic, readonly) NSString *field;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL isLazy;

@end