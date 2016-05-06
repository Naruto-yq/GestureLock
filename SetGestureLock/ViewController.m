//
//  ViewController.m
//  SetGestureLock
//
//  Created by 余钦 on 16/5/6.
//  Copyright © 2016年 yuqin. All rights reserved.
//

#import "ViewController.h"
#import "SetGestureLockViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SetGestureLock:(id)sender {
    SetGestureLockViewController *setLockVc = [[SetGestureLockViewController alloc] init];
    [self presentViewController:setLockVc  animated:YES completion:nil];
}

@end
