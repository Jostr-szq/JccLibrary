//
//  NSData+Base64.h
//  加密算法
//
//  Created by scn on 16/9/5.
//  Copyright © 2016年 TAnna. All rights reserved.
//

#import <Foundation/Foundation.h>
//可逆算法
@interface NSData (Base64)
+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
@end
@interface NSString (Base64)
+ (NSString *)stringWithBase64EncodedString:(NSString *)string;
- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSData *)base64DecodedData;

@end