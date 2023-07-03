//
//  CFAppDelegate.m
//  JccLibrary
//
//  Created by 824656058@qq.com on 06/30/2023.
//  Copyright (c) 2023 824656058@qq.com. All rights reserved.
//

#import "CFAppDelegate.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@implementation CFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self getAdvertisingTrackingAuthority];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)getAdvertisingTrackingAuthority {
    
    if (@available(iOS 14, *)) {
            ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
            switch (status) {
                case ATTrackingManagerAuthorizationStatusDenied:
                    NSLog(@"用户拒绝IDFA");
                    break;
                case ATTrackingManagerAuthorizationStatusAuthorized:
                    NSLog(@"用户允许IDFA");
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined: {
                    NSLog(@"用户未做选择或未弹窗IDFA");
                    //请求弹出用户授权框，只会在程序运行是弹框1次，除非卸载app重装，通地图、相机等权限弹框一样
                    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                        NSLog(@"app追踪IDFA权限：%lu",(unsigned long)status);
                    }];
                }
                    break;
                default:
                    break;
            }
        } else {
            // iOS14以下版本依然使用老方法
             // 判断在设置-隐私里用户是否打开了广告跟踪
             if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
                 NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                 NSLog(@"用户允许广告追踪 idfa:%@",idfa);
             } else {
                 NSLog(@"用户限制了广告追踪");
             }
        }
}


@end
