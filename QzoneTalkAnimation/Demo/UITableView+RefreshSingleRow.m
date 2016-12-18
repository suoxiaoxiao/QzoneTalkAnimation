//
//  UITableView+RefreshSingleRow.m
//  Demo
//
//  Created by 索晓晓 on 16/10/26.
//  Copyright © 2016年 SXiao.RR. All rights reserved.
//

#import "UITableView+RefreshSingleRow.h"
#import <objc/runtime.h>

static const char *kAnimationFloatCoefficient = "kAnimationFloatCoefficient";
static const char *kAnimationbearingLayer = "kAnimationbearingLayer";
static const char *kAnimationStatus = "kAnimationStatus";
static NSString *const kGroupAnimationKey = @"kGroupAnimationKey";
static NSString *const kGroupKey = @"kGroupKey";
static NSString *const kGroupValue = @"kGroupValue";


CG_INLINE CGPoint
__CGPointSum(CGPoint point1, CGPoint point2)
{
    CGPoint point;
    point.x = point1.x + point2.x;
    point.y = point1.y + point2.y;
    return point;
}

#define CGPointSum __CGPointSum

CG_INLINE CGSize
__CGSizeSum(CGSize size1, CGSize size2)
{
    CGSize size;
    size.width = size1.width + size2.width;
    size.height = size1.height + size2.height;
    return size;
}

#define CGSizeSum __CGSizeSum

CG_INLINE CGRect
__CGRectSum(CGRect rect1, CGRect rect2)
{
    CGRect rect;
    rect.origin.x = rect1.origin.x + rect2.origin.x;
    rect.origin.y = rect1.origin.y + rect2.origin.y;
    rect.size.width = rect1.size.width + rect2.size.width;
    rect.size.height = rect1.size.height + rect2.size.height;
    return rect;
}

#define CGRectSum __CGRectSum

CG_INLINE CGPoint
__CGRectCenter(CGRect rect)
{
    CGPoint point;
    point.x = rect.origin.x + rect.size.width * 0.5;
    point.y = rect.origin.y + rect.size.height * 0.5;
    return point;
}

#define CGRectCenter __CGRectCenter

CG_INLINE CGPoint
__CGPointOffset(CGPoint point,CGFloat x,CGFloat y)
{
    CGPoint newPoint;
    newPoint.x = point.x + x;
    newPoint.y = point.y + y;
    return newPoint;
}

#define CGPointOffset __CGPointOffset


@interface UITableView ()<CAAnimationDelegate>

@property (nonatomic , strong)NSNumber *isAnimation;

@property (nonatomic ,strong)UIView *bearingAnimation;

@end

@implementation UITableView (RefreshSingleRow)

