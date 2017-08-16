# wDModel

## 介绍

### 封装

这是一个对FMDB进行封装的sqlite ORM库，为了和当前应用场景完美替换，对于数据表的CREATE和MIGRATION不进行封装，需要用户用SQL进行『填空』。
一些方法的封装主要用到的objc的runtime特性。

### 功能

主要是对一些经常用到的CRUD方法进行封装，目标就是不失灵活性，又能比较好的做到ORM功能，所以提供了以下封装的方法。

* 通用SAVE方法
* 通用UPDATE方法
* 通用DELETE方法
* 通用FETCH方法，查询条件支持 = >= <= > <等运算方式
* 通用FETCH_ONE方法
* lazy延时加载功能，对于一些数据量比较大的数据可以进行懒加载操作，减少内存，用到的时候再用xxxField去读取
* changeXxx方法，可以单独保存某个属性的值
* xxxField方法可以单独读取某个属性的值，可以用于读取设置了lazy的属性或者解析NSData类型属性

### 不做的事情

对于数据表的CREATE和MIGRATION不进行封装，需要用户用SQL进行『填空』

## 代码示例

### 初始化

在项目初始化的位置，对Service的单例进行初始化操作。
*注意，如果项目已经做了Service层封装，那么只需要将WDBaseModel中用的的WDDBService方法在自己的Service中实现即可，然后调用自己的Service*

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WDDBService sharedInstance];
    return YES;
}
```

### 表初始化

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

### Model类创建

创建自己的Model类，继承自WDBaseModel，必须实现 @selector(tableName)、@selector(fields)、@selector(fieldForId)方法，具体如下。

注意：

* fields方法如果不增加，那默认就是数据库中user表的相应field名和User中的相应prop名一致。
* tableName如果不配置，那么表名即为类名
* fieldForId如果不配置，那么id字段即为『id』

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

@end
```

### Model类操作

然后save、update、fetch、delete调用就好了。

#### SAVE

```objc
//SAVE
WDUser *user = [[WDUser alloc] init];
    user.name = @"汤莹";
    user.email = @"450620338@qq.com";
    user.sex = @(UserSexFemale);
    [user save];
```

#### FETCH

查询有3种方式：

* 一种是fetch不带参数，那就等于查询所有的元素
* 一种是fetch带参数做『等于查询』
* 还一种是fetch的参数Dict中的key中已经带了运算表达式了，比如 ```@{@"user_id>=":@(1)}``` 就是查询user_id大于等于1的用户

当然，除了fetch外还有fetchOne，就是只查询一条，多用于比较明确的查询。

```objc
//fetch
//    NSArray *models = [WDUser fetch:@{@"email":@"xiao303178394@gmail.com"} sortField:nil isAsc:YES];
//    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSArray *models = [WDUser fetch:@{@"user_id>=":@(1)} sortField:nil isAsc:YES];
    NSLog(@"%@",models);
    WDUser *user2 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
```

#### UPDATE

```objc
    //update
    WDUser *user2 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
    user2.email = @"aaaaa.com";
    user2.weight = @(55.5);
    user2.parent = [NSKeyedArchiver archivedDataWithRootObject:@[@{@"father":@"A",@"age":@58},@{@"mother":@"B",@"age":@52}]];
    [user2 update];
```

#### DELETE

提供了3种删除方式：

* 调用实例的delete方法删除当前实例
* 调用类方法delete:，带field:value的Dict参数字典去删除
* 调用类方法deleteAllData，删除该数据库对象的所有内容

```objc
    //测试delete
    NSArray *models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSInteger beforeDeleteCount = [models count];

    //删除方法1,有id值的对象可以这样去调用实例方法去删除
//    WDUser *user4 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
//    [user4 delete];

    //删除方法2，比较灵活
//    [WDUser delete:@{@"user_id":@(2)}];

    //删除方法3，清空表，使用需谨慎
//    [WDUser deleteAllData];

    models = [WDUser fetch:nil sortField:nil isAsc:YES];
    NSInteger afterDeleteCount = [models count];
    NSLog(@"删除数据数量：%ld",beforeDeleteCount-afterDeleteCount);
```

