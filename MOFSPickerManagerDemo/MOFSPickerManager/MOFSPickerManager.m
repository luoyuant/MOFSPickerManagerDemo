//
//  MOFSPickerManager.m
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/26.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import "MOFSPickerManager.h"

@implementation MOFSPickerManager

+ (MOFSPickerManager *)shareManger {
    static MOFSPickerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return  manager;
}

- (MOFSDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [MOFSDatePicker new];
    }
    return _datePicker;
}

- (MOFSPickerView *)pickView {
    if (!_pickView) {
        _pickView = [MOFSPickerView new];
    }
    return _pickView;
}

- (MOFSAddressPickerView *)addressPicker {
    if (!_addressPicker) {
        _addressPicker = [MOFSAddressPickerView new];
    }
    return _addressPicker;
}

- (LQYDatePickerView *)lqyDatePicker {
    if (!_lqyDatePicker) {
        _lqyDatePicker = [LQYDatePickerView new];
    }
    return _lqyDatePicker;
}

@end
