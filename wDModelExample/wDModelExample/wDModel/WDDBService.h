//
//  WDDBService.h
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/29.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDDBService : NSObject

+ (instancetype)sharedInstance;

+ (BOOL)executeUpdateSql:(NSString *)sql withArgs:(NSDictionary *)args;
+ (BOOL)executeUpdateSqlArray:(NSArray *)sqlArray;
+ (NSDictionary *)executeQuerySql:(NSString *)sql withArgs:(NSDictionary *)args;
+ (NSArray *)executeQuerySql:(NSString *)sql withArgs:(NSDictionary *)args propSetBlock:(NSObject* (^)(NSDictionary *))propSetBlock;

@end