- (void)setBearingAnimation:(UIView *)bearingAnimation
{
    objc_setAssociatedObject(self, kAnimationbearingLayer,bearingAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)bearingAnimation
{
    return objc_getAssociatedObject(self, kAnimationbearingLayer);
}

- (void)setCoefficient:(NSNumber *)coefficient
{
    objc_setAssociatedObject(self, kAnimationFloatCoefficient,coefficient, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)coefficient
{
    return objc_getAssociatedObject(self, kAnimationFloatCoefficient);
}

- (void)setIsAnimation:(NSNumber *)isAnimation
{
    objc_setAssociatedObject(self, kAnimationStatus,isAnimation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)isAnimation
{
    return objc_getAssociatedObject(self, kAnimationStatus);
}



- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowCustomAnimation:(TableViewRowAnimation)animation
{
    switch (animation) {
        case TableViewRowAnimation3DInsertMode:
        {
            
            if ([self.isAnimation boolValue]){
                //暂停动画
                [self.bearingAnimation removeFromSuperview];
                self.bearingAnimation = nil;
                //直接刷新 不进行动画
                [self reloadData];
                //改变bool值
                 self.isAnimation = [NSNumber numberWithBool:NO];
                
                return;
            }else self.isAnimation = [NSNumber numberWithBool:YES];
            
            //自定义动画
            NSIndexPath *indexpath = indexPaths[0];
            //拿到当前行高度
            CGFloat cellH = [self.delegate tableView:self heightForRowAtIndexPath:indexpath];
            
            //让tableView往下移动当前cell的高度
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y - cellH);
            
            
            UITableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexpath];
            
            CGRect cellF = [self rectForRowAtIndexPath:indexpath];
            
            
            NSString *classStr = @"UITableViewWrapperView";
            
            Class wrapperView = NSClassFromString(classStr);
            
            UIView *diceng = nil;
            
            for (UIView *sub in self.subviews) {
                
                if ([sub isKindOfClass:[wrapperView class]]) {
                    diceng = sub;
                    break;
                }
                
            }
            if (diceng == nil) return;
            
            NSLog(@"找到了UITableViewWrapperView");
            
            //设置当前的Frame
            cell.frame = (CGRect){CGPointOffset(cellF.origin,0,-cellH),cellF.size};
            
            if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                
                [cell setSeparatorInset:UIEdgeInsetsZero];
                
            }
            
            if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
                
                [cell setLayoutMargins:UIEdgeInsetsZero];
                
            }
            
            //设置层级关系
            //创建一个动画承载层 防止同层之间的旋转动画造成视觉层级错乱问题
            self.bearingAnimation = [[UIView alloc] initWithFrame:diceng.bounds];
            [self.bearingAnimation addSubview:cell];
            
            [diceng insertSubview:self.bearingAnimation atIndex:0];
            
            
            
            //设置动画系数
            if (!self.coefficient) {
                self.coefficient = @(0.1);
            }
            
            float floatCoeffic = [self.coefficient floatValue]*cellF.size.width;
            
            //设置动画
            CGPoint startPosition = CGRectCenter(cellF);
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.duration = 2.5;
            [group setValue:kGroupValue forKey:kGroupKey];
            group.delegate = self;
            
            //移动动画
            CAKeyframeAnimation *keyani = [CAKeyframeAnimation animationWithKeyPath:@"position"];
            CGMutablePathRef mutablePath = CGPathCreateMutable();
            
            UIBezierPath *bezier = [[UIBezierPath alloc] init];
            [bezier moveToPoint:startPosition];
            [bezier addQuadCurveToPoint:CGPointOffset(startPosition,0,-cellH) controlPoint:CGPointOffset(CGPointOffset(startPosition,0,-cellH),-floatCoeffic,-floatCoeffic)];
            
            CGPathAddPath(mutablePath, NULL, bezier.CGPath);
            
            keyani.path = mutablePath;
            
            keyani.duration = 1.5;
            
            keyani.repeatCount = 1;
            
            keyani.removedOnCompletion = NO;
            
            keyani.autoreverses = NO;
            
            keyani.fillMode = kCAFillModeForwards;
            
            keyani.calculationMode = kCAAnimationLinear;
            
            keyani.timingFunction = [CAMediaTimingFunction  functionWithName:kCAMediaTimingFunctionEaseIn];
            
            //旋转动画
            CABasicAnimation *base = [CABasicAnimation animationWithKeyPath:@"transform"];
            
            base.beginTime = 0;
            
            CATransform3D startTrs = CATransform3DRotate(CATransform3DIdentity, M_PI_4, 1, 0, 0);
            
            CATransform3D endTrs = CATransform3DIdentity;
            
            base.fromValue = [NSValue valueWithCATransform3D:startTrs];
            base.toValue = [NSValue valueWithCATransform3D:endTrs];
            
            base.duration = 2.5;
            
            base.repeatCount = 1;
            
            base.removedOnCompletion = NO;
            
            base.autoreverses = NO;
            
            base.fillMode = kCAFillModeForwards;
            
            group.animations = @[keyani,base];
            
            [cell.layer addAnimation:group forKey:kGroupAnimationKey];
            
        }
            break;
            
        default:
            
            return [self insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimation)animation];
            
            break;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"%@",[anim valueForKey:kGroupKey]);
    
    //因为复用问题 所以需要清空动画
    if ([[anim valueForKey:kGroupKey] isEqualToString:kGroupValue]) {
        
        for (UIView *sub in self.bearingAnimation.subviews) {
            
            [sub.layer removeAnimationForKey:kGroupAnimationKey];
            
        }
        [self.bearingAnimation removeFromSuperview];
        self.bearingAnimation = nil;
        self.isAnimation = [NSNumber numberWithBool:NO];
        [self reloadData];
        
    }
    
}

@end
