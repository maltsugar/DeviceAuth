//
//  DeviceAuth.m
//  DeviceAuth
//
//  Created by qm on 2017/10/27.
//  Copyright © 2017年 qm. All rights reserved.
//

#import "DeviceAuth.h"

LAContext *__context;

NSError *checkError;

@implementation DeviceAuth



static DeviceAuth *_instance;
+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    
    return _instance;
}

+ (instancetype)defaultChecker
{
    if (_instance == nil) {
        _instance = [[DeviceAuth alloc] init];
        [_instance initConfig];
    }
    return _instance;
}

- (void)initConfig
{
    //系统api有问题 直接 [OwnChecker systemContext].biometryType  都返回none
    // 需要先调一下下面的
    
    BOOL flag0 = [DeviceAuth isSupportDeviceOwnerAuth];
    BOOL flag1 = [DeviceAuth isSupportBiometrics];
    NSLog(@"ownerAuth: %d,  Biometrics: %d", flag0, flag1); // 系统API 有bug 先调用一下
    
    self.bioType = DABiometryTypeNone;
    if (@available(iOS 11.0, *)) {
        if ([DeviceAuth systemContext].biometryType == LABiometryTypeTouchID) {
            self.bioType = DABiometryTypeTouchID;
        }
        if ([DeviceAuth systemContext].biometryType == LABiometryTypeFaceID) {
            self.bioType = DABiometryTypeFaceID;
        }
    }
}


+ (BOOL)isSupportBiometrics
{
    checkError = nil;
    if (NSClassFromString(@"LAContext") != nil) {
        NSError *error;
        BOOL flag = [[self systemContext] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
        if (error) {
            checkError = error;
            NSLog(@"%@", error.localizedDescription);
        }
        
        return flag;
    }
    return NO;
}

+ (BOOL)isSupportDeviceOwnerAuth
{
    checkError = nil;
    if (@available(iOS 9.0, *)) {
        NSError * error;
        BOOL flag = [[self systemContext] canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error];
        if (error) {
            checkError = error;
            NSLog(@"%@", error.localizedDescription);
        }
        return flag;
    } else {
        // Fallback on earlier versions
        return NO;
    }
    return NO;
}

+ (void)authDeviceWithDes:(NSString *)des result:(authResult)result
{
    
    if (![self isSupportBiometrics]) {
        NSString *tip = @"暂不支持";
        if (checkError) {
            NSLog(@"%@", checkError);
            if (checkError.code == -8) {
                tip = @"超出尝试次数，需要您使用密码解锁设备一次";
                des = tip;
            }
        }
    }
    
    LAContext *context = [self systemContext];
    if (@available(iOS 9.0, *)) {
        LAPolicy policy = LAPolicyDeviceOwnerAuthentication;
        
        if (nil == des) {
            if ([self isSupportDeviceOwnerAuth]) {
                
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
        
        
        
        
        [context evaluatePolicy:policy localizedReason:des reply:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    result(YES, error.code, error.localizedDescription);
                } else {
                    result(NO, error.code, error.localizedDescription);
                }
            });
        }];
    } else {
        // Fallback on earlier versions
        NSLog(@"暂不支持iOS9以下");
    }
    
}

+ (LAContext *)systemContext
{
    if (nil == __context) {
        __context = [[LAContext alloc] init];
    }
    return __context;
}

@end
