//
//  MOFSPickerManager.h
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/26.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MOFSDatePicker.h"
#import "MOFSPickerView.h"
#import "MOFSAddressPickerView.h"
#import "LQYPickerView.h"

@interface MOFSPickerManager : NSObject

+ (MOFSPickerManager *_Nonnull)shareManger;

@property (nonnull, nonatomic, strong) MOFSDatePicker *datePicker;

@property (nonnull, nonatomic, strong) MOFSPickerView *pickView;

@property (nonnull, nonatomic, strong) MOFSAddressPickerView *addressPicker;

@property (nonnull, nonatomic, strong) LQYDatePickerView *lqyDatePicker;


@end
