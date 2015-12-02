# wDModel
##介绍
###封装
这是一个对FMDB进行封装的sqlite ORM库，为了和当前应用场景完美替换，对于数据表的CREATE和MIGRATION不进行封装，需要用户用SQL进行『填空』。
###功能

* 通用SAVE方法
* 通用UPDATE方法
* 通用FETCH方法
* 通用FETCH_ONE方法
* lazy延时加载功能
* changeXxx方法，可以单独保存某个属性的值
* xxxField方法可以单独读取某个属性的值，可以用于读取设置了lazy的属性或者解析NSData类型属性

###不做的事情
对于数据表的CREATE和MIGRATION不进行封装，需要用户用SQL进行『填空』

##代码示例
###初始化
在项目初始化的位置，对Service进行单例初始化操作。

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WDDBService sharedInstance];
    return YES;
}
```
###表初始化
在WDDBService中对init和upgrade方法进行填空，填空如下。

```objc
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
    
    
    [udf setObject:@(version) forKey:@"sportdatabaseversion"];
    [udf synchronize];
}
```

###Model类创建
创建自己的Model类，继承自WDBaseModel，必须实现 @selector(tableName)、@selector(fields)、@selector(fieldForId)方法，具体如下。

```objc
@implementation WDUser

- (NSString *)tableName{
    return @"user";
}

//@property (nonatomic,strong) NSNumber *userId;
//@property (nonatomic, copy) NSString * name;
//@property (nonatomic, strong) NSNumber * sex;        //1：男 2：女
//@property (nonatomic, copy) NSString * email;
- (NSArray *)fields{
    return @[@{@"field":@"user_id",@"prop":@"userId"},
             @{@"field":@"name",@"prop":@"name"},
             @{@"field":@"email",@"prop":@"email"},
             @{@"field":@"sex",@"prop":@"sex"},];
}

- (NSDictionary *)fieldForId{
    return @{@"field":@"user_id",@"prop":@"userId"};
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@:%@:%@:%@",self.userId,self.name,self.email,self.sex];
}

@end
```

###Model类操作
然后save、update、fetch调用就好了。

```objc
//SAVE
WDUser *user = [[WDUser alloc] init];
    user.name = @"汤莹";
    user.email = @"450620338@qq.com";
    user.sex = @(UserSexFemale);
    [user save];
    
    //fetch
//    NSArray *models = [WDUser fetch:@{@"email":@"xiao303178394@gmail.com"} sortField:nil isAsc:YES];
    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSLog(@"%@",models);
    
    //update
    WDUser *user2 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
    user2.email = @"aaaaa.com";
    user2.weight = @(55.5);
    user2.parent = [NSKeyedArchiver archivedDataWithRootObject:@[@{@"father":@"A",@"age":@58},@{@"mother":@"B",@"age":@52}]];
    [user2 update];
    
      //动态改变属性
//    WDUser *user2 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
//    user2.weight = @67.9;
//    [user2 performSelector:@selector(changeWeight)];
    
    //动态读取属性，如果属性是NSData会解析
    WDUser *user3 = (WDUser *)[WDUser fetchOne:@{@"user_id":@2}];
    NSLog(@"parent:%@",[user3 performSelector:@selector(parentField)]);
    NSLog(@"weight:%@",[user3 performSelector:@selector(weightField)]);
```

##TODO LIST

* 所有的验证用AOP实现
* 减少配置：所有属性是否都默认入库，没有出现在fields中的是否默认为field与prop名相同？这样得启用excludeFields方法。
* 减少配置：没有表名默认为类名首字母小写
* 减少配置：没有idField默认叫id？
* 性能：待测试
* 类型转换: 对象类型可以自动转换
* 类型安全: 转换过程中，所有的数据类型都会被检测一遍，以保证类型安全，避免崩溃问题
* runtime 方法是否可以不用[user performSelector:@selector(parentField)]方式调用
* 已经fetch后的数据，其他地方对数据进行了update，那么是否能同步修改所有的？有一个总的管理器，管理所有创建的Model？内存开销？


