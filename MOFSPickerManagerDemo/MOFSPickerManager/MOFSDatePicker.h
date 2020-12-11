//
//  MOFSDatePicker.h
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/26.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolView.h"

typedef void (^CommitBlock)(NSDate * _Nullable date);
typedef void (^CancelBlock)(void);

@interface MOFSDatePicker : UIDatePicker

@property (nullable, nonatomic, strong) MOFSToolView *toolBar;
@property (nullable,nonatomic, strong) UIView *containerView;

@property (nullable,nonatomic, strong) void (^containerViewClickedBlock)(void);

/**
 * 显示日期选择器
 * @param selectedDate 默认选中的日期
 */
- (void)showWithSelectedDate:(NSDate * _Nullable)selectedDate
                      commit:(CommitBlock _Nullable)commitBlock
                      cancel:(CancelBlock _Nullable)cancelBlock;

/**
 * 显示日期选择器
 * @param title 选择器toolBar中间标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 * @param selectedDate 默认选中的日期
 * @param minDate 选择器最小日期
 * @param maxDate 选择器最大日期
 * @param mode 选择器模式
 */
- (void)showWithTitle:(NSString * _Nullable)title
          commitTitle:(NSString * _Nullable)commitTitle
          cancelTitle:(NSString * _Nullable)cancelTitle
         selectedDate:(NSDate * _Nullable)selectedDate
              minDate:(NSDate * _Nullable)minDate
              maxDate:(NSDate * _Nullable)maxDate
       datePickerMode:(UIDatePickerMode)mode
          commitBlock:(CommitBlock _Nullable )commitBlock
          cancelBlock:(CancelBlock _Nullable )cancelBlock;

@end
