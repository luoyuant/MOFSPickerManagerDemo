//
//  MOFSToolView.h
//  MOFSPickerManagerDemo
//
//  Created by luoyuan on 2018/2/5.
//  Copyright © 2018年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSAddressModel.h"

@interface MOFSToolView : UIView

@property (nonatomic, strong) UILabel *cancelBar;
@property (nonatomic, strong) UILabel *commitBar;
@property (nonatomic, strong) UILabel *titleBar;

/**
 default Title: "取消"
 */
@property (nonatomic, strong) NSString *cancelBarTitle;

/**
 default Color: [UIColor colorWithRed:0.090  green:0.463  blue:0.906 alpha:1]
 */
@property (nonatomic, strong) UIColor *cancelBarTintColor;

/**
 default Title: "确定"
 */
@property (nonatomic, strong) NSString *commitBarTitle;

/**
 default Color: [UIColor colorWithRed:0.090  green:0.463  blue:0.906 alpha:1]
 */
@property (nonatomic, strong) UIColor *commitBarTintColor;

/**
 default Title: ""
 */
@property (nonatomic, strong) NSString *titleBarTitle;

/**
 default Color: [UIColor colorWithRed:0.804  green:0.804  blue:0.804 alpha:1]
 */
@property (nonatomic, strong) UIColor *titleBarTextColor;

@end


@interface MOFSPickerDelegateObject : NSObject

@property (nonatomic, copy) void (^cancelBlock)(void);

@property (nonatomic, copy) void (^commitDateBlock)(NSDate *date);
@property (nonatomic, copy) void (^commitAddressBlock)(MOFSAddressSelectedModel *selectedModel);
@property (nonatomic, copy) void (^commitPickerBlock)(id obj);
@property (nonatomic, copy) void (^commitLYQDateBlock)(NSDateComponents *dateComponents);

/**
 * 日期
 */
+ (instancetype)initWithCancelBlock:(void(^)(void))cancelBlock commitDateBlock:(void (^)(NSDate * date))commitBlock;

/**
 * 地址
 */
+ (instancetype)initWithCancelBlock:(void(^)(void))cancelBlock commitAddressBlock:(void (^)(MOFSAddressSelectedModel *selectedModel))commitBlock;

/**
 * 普通选择器
 */
+ (instancetype)initWithCancelBlock:(void(^)(void))cancelBlock commitPickerBlock:(void (^)(id obj))commitBlock;

+ (instancetype)initWithCancelBlock:(void(^)(void))cancelBlock commitLQYDateBlock:(void (^)(NSDateComponents *dateComponents))commitBlock;

@end
