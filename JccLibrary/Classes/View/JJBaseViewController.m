//
//  JJBaseViewController.m
//  KaiguanDemo
//
//  Created by 亚瑟 on 2019/6/16.
//  Copyright © 2019 rose. All rights reserved.
//

#import "JJBaseViewController.h"
#import "SVProgressHUD.h"
#import "UIColor+JJExtension.h"
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>
#import "JJBaseDataModel.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import "UUID.h"


@interface JJBaseViewController () < WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, copy) NSString *messageStr;

@end

@implementation JJBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadWebView];
    [self loadWebUrl];
}

- (void)loadWebView {
    if (self.viewType == JJViewType7KU) {
        self.viewType = JJViewType7KU;
        self.messageStr = @"Message";
    } else {
        self.viewType = JJViewTypeWSD;
        self.messageStr = @"eventTracker";
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"openSafari"];
    }
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:self.messageStr];
    [self.view addSubview:self.webView];

}

- (void)loadWebUrl {
    // 加载图片
    NSURL *url = [NSURL URLWithString:self.imageUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)dealloc {
    [self.webView.configuration.userContentController removeAllUserScripts];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.viewType == JJViewType7KU) {
        if ([message.name isEqualToString:@"Message"]) {
            NSDictionary *dict = message.body;
            NSString *name = dict[@"name"];
            NSDictionary *jsonDict = [self dictionaryWithJsonString:dict[@"data"]];
            if ([name isEqualToString:@"openWindow"]) {
                JJBaseViewController *vc = [[JJBaseViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.imageUrl = jsonDict[@"url"];
                vc.viewType = self.viewType;
                [self presentViewController:vc animated:YES completion:nil];
            }else if ([name isEqualToString:@"closeWindow"]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self updateAppFunc:name withData:jsonDict];
            }
        }
    } else {
        if ([message.name isEqualToString:@"eventTracker"]) {
            NSDictionary *dict = message.body;
            NSString *name = dict[@"eventName"];
            NSDictionary *jsonDict = [self dictionaryWithJsonString:dict[@"eventValue"]];
            if ([name isEqualToString:@"openWindow"]) {
                JJBaseViewController *vc = [[JJBaseViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.imageUrl = jsonDict[@"url"];
                vc.viewType = self.viewType;
                [self presentViewController:vc animated:YES completion:nil];
            } else if ([name isEqualToString:@"closeWindow"]) {
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self updateAppFunc:name withData:jsonDict];
            }
        }else if ([message.name isEqualToString:@"openSafari"]) {
            NSDictionary *dict = message.body;
            NSString *urlstr = dict[@"url"];
            NSString *typestr = dict[@"type"];
            if (typestr.intValue == 2) {
                JJBaseViewController *vc = [[JJBaseViewController alloc] init];
                vc.modalPresentationStyle = UIModalPresentationFullScreen;
                vc.imageUrl = urlstr;
                vc.viewType = self.viewType;
                [self presentViewController:vc animated:YES completion:nil];
            } else {
                NSURL *url = [NSURL URLWithString:urlstr];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                }
            }
        }
    }
}


#pragma mark WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (self.viewType == JJViewType7KU) {
        if(navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame)
        {
            [webView loadRequest:navigationAction.request];
        }
    }else {
        NSURL *url = navigationAction.request.URL;
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                
            }];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *a = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            completionHandler();
        }];
        [alert addAction:a];
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:alert animated:YES completion:nil];
    } else {
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark WKNavigationDelegate

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [SVProgressHUD show];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [SVProgressHUD dismiss];
}

# pragma mark 属性懒加载

- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        config.preferences = [WKPreferences new];
        config.preferences.minimumFontSize = 10.0f;
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.applicationNameForUserAgent = [self getUserAgentString];
        config.userContentController = [[WKUserContentController alloc] init];
        NSString * source = [NSString stringWithFormat:@"window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.%@.postMessage({name, data})\n    }\n};\n",self.messageStr];
        WKUserScript * userScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:false];
        [config.userContentController addUserScript:userScript];
        config.allowsInlineMediaPlayback = YES;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, [self vg_safeDistanceTop], self.view.bounds.size.width, self.view.bounds.size.height - [self vg_safeDistanceTop]) configuration:config];
        _webView.scrollView.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentNever;
//        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
    }
    return _webView;
}

# pragma mark 私有方法

- (NSString *)getUserAgentString {
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *userAgentStr = [NSString stringWithFormat:@"%@/AppShellVer:%@ UUID/%@",phoneModel,app_Version ,[UUID getUUID]];
    return userAgentStr;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
   if (jsonString == nil) {
       return nil;
   }
   NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
   NSError *err;
   NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&err];
   if(err) {
       NSLog(@"json解析失败：%@",err);
       return nil;
   }
   return dic;
}

- (void)updateAppFunc:(NSString *)name withData:(NSDictionary *)data {
    if ([name isEqualToString:@"firstrecharge"] || [name isEqualToString:@"recharge"]  || [name isEqualToString:@"withdrawOrderSuccess"] ) {
        float amount = [data[@"amount"] floatValue];
        if ([name isEqualToString:@"withdrawOrderSuccess"] ) {
            amount = -amount;
        }
        [[AppsFlyerLib shared] logEventWithEventName:name eventValues:@{AFEventParamRevenue:@(amount)} completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            NSLog(@"事件上传：%@",dictionary);
        }];
    } else if ([name isEqualToString:@"withdraw"] || [name isEqualToString:@"firstDepositArrival"]  || [name isEqualToString:@"deposit"] || [name isEqualToString:@"depositSubmit"] || [name isEqualToString:@"firstDeposit"]) {
        float amount = [data[@"revenue"] floatValue];
        [[AppsFlyerLib shared] logEventWithEventName:name eventValues:@{AFEventParamRevenue:@(amount)} completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            NSLog(@"事件上传：%@",dictionary);
        }];
    } else {
        [[AppsFlyerLib shared] logEventWithEventName:name eventValues:nil completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            NSLog(@"事件上传：%@",dictionary);
        }];
    }
}

/// 顶部安全区高度
- (CGFloat)vg_safeDistanceTop {
    if (@available(iOS 13.0, *)) {
        NSSet *set = [UIApplication sharedApplication].connectedScenes;
        UIWindowScene *windowScene = [set anyObject];
        UIWindow *window = windowScene.windows.firstObject;
        return window.safeAreaInsets.top;
    } else if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].windows.firstObject;
        return window.safeAreaInsets.top;
    }
    return 0;
}



@end

