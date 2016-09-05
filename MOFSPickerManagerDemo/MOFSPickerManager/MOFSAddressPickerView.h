//
//  MOFSAddressPickerView.h
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/31.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOFSToolbar.h"
#import "AddressModel.h"

typedef NS_ENUM(NSInteger, SearchType) {
    SearchTypeAddress = 0,
    SearchTypeZipcode
};

@interface MOFSAddressPickerView : UIPickerView

@property (nonatomic, assign) NSInteger showTag;
@property (nonatomic, strong) MOFSToolbar *toolBar;
@property (nonatomic, strong) UIView *containerView;

- (void)showMOFSAddressPickerCommitBlock:(void(^)(NSString *address, NSString *zipcode))commitBlock cancelBlock:(void(^)())cancelBlock;

- (void)searchType:(SearchType)searchType key:(NSString *)key block:(void(^)(NSString *result))block;

@end
