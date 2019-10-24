//
//  LQYPickerView.h
//  MOFSPickerManagerDemo
//
//  Created by luoyuan on 2019/10/22.
//  Copyright © 2019 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LQYPickerViewLayout : NSObject

@property (nonatomic, assign) CGFloat marginLeft;
@property (nonatomic, assign) CGFloat marginRight;
@property (nonatomic, assign) CGFloat marginBottom;

//高度，默认216
@property (nonatomic, assign) CGFloat height;
//默认 44
@property (nonatomic, assign) CGFloat toolBarHeight;

@end



@interface LQYPickerView : UIPickerView

@property (nonatomic, strong) LQYPickerViewLayout *layout;
//背景透明度， 默认0.4
@property (nonatomic, assign) CGFloat maskAlpha;
@property (nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *textAttributes;

@property (nonatomic, strong, readonly) MOFSToolView *toolBar;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) UIView *maskView;

@property (nonatomic, weak) UIView *parentView;

/**
 * 是否为动态，即联动
 */
@property (nonatomic, assign) BOOL isDynamic;

/**
 * 级数
 * isDynamic = true有效
 * 默认值 1
 */
@property (nonatomic, assign) NSInteger numberOfSection;

/**
* 下一层数据源 key值
* isDynamic = true有效
* @{component : key}
*/
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *dataKeys;

/**
 * 数据内容key值
 * 格式 @{component : key}
 * 当数据源类型为NSDictionary或NSObject时调用
 * 例如 [@[@{@"name_0" : @"kamio"}, @{@"name_1" : @"nagisa"}]]时，其值应该为@{@0 : @"name_0", @1 : @"name_1"};如果key值都相同，可以只设置一个，例如@{@0 : @"name"}
 */
@property (nonatomic, strong) NSDictionary<NSNumber *, NSString *> *dataTextKeys;


/**
 * 数据
 * 内容可以是NSString、NSDictionary和NSObject；其中 NSDictionary和NSObject需要提供dataTextKeys来取出内容
 * 静态格式：1. @[@"kamio", @"nagisa", @"misuzu"] (一级)
 *         2. @[@{@"name" : @"kamio"}, @{@"name" : @"nagisa"}] (一级)
 *         3. @[@[@"a", @"b", @"c"], @[@"1", @"2", @"3"]] (多级，取决于最外层数组长度)
 * 动态格式：@[@{@"name" : @"广东", @"list" : @[@"深圳", @"广州"]}, @{@"name" : @"广西", @"list" : @[@"南宁", @"桂林"]}];
 */
@property (nonatomic, strong) NSArray *dataArray;


@property (nonatomic, copy) void (^commitBlock)(NSDictionary<NSNumber *, id> * _Nullable json);

/**
 * 获取某个component下的 数组
 */
- (nullable NSArray *)getDataArrayForComponent:(NSInteger)component;

- (void)show;


- (void)dismiss;

@end

/**------------------年月选择器-----------------------*/

@interface LQYYearAndMonthPickerView : LQYPickerView

@property (nullable, nonatomic, strong) NSDate *minimumDate;
@property (nullable, nonatomic, strong) NSDate *maximumDate;

@end


NS_ASSUME_NONNULL_END
