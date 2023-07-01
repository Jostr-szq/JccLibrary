//
//  UUID.m
//  GitProject
//
//  Created by jcf on 2023/6/30.
//

#import "UUID.h"
#import "QSKeyChainStore.h"

@implementation UUID

+(NSString *)getUUID
{
    //获取项目的bundle ID
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
    //根据bundle ID拼接一个自定义的key用来作为keychain里面的唯一标示
    //NSString *keyUUid = [NSString stringWithFormat:@"%@.uuid",bundleId];
    //将bundle ID作为唯一key在keychain里面获取保存的uuid
    NSString * strUUID = (NSString *)[QSKeyChainStore load:bundleId];
    
    //首次执行该方法时，uuid为空
    if ([strUUID isEqualToString:@""] || !strUUID)
    {
        //生成一个uuid的方法
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        
        //将该uuid保存到keychain
        [QSKeyChainStore save:bundleId data:strUUID];
        
    }
    return strUUID;
}

@end
