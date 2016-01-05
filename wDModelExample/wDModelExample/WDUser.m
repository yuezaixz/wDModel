//
//  WDUser.m
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/30.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "WDUser.h"

@implementation WDUser

+ (NSString *)tableName{
    return @"user";
}

//@property (nonatomic,strong) NSNumber *userId;
//@property (nonatomic, copy) NSString * name;
//@property (nonatomic, strong) NSNumber * sex;        //1：男 2：女
//@property (nonatomic, copy) NSString * email;
+ (NSArray *)fields{
    return @[@{@"field":@"user_id",@"prop":@"userId"},
             @{@"field":@"name",@"prop":@"name"},
             @{@"field":@"email",@"prop":@"email"},
             @{@"field":@"sex",@"prop":@"sex"},
             @{@"field":@"weight",@"prop":@"weight"},
             @{@"field":@"parent",@"prop":@"parent",@"lazy":@(YES)},];
}

+(NSArray *)fieldsForJson{
    return @[@{@"field":@"u_id",@"prop":@"userId"},
             @{@"field":@"name",@"prop":@"name"},
             @{@"field":@"email",@"prop":@"email"},
             @{@"field":@"sex",@"prop":@"sex"},
             @{@"field":@"weight",@"prop":@"weight"}];
}

+ (NSDictionary *)fieldForId{
    return @{@"field":@"user_id",@"prop":@"userId"};
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@:%@:%@:%@:%@",self.userId,self.name,self.email,self.sex,self.weight];
}

@end
