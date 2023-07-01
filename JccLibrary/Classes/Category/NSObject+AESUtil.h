//
//  NSObject+AESUtil.h
//  JQLFramework
//
//  Created by jcf on 2023/6/20.
//  Copyright © 2023 rose. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (AESUtil)

/**
 * AES加密
 */
+ (NSString *)aesEncrypt:(NSString *)sourceStr withKey:(NSString *)key;
 
/**
 * AES解密
 */
+ (NSString *)aesDecrypt:(NSString *)secretStr withKey:(NSString *)key;

@end

