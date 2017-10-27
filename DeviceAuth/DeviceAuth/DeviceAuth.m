//
//  DeviceAuth.m
//  DeviceAuth
//
//  Created by qm on 2017/10/27.
//  Copyright © 2017年 qm. All rights reserved.
//

#import "DeviceAuth.h"

@implementation DeviceAuth


+ (BOOL)isSupportBiometrics
{
    if (NSClassFromString(@"LAContext") != nil) {
        LAContext *context = [[LAContext alloc] init];
        return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL];
    }
    return NO;
}

+ (BOOL)isOpenDeviceLock
{
    if (NSClassFromString(@"LAContext") != nil) {
        LAContext *context = [[LAContext alloc] init];
        return [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:NULL];
    }
    return NO;
}

+ (void)authDeviceWithDes:(NSString *)des result:(authResult)result
{
    if (![self isOpenDeviceLock]) {
        result(NO, -1000, @"未开启设备锁"); // If passcode is not enabled, policy evaluation will fail.
        return;
    }
    
    
    if (nil == des) {
        if ([self isSupportBiometrics]) {
            if (isIPhoneX()) {
                des = @"验证面容ID";
            }else
            {
                des = @"验证Touch ID";
            }
        }else
        {
            des = @"验证设备密码";
        }
    }
    
    
    LAContext *context = [[LAContext alloc] init];
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:des reply:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                result(YES, error.code, error.localizedDescription);
            } else {
                result(NO, error.code, error.localizedDescription);
            }
        });
    }];
    
    
}

BOOL isIPhoneX(void) {
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)]) {
        return CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size);
    }else{
        return NO;
    }
}

@end
