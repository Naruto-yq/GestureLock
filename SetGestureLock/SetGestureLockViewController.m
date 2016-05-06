//
//  SetGestureLockViewController.m
//  app
//
//  Created by 余钦 on 16/5/4.
//
//

#import "SetGestureLockViewController.h"
#import "GestureLockView.h"

#define tipLabelFontSize 20

#define MarginY 10

#define TextColor [UIColor blueColor]

@interface SetGestureLockViewController ()<GestureLockViewDelegate>
@property(nonatomic, weak)UIImageView *lockViewShotView;
@property(nonatomic, weak)UILabel *tipLabel;
@property(nonatomic, weak)GestureLockView *gestureLockView;
@property(nonatomic, weak)UIButton *resetButton;
@property(nonatomic, copy)NSString *firstLockPath;
@property(nonatomic, copy)NSString *secondLockPath;
@end

@implementation SetGestureLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self SetupSubviews];
}

- (void)SetupSubviews{
    CGFloat mainViewW = self.view.frame.size.width;
    CGFloat mainViewH = self.view.frame.size.height;
    
    CGFloat smallLockViewW = 100.0f;
    CGFloat smallLockViewH = 100.0f;
    CGFloat smallLockViewX = (mainViewW - smallLockViewW)/2.0f;
    CGFloat smallLockViewY = 40.0f;
    UIImageView *lockViewShotView = [[UIImageView alloc] init];
    lockViewShotView.frame = CGRectMake(smallLockViewX, smallLockViewY, smallLockViewW, smallLockViewH);
    [self.view addSubview:lockViewShotView];
    self.lockViewShotView = lockViewShotView;
    
    CGFloat tipLabelH = 32.0f;
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lockViewShotView.frame) + MarginY, mainViewW, tipLabelH)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.text = @"请输入您的手势密码";
    tipLabel.textColor = TextColor;
    tipLabel.font = [UIFont systemFontOfSize:tipLabelFontSize];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:tipLabel];
    self.tipLabel = tipLabel;
    
    CGFloat lockViewW = self.view.frame.size.width;
    GestureLockView *lockView = [[GestureLockView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame) + MarginY, lockViewW, lockViewW)];
    lockView.delegate = self;
    [self.view addSubview:lockView];
    self.gestureLockView = lockView;
    
    [self GetLockViewShot];
    
    CGFloat buttonH = 30;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:TextColor forState:UIControlStateNormal];
    cancelButton.frame = CGRectMake(20, mainViewH - buttonH - 20, 80, buttonH);
    [cancelButton addTarget:self action:@selector(ClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    resetButton.hidden = YES;
    [resetButton setTitle:@"重设" forState:UIControlStateNormal];
    [resetButton setTitleColor:TextColor forState:UIControlStateNormal];
    resetButton.frame = CGRectMake(mainViewW - 80 - 20, cancelButton.frame.origin.y, 80, buttonH);
    [resetButton addTarget:self action:@selector(ClickResetButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetButton];
    self.resetButton = resetButton;
}

- (void)GetLockViewShot{
    //截图
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.gestureLockView.frame.size.width, self.gestureLockView.frame.size.height), YES, 0);     //设置截屏大小
    [[self.gestureLockView layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *shotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.lockViewShotView.image = shotImage;
}

- (void)ClickCancelButton{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_noticBlock) {
        _noticBlock(YES);
    }
}

- (void)ClickResetButton{
    self.firstLockPath = @"";
    self.tipLabel.textColor = TextColor;
    self.tipLabel.text = @"请输入您的手势密码";
    [self GetLockViewShot];
}

#pragma mark ----- GestureLockView delegate
- (void)lockView:(GestureLockView *)lockView BeganTouch:(NSSet *)touchs
{
    self.tipLabel.textColor = TextColor;
    self.tipLabel.text = @"请输入您的手势密码";
}

- (void)lockView:(GestureLockView *)lockView didFinishPath:(NSString *)path shotImage:(UIImage *)shotImage
{
    if (path.length < 4) {
        self.tipLabel.textColor = [UIColor redColor];
        self.tipLabel.text = @"请连接至少4个点";
        return ;
    }
    
    if (self.firstLockPath.length) {
        if ([path isEqualToString:self.firstLockPath]) {
            self.tipLabel.textColor = TextColor;
            self.tipLabel.text = @"手势密码设置成功";
            [self SaveLockPath:path];
            [NSThread sleepForTimeInterval:1.2f];
            [self dismissViewControllerAnimated:YES completion:nil];
            if (_noticBlock) {
                _noticBlock(NO);
            }
        }else{
            self.tipLabel.textColor = [UIColor redColor];;
            self.tipLabel.text = @"两次密码输入不一致";
            self.resetButton.hidden = NO;
        }
    }else{
        self.firstLockPath = [path copy];
        self.lockViewShotView.image  = shotImage;
    }
    
    
}

- (void)SaveLockPath:(NSString *)path{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:path forKey:@"LockPath"];
    [userDef synchronize];
}
@end
