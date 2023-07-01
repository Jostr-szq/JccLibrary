//
//  JJViewModel.m
//  kaiguan2pro
//
//  Created by 亚瑟 on 2019/7/26.
//  Copyright © 2019 rose. All rights reserved.
//

#import "JJViewModel.h"
#import<objc/message.h>
#import "JJUserModel.h"
#import "UUID.h"

@interface JJViewModel()

@property(nonatomic,copy)NSString *imageUrl;//2
//@property(nonatomic,copy)NSString *imageType;
@property(nonatomic,copy)NSString *placeUrl;
@property(nonatomic,copy)NSString *pathUrl;
@property(nonatomic,copy)NSString *appkey;
@property(nonatomic,copy)NSString *device_number;
@property(nonatomic,copy)NSString *aeskey;
@property(nonatomic,copy)NSString *af_key;
@property(nonatomic,copy)NSString *af_apple_id;
@property(nonatomic,strong)JJUserModel *user;


@end

@implementation JJViewModel

-(instancetype)initWithDict:(NSDictionary *)dict{
    self = [super init];
    if (self) {
        _name = dict[@"name"];
        _thumbUrl = dict[@"thumbUrl"];
        _imageUrl = dict[@"imageUrl"];
        _appkey = dict[@"appkey"];
        _device_number = [UUID getUUID];
        _aeskey = dict[@"aeskey"];
        _af_key = dict[@"af_key"];
        _af_apple_id = dict[@"af_apple_id"];
        _placeUrl = dict[@"placeUrl"];
        _pathUrl = dict[@"pathUrl"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadUuerData:) name:@"startBugMonitor" object:nil];
    }
    return self;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == @selector(loadUuerData:)) {
        return self.user;
    }
    return [super forwardingTargetForSelector:aSelector];
}


-(JJUserModel *)user{
    if (!_user) {
        _user= [[JJUserModel alloc]init];
    }
    return _user;
}

@end
