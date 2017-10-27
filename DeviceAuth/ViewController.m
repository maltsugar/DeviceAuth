//
//  ViewController.m
//  DeviceAuth
//
//  Created by qm on 2017/10/27.
//  Copyright © 2017年 qm. All rights reserved.
//

#import "ViewController.h"
#import "DeviceAuth.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [DeviceAuth authDeviceWithDes:nil result:^(BOOL success, LAError error, NSString *errorDes) {
        if (success) {
            NSLog(@"成功");
        }else
        {
            NSLog(@"%@", errorDes);
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
