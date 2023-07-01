//
//  QSKeyChainStore.h
//  baoguan
//
//  Created by 周群 on 2018/5/10.
//  Copyright © 2018年 周群. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSKeyChainStore : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;
@end
