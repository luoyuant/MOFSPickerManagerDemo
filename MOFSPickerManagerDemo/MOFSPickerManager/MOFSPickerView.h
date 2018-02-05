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

@property (nonatomic, assign) NSInteger showTag;
@property (nonatomic, strong) MOFSToolView *toolBar;
@property (nonatomic, strong) UIView *containerView;

- (void)showMOFSPickerViewWithDataArray:(NSArray *)array commitBlock:(void(^)(NSString *string))commitBlock cancelBlock:(void(^)(void))cancelBlock;

@end
