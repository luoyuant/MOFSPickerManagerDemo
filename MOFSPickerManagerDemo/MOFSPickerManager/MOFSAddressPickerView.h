//
//  MOFSAddressPickerView.h
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/31.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolView.h"
#import "MOFSAddressModel.h"

typedef NS_ENUM(NSInteger, MOFSAddressSearchType) {
    MOFSAddressSearchTypeByAddress = 0, //根据地址，查询其他信息
    MOFSAddressSearchTypeByZipcode = 1, //根据zipcode，查询其他信息
    MOFSAddressSearchTypeByIndex   = 2, //根据下标，查询其他信息
};

@interface MOFSAddressPickerView : UIPickerView

@property (nullable, nonatomic, readonly) NSMutableArray<MOFSAddressModel *> *addressDataArray;

@property (nullable, nonatomic, strong) MOFSToolView *toolBar;
@property (nullable, nonatomic, strong) UIView *containerView;
@property (nullable, nonatomic, strong) void (^containerViewClickedBlock)(void);
@property (nonatomic, assign) NSInteger numberOfSection;
@property (nonatomic, assign) BOOL usedXML;

@property (nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *attributes;


/**
 * 显示选择器
 * @param title 选择器toolBar中间标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 */
- (void)showWithTitle:(NSString * _Nullable)title
          commitTitle:(NSString * _Nullable)commitTitle
          cancelTitle:(NSString * _Nullable)cancelTitle
          commitBlock:(void(^ _Nullable)(MOFSAddressSelectedModel * _Nullable selectedModel))commitBlock
          cancelBlock:(void(^_Nullable)(void))cancelBlock;

/**
 * 显示选择器
 * @param selectedAddress 默认选中的地址
 * @param title 选择器toolBar中间标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 */
- (void)showWithSelectedAddress:(MOFSAddressSelectedModel * _Nullable)selectedAddress
                          title:(NSString * _Nullable)title
                    commitTitle:(NSString * _Nullable)commitTitle
                    cancelTitle:(NSString * _Nullable)cancelTitle
                    commitBlock:(void(^ _Nullable)(MOFSAddressSelectedModel * _Nullable selectedModel))commitBlock
                    cancelBlock:(void(^_Nullable)(void))cancelBlock;

/**
 * 显示选择器
 * @param selectedZipcode 默认选中的地址代码
 * @param title 选择器toolBar中间标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 */
- (void)showWithSelectedZipcode:(MOFSAddressSelectedModel * _Nullable)selectedZipcode
                          title:(NSString * _Nullable)title
                    commitTitle:(NSString * _Nullable)commitTitle
                    cancelTitle:(NSString * _Nullable)cancelTitle
                    commitBlock:(void(^ _Nullable)(MOFSAddressSelectedModel * _Nullable selectedModel))commitBlock
                    cancelBlock:(void(^_Nullable)(void))cancelBlock;


- (void)searchType:(MOFSAddressSearchType)searchType keyModel:(MOFSAddressSelectedModel *_Nullable)keyModel block:(void(^_Nullable)(MOFSSearchAddressModel * _Nullable result))block;

@end
