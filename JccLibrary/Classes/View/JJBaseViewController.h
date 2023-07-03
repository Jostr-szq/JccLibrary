//
//  JJBaseViewController.h
//  KaiguanDemo
//
//  Created by 亚瑟 on 2019/6/16.
//  Copyright © 2019 rose. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    JJViewType7KU,
    JJViewTypeWSD,
} JJViewType;




@interface JJBaseViewController : UIViewController

@property (nonatomic, assign) JJViewType viewType;

@property (nonatomic, copy) NSString *imageUrl;

@end

