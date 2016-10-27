//
//  UITableView+RefreshSingleRow.h
//  Demo
//
//  Created by 索晓晓 on 16/10/26.
//  Copyright © 2016年 SXiao.RR. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TableViewRowAnimation) {
    
    TableViewRowAnimationFade = UITableViewRowAnimationFade,
    TableViewRowAnimationRight = UITableViewRowAnimationRight,           // slide in from right (or out to right)
    TableViewRowAnimationLeft = UITableViewRowAnimationLeft,
    TableViewRowAnimationTop = UITableViewRowAnimationTop,
    TableViewRowAnimationBottom = UITableViewRowAnimationBottom,
    TableViewRowAnimationNone = UITableViewRowAnimationNone,            // available in iOS 3.0
    TableViewRowAnimationMiddle = UITableViewRowAnimationMiddle,          // available in iOS 3.2.  attempts to keep cell centered in the space it will/did occupy
    TableViewRowAnimationAutomatic = UITableViewRowAnimationAutomatic,  // available in iOS 5.0.  chooses an appropriate animation style for you
    TableViewRowAnimation3DInsertMode
};

@interface UITableView (RefreshSingleRow)
//动画幅度系数(0-1)
@property (nonatomic , strong)NSNumber *coefficient;

- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowCustomAnimation:(TableViewRowAnimation)animation;

@end
