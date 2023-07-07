<<<<<<< HEAD
# JccLibrary

[![CI Status](https://img.shields.io/travis/824656058@qq.com/JccLibrary.svg?style=flat)](https://travis-ci.org/824656058@qq.com/JccLibrary)
[![Version](https://img.shields.io/cocoapods/v/JccLibrary.svg?style=flat)](https://cocoapods.org/pods/JccLibrary)
[![License](https://img.shields.io/cocoapods/l/JccLibrary.svg?style=flat)](https://cocoapods.org/pods/JccLibrary)
[![Platform](https://img.shields.io/cocoapods/p/JccLibrary.svg?style=flat)](https://cocoapods.org/pods/JccLibrary)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JccLibrary is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JccLibrary'
```

1. 引入JJdata.plist数据文件，使用Base64加密
2. 添加info.plist权限
   - App Transport Security Settings
   - Privacy - Camera Usage Description
   - Privacy - Photo Library Usage Description
   - Privacy - Tracking Usage Description
   - Privacy - Location Always and When In Use Usage Description
   - Privacy - Location When In Use Usage Description
   - Privacy - Location Usage Description
   - App Uses Non-Exempt Encryption
3. 添加请求追踪权限代码

```objective-c
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


-(void)applicationDidBecomeActive:(UIApplication *)application {
    [self getAdvertisingTrackingAuthority];
}

```



## Author

824656058@qq.com, black@gmail.com

## License

JccLibrary is available under the MIT license. See the LICENSE file for more info.
=======
# JccLibrary
>>>>>>> 9e57eec29761a6448ceb32edc9fb79563798cbf5
