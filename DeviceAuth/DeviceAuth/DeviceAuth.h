//
//  DeviceAuth.h
//  DeviceAuth
//
//  Created by qm on 2017/10/27.
//  Copyright © 2017年 qm. All rights reserved.
//  一般用于登录，支付等。首先验证指纹（iPhone X 面容ID），失败时可以选择输入设备密码

#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface DeviceAuth : NSObject

typedef void (^authResult)(BOOL success, LAError error, NSString *errorDes);

// 是否支持生物学识别（TouchID 面容ID）
+ (BOOL)isSupportBiometrics;

// 是否开启设备锁
+ (BOOL)isOpenDeviceLock;

/**
 验证设备，如果支持生物识别，首先验证指纹（iPhone X 面容ID），失败时可以选择输入设备密码。 否则直接验证设备锁
 
 @param des 验证时的提示，可以不传
 @param result 验证结果
 */
+ (void)authDeviceWithDes:(NSString *)des result:(authResult)result;


@end
