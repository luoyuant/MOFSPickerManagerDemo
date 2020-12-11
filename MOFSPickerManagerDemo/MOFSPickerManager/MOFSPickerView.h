//
//  MOFSPickerView.h
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/30.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolView.h"

@interface MOFSPickerView : UIPickerView

@property (nullable, nonatomic, strong) MOFSToolView *toolBar;
@property (nullable, nonatomic, strong) UIView *containerView;
@property (nullable, nonatomic, strong) void (^containerViewClickedBlock)(void);

@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *attributes;

/**
 * 显示选择器
 * @param array 字符数组
 * @param title 标题
 */
- (void)showWithDataArray:(NSArray<NSString *> * _Nonnull)array
                    title:(NSString * _Nullable)title
              commitBlock:(void(^ _Nullable)(id _Nullable model))commitBlock
              cancelBlock:(void(^ _Nullable)(void))cancelBlock;

/**
 * 显示选择器
 * @param array 数据源数组
 * @param title 标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 */
- (void)showWithDataArray:(NSArray<NSString *> * _Nonnull)array
                    title:(NSString * _Nullable)title
              commitTitle:(NSString * _Nullable)commitTitle
              cancelTitle:(NSString * _Nullable)cancelTitle
              commitBlock:(void(^ _Nullable)(id _Nullable model))commitBlock
              cancelBlock:(void(^ _Nullable)(void))cancelBlock;

/**
 * 显示选择器
 * @param array 数据源数组
 * @param keyMapper 数据源中的Model或者JSON对应的key
 * @param title 标题
 */
- (void)showWithDataArray:(NSArray * _Nonnull)array
                keyMapper:(NSString * _Nullable)keyMapper
                    title:(NSString * _Nullable)title
              commitBlock:(void(^ _Nullable)(id _Nullable model))commitBlock
              cancelBlock:(void(^ _Nullable)(void))cancelBlock;

/**
 * 显示选择器
 * @param array 数据源数组
 * @param keyMapper 数据源中的Model或者JSON对应的key
 * @param title 标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 */
- (void)showWithDataArray:(NSArray * _Nonnull)array
                keyMapper:(NSString * _Nullable)keyMapper
                    title:(NSString * _Nullable)title
              commitTitle:(NSString * _Nullable)commitTitle
              cancelTitle:(NSString * _Nullable)cancelTitle
              commitBlock:(void(^ _Nullable)(id _Nullable model))commitBlock
              cancelBlock:(void(^ _Nullable)(void))cancelBlock;


@end


