//
//  GestureLockView.m
//  app
//
//  Created by 余钦 on 16/5/4.
//
//

#import "GestureLockView.h"

#define ButtonW 64
#define SmallViewButtonW 12


@interface GestureLockView ()
@property (nonatomic, strong) NSMutableArray *selectedButtons;
@property (nonatomic, assign) CGPoint currentMovePoint;
@end


@implementation GestureLockView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self SetupSubviews];
    }
    return self;
}

- (NSMutableArray *)selectedButtons
{
    if (_selectedButtons == nil) {
        _selectedButtons = [NSMutableArray array];
    }
    return _selectedButtons;
}

- (void)SetupSubviews{
    for (int nIndex = 0; nIndex < 9; nIndex++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = nIndex;
        btn.userInteractionEnabled = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        [self addSubview:btn];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    for (int index = 0; index<self.subviews.count; index++) {
        // 取出按钮
        UIButton *btn = self.subviews[index];
        
        // 设置frame
        CGFloat btnW = ButtonW;
        CGFloat btnH = ButtonW;
    
        int totalColumns = 3;
        int col = index % totalColumns;
        int row = index / totalColumns;
        CGFloat marginX = (self.frame.size.width - totalColumns * btnW) / (totalColumns + 1);
        CGFloat marginY = (self.frame.size.height - totalColumns * btnW) / (totalColumns + 1);;
        
        CGFloat btnX = marginX + col * (btnW + marginX);
        CGFloat btnY = marginY + row * (btnH + marginY);
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}
/**
 根据touches集合获得对应的触摸点位置
 */
- (CGPoint)pointWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:touch.view];
}

/**
 根据触摸点位置获得对应的按钮
 */
- (UIButton *)buttonWithPoint:(CGPoint)point
{
    for (UIButton *btn in self.subviews) {
//        CGFloat centerWidth = btn.frame.size.width * 0.5;
//        CGFloat frameX = btn.center.x - centerWidth * 0.5;
//        CGFloat frameY = btn.center.y - centerWidth * 0.5;
//        if (CGRectContainsPoint(CGRectMake(frameX, frameY, centerWidth, centerWidth), point)) {
        if (CGRectContainsPoint(btn.frame, point)) {
            return btn;
        }
    }
    return nil;
}

#pragma mark - 触摸方法
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(lockView:BeganTouch:)]) {
        [self.delegate lockView:self BeganTouch:touches];
    }

    // 清空当前的触摸点
    self.currentMovePoint = CGPointMake(-10, -10);
    
    // 1.获得触摸点
    CGPoint pos = [self pointWithTouches:touches];
    
    // 2.获得触摸的按钮
    UIButton *btn = [self buttonWithPoint:pos];
    
    // 3.设置状态
    if (btn && btn.selected == NO) {
        btn.selected = YES;
        [self.selectedButtons addObject:btn];
    }
    
    // 4.刷新
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 1.获得触摸点
    CGPoint pos = [self pointWithTouches:touches];
    
    // 2.获得触摸的按钮
    UIButton *btn = [self buttonWithPoint:pos];
    
    // 3.设置状态
    if (btn && btn.selected == NO) { // 摸到了按钮
        btn.selected = YES;
        [self.selectedButtons addObject:btn];
    } else { // 没有摸到按钮
        self.currentMovePoint = pos;
    }
    
    // 4.刷新
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(lockView:didFinishPath: shotImage:)]) {
        NSMutableString *path = [NSMutableString string];
        for (UIButton *btn in self.selectedButtons) {
            [path appendFormat:@"%ld", (long)btn.tag];
        }
        NSLog(@"--->>>path:%@", path);
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.frame.size.width, self.frame.size.height), YES, 0);     //设置截屏大小
        [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *shotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.delegate lockView:self didFinishPath:path shotImage:shotImage];
    }
    
    // 取消选中所有的按钮
    for (UIButton *btn in self.selectedButtons) {
        [btn setSelected:NO];
    }
    
    [self.selectedButtons makeObjectsPerformSelector:@selector(setSelected:) withObject:@(NO)];
    
    // 清空选中的按钮
    [self.selectedButtons removeAllObjects];
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - 绘图
- (void)drawRect:(CGRect)rect
{
    if (self.selectedButtons.count == 0) return;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // 遍历所有的按钮
    for (int index = 0; index<self.selectedButtons.count; index++) {
        UIButton *btn = self.selectedButtons[index];
        
        if (index == 0) {
            [path moveToPoint:btn.center];
        } else {
            [path addLineToPoint:btn.center];
        }
    }
    
    // 连接
    if (CGPointEqualToPoint(self.currentMovePoint, CGPointMake(-10, -10)) == NO) {
        [path addLineToPoint:self.currentMovePoint];
    }
    
    // 绘图
    path.lineWidth = 5;
    
    path.lineJoinStyle = kCGLineJoinBevel;
    [[UIColor blackColor] set];
    [path stroke];
}

@end
