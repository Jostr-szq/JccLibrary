//
//  JJViewModel.h
//  kaiguan2pro
//
//  Created by 亚瑟 on 2019/7/26.
//  Copyright © 2019 rose. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJViewModel : NSObject

@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *thumbUrl;
-(instancetype)initWithDict:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
