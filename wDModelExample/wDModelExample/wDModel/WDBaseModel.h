//
//  WDBaseModel.h
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDBaseModel : NSObject

+ (WDBaseModel *)fetchOne:(NSDictionary *)kvDict;

+ (NSArray *)fetch:(NSDictionary *)kvDict sortField:(NSString *)sortField;

- (NSString *)sqlForUpdate;

- (NSString *)sqlForInsert;

- (NSDictionary *)dictionaryForKeyValue;

- (NSString *)tableName;
- (NSArray *)fields;
- (NSString *)fieldForId;
+ (NSArray *)extraFields;
+ (NSArray *)excludedFields;

- (void)save;
- (void)update;

@end

@interface WDBaseField : NSObject

@property (nonatomic, readonly) NSString *property;
@property (nonatomic, readonly) NSString *field;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL isLazy;

@end