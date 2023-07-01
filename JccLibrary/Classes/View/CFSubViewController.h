//
//  CFSubViewController.h
//  webDemo
//
//  Created by jcf on 2023/6/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClosedViewBlock)();

@interface CFSubViewController : UIViewController

@property (nonatomic, copy) NSString *urlStr;

@property (nonatomic, copy) NSString *messageStr;

@property (nonatomic, copy) ClosedViewBlock closedBlock;


@end

NS_ASSUME_NONNULL_END
