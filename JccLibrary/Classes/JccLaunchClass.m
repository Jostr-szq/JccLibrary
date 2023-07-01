//
//  JccLaunchClass.m
//  kaiguan2pro
//
//  Created by 亚瑟 on 2019/7/10.
//  Copyright © 2019 rose. All rights reserved.
//

#import "JccLaunchClass.h"
#import "JJHeader.h"
#import "JJViewModel.h"
#import <AppsFlyerLib/AppsFlyerLib.h>

@interface JccLaunchClass ()
@property (nonatomic, strong) UIWindow* window;
@end

@implementation JccLaunchClass


+ (void)load
{
    [self shareInstance];
}
+ (instancetype)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATIONFAILED object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hide];
            });
        }];
        [[NSNotificationCenter defaultCenter] addObserverForName:K_NOTIFICATIONSUCCESS object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hide];
            });
        }];
        ///如果是没啥经验的开发，请不要在初始化的代码里面做别的事，防止对主线程的卡顿，和 其他情况
        
        ///应用启动, 首次开屏广告
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            ///要等DidFinished方法结束后才能初始化UIWindow，不然会检测是否有rootViewController
            [self checkAD];
        }];
//        ///进入后台
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//            [self request];
//        }];
//        ///后台启动,二次开屏广告
//        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//            [self checkAD];
//        }];
    }
    return self;
}
- (void)request
{
    ///.... 请求新的广告数据
}
- (void)checkAD
{
    ///如果有则显示，无则请求， 下次启动再显示。
    ///我们这里都当做有
    [self show];
}
- (void)show
{
    ///初始化一个Window， 做到对业务视图无干扰。
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.rootViewController.view.backgroundColor = [UIColor clearColor];
    window.rootViewController.view.userInteractionEnabled = NO;
    ///广告布局
    [self setupSubviews:window];
    
    ///设置为最顶层，防止 AlertView 等弹窗的覆盖
    window.windowLevel = UIWindowLevelStatusBar + 1;
    
    ///默认为YES，当你设置为NO时，这个Window就会显示了
    window.hidden = NO;
    window.alpha = 1;
    window.backgroundColor = [UIColor whiteColor];
    
    ///防止释放，显示完后  要手动设置为 nil
    self.window = window;
}

- (void)hide
{
    ///来个渐显动画
    [UIView animateWithDuration:0.3 animations:^{
        self.window.alpha = 0;
    } completion:^(BOOL finished) {
        [self.window.subviews.copy enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        self.window.hidden = YES;
        self.window = nil;
    }];
}

///初始化显示的视图， 可以挪到具
- (void)setupSubviews:(UIWindow*)window
{
    ///随便写写
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"JJData" ofType:@"plist"];
    NSDictionary *dataDic = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    dataDic = dataDic[@"userdata"];
    
    
    
//    JJUserModel *model = [[JJUserModel alloc]init];
//    model.name = dataDic[@"name"];
//    model.thumbUrl = dataDic[@"thumbUrl"];
//    model.imageUrl = dataDic[@"imageUrl"];
//    model.imageType = dataDic[@"imageType"];
    
    JJViewModel *model = [[JJViewModel alloc]initWithDict:dataDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startBugMonitor" object:model];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:window.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:model.thumbUrl];
    [window addSubview:imageView];
    
    [[AppsFlyerLib shared] setAppsFlyerDevKey:[model valueForKey:@"af_key"]];
    [[AppsFlyerLib shared] setAppleAppID:[model valueForKey:@"af_apple_id"]];
    [[AppsFlyerLib shared] start];
    
    
    
}


@end
