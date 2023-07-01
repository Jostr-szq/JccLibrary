//
//  CFSubViewController.m
//  webDemo
//
//  Created by jcf on 2023/6/30.
//

#import "CFSubViewController.h"
#import <WebKit/WebKit.h>
#import <AppsFlyerLib/AppsFlyerLib.h>

@interface CFSubViewController ()<WKScriptMessageHandler>

@property (nonatomic,  strong ) WKWebView *webView;

@end

@implementation CFSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadWebView];
    [self loadWebUrl];
}

- (void)loadWebView {
    
    [self.view addSubview:self.webView];
    // 777事件监听
    [self.webView.configuration.userContentController addScriptMessageHandler:self name:self.messageStr];
    // WSD时间监听
//    [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"eventTracker"];
    
}

- (void)loadWebUrl {
    // 加载HTML
    NSURL *url = [NSURL URLWithString:self.urlStr];
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
    if ([message.name isEqualToString:@"Message"]) {
        NSDictionary *dict = message.body;
        NSString *name = dict[@"name"];
        NSDictionary *jsonDict = [self dictionaryWithJsonString:dict[@"data"]];
        [self updateAppFunc:name withData:jsonDict];
        if ([name isEqualToString:@"openWindow"]) {
            CFSubViewController *vc = [[CFSubViewController alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.urlStr = jsonDict[@"url"];
            [self presentViewController:vc animated:YES completion:nil];
        }
        if ([name isEqualToString:@"openWindow"])  {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else if ([message.name isEqualToString:@"eventTracker"]) {
        NSDictionary *dict = message.body;
        NSString *name = dict[@"name"];
        NSDictionary *jsonDict = [self dictionaryWithJsonString:dict[@"data"]];
        [self updateAppFunc:name withData:jsonDict];
    }
}


- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        config.preferences = [WKPreferences new];
        config.preferences.minimumFontSize = 10.0f;
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        config.userContentController = [[WKUserContentController alloc] init];
        NSString * source = [NSString stringWithFormat:@"window.jsBridge = {\n    postMessage: function(name, data) {\n        window.webkit.messageHandlers.%@.postMessage({name, data})\n    }\n};\n",self.messageStr];
        WKUserScript * userScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:false];
        [config.userContentController addUserScript:userScript];
        config.allowsInlineMediaPlayback = YES;
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.UIDelegate = self;
    }
    return _webView;
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
   if(err)
   {
       NSLog(@"json解析失败：%@",err);
       return nil;
   }
   return dic;
}

- (void)updateAppFunc:(NSString *)name withData:(NSDictionary *)data {
    [[AppsFlyerLib shared] logEventWithEventName:name eventValues:data completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
        NSLog(@"事件上传：%@",dictionary);
    }];
}


- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if(navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame)
    {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
@end