#### INIT BY JSON

用于从json dict生成数据库对象的实例。或许有人觉得这个功能不应该放数据库对象中，但是暂时不考虑这些，先放这里吧。
User对象中增加如下方法:

```objc

+(NSArray *)fieldsForJson{
    return @[@{@"field":@"u_id",@"prop":@"userId"},
             @{@"field":@"name",@"prop":@"name"},
             @{@"field":@"email",@"prop":@"email"},
             @{@"field":@"sex",@"prop":@"sex"},
             @{@"field":@"weight",@"prop":@"weight"}];
}
```

该方法如果不增加，那默认就是json中的key和User中的prop名一致。

然后通过以下方法进行方向json dict：

```objc
    WDUser *user5 = [WDUser modelFromJsonDict:@{@"u_id":@(23),
                                                @"name":@"David_Wooo",
                                                @"email":@"david@paodong.cn",
                                                @"sex":@(UserSexMale),
                                                @"weight":@65.9}];
    [user5 save];
```


#### CHANGE

动态的改变Model的属性，主要应用于Model改变了一个属性又不想整个model去update（封装的Update生成的update sql会update所有属性），那就用这个功能去Update一个特定属性，比如下面例子生成的sql就是 ``` update user set weight=:weight where user_id=:user_id ```

```objc
      //动态改变属性
//    WDUser *user2 = (WDUser *)[WDUser fetchOne:@{@"user_id":@1}];
//    user2.weight = @67.9;
//    [user2 performSelector:@selector(changeWeight)];

    //动态读取属性，如果属性是NSData会解析
    WDUser *user3 = (WDUser *)[WDUser fetchOne:@{@"user_id":@2}];
    NSLog(@"parent:%@",[user3 performSelector:@selector(parentField)]);
    NSLog(@"weight:%@",[user3 performSelector:@selector(weightField)]);
```
#### LAZY 和 READ

有的属性数据比较大，不想立马加载出来占用内存，可以像如下代码设置，FETCH的时候不去加载该属性
```objc
@implementation WDUser

... ...

+ (NSArray *)fields{
    return @[@{@"field":@"user_id",@"prop":@"userId"},
             .... ...
             @{@"field":@"parent",@"prop":@"parent",@"lazy":@(YES)},];
}

... ...


@end

```
这样设置后，FETCH的User对象就没有parent这个对象，如果需要读取的话可以用 xxxField方法，如下：

```objc
    WDUser *user3 = (WDUser *)[WDUser fetchOne:@{@"user_id":@2}];
    NSLog(@"parent:%@",[user3 performSelector:@selector(parentField)]);
```



## TODO LIST

* get set 方法，现在都用KVC
* int float等类型的值，现在都只能用NSNumber
* read的时候用的是KVC，测试在有些名字情况下会出异常，比如有属性parent，然后又定义了个getParent方法，那么kvc读取parent的时候会去调用getParent
* json对象转换的转换方法自定义
* SAVE结束后自动填充id
* 所有的验证用AOP实现
* 框架重构 待测试，值测试了 save和get
* 减少配置：所有属性是否都默认入库，没有出现在fields中的是否默认为field与prop名相同？ to测试
* 减少配置：没有表名默认为类名首字母小写 to测试
* 减少配置：没有idField默认叫id？ to测试
* 性能：待测试
* 类型安全: 转换过程中，所有的数据类型都会被检测一遍，以保证类型安全，避免崩溃问题
* runtime 方法是否可以不用[user performSelector:@selector(parentField)]方式调用
* 已经fetch后的数据，其他地方对数据进行了update，那么是否能同步修改所有的？有一个总的管理器，管理所有创建的Model？内存开销？


