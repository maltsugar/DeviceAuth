//
//  DeviceAuth.m
//  DeviceAuth
//
//  Created by qm on 2017/10/27.
//  Copyright © 2017年 qm. All rights reserved.
//

#import "DeviceAuth.h"

LAContext *__context;

@implementation DeviceAuth

+ (BOOL)isSupportBiometrics
{
    if (NSClassFromString(@"LAContext") != nil) {
        return [[self shareContext] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL];
    }
    return NO;
}

+ (BOOL)isSupportDeviceOwnerAuth
{
    if (@available(iOS 9.0, *)) {
        return [[self shareContext] canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:NULL];
    } else {
        // Fallback on earlier versions
        return NO;
    }
    return NO;
}

+ (void)authDeviceWithDes:(NSString *)des result:(authResult)result
{
    if (![self isSupportBiometrics]) {
        result(NO, -1000, @"不支持这种验证方式");
        return;
    }
    
    LAContext *context = [self shareContext];
    if (nil == des) {
        if ([self isSupportBiometrics]) {
            
            if (@available(iOS 11.0, *)) {
                if (context.biometryType == LABiometryTypeFaceID) {
                    des = @"验证面容ID";
                }
                if (context.biometryType == LABiometryTypeTouchID) {
                    des = @"验证Touch ID";
                }
                
            } else {
                // Fallback on earlier versions
                des = @"验证Touch ID";
            }
        }else
        {
            des = @"验证设备密码";
        }
    }
    
    
    // 8.0使用指纹验证
    LAPolicy policy = LAPolicyDeviceOwnerAuthenticationWithBiometrics;
    if (@available(iOS 9.0, *)) {
        policy = LAPolicyDeviceOwnerAuthentication;
    }
    
    [context evaluatePolicy:policy localizedReason:des reply:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                result(YES, error.code, error.localizedDescription);
            } else {
                result(NO, error.code, error.localizedDescription);
            }
        });
    }];
    
}

+ (LAContext *)shareContext
{
    if (nil == __context) {
        __context = [[LAContext alloc] init];
    }
    return __context;
}

@end
