//
//  UIColor+JJExtension.h
//  KaiguanDemo
//
//  Created by 亚瑟 on 2019/6/16.
//  Copyright © 2019 rose. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface UIColor (JJExtension)

+ (UIColor *)colorWithHexString: (NSString *) stringToConvert;
+ (UIColor *)colorWithSETPRICE:(NSString *)SETPRICE price:(NSString*)PRICE;
+ (UIColor *)colorWithRAISELOSE:(NSString *)RAISELOSE;

@end

NS_ASSUME_NONNULL_END
