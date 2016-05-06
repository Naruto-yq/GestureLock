//
//  SetGestureLockViewController.h
//  app
//
//  Created by 余钦 on 16/5/4.
//
//

#import <UIKit/UIKit.h>

typedef void (^NoticeSwitchOffBlock)(BOOL isCancel);

@interface SetGestureLockViewController : UIViewController
@property(nonatomic, copy)NoticeSwitchOffBlock noticBlock;
@end
