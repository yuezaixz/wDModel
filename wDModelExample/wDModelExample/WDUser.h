//
//  WDUser.h
//  wDModelExample
//
//  Created by 吴迪玮 on 15/11/30.
//  Copyright © 2015年 Paodong. All rights reserved.
//

#import "WDBaseModel.h"

typedef NS_ENUM(NSInteger, UserSex) {
    UserSexMale,
    UserSexFemale,
    UserSexUnknow
};

@interface WDUser : WDBaseModel

@property (nonatomic,strong) NSNumber *userId;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, strong) NSNumber * sex;        //1：男 2：女
@property (nonatomic, copy) NSString * email;
@property (nonatomic,strong) NSNumber *weight;
@property (nonatomic,strong) NSData *parent;

@end
