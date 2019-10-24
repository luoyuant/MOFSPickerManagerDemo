//
//  LQYPickerView.m
//  MOFSPickerManagerDemo
//
//  Created by luoyuan on 2019/10/22.
//  Copyright © 2019 luoyuan. All rights reserved.
//

#import "LQYPickerView.h"

@implementation LQYPickerViewLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _height = 216;
        _toolBarHeight = 44;
    }
    return self;
}

@end


@interface LQYPickerView () <UIPickerViewDelegate,UIPickerViewDataSource>

@end

@implementation LQYPickerView

#pragma mark - setter

- (void)setParentView:(UIView *)parentView {
    _parentView = parentView;
    if (_parentView) {
        [self updateFrame];
    }
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadAllComponents];
    });
}

#pragma mark - getter

- (LQYPickerViewLayout *)layout {
    if (!_layout) {
        _layout = [LQYPickerViewLayout new];
    }
    return _layout;
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _numberOfSection = 1;
        
        _maskAlpha = 0.4;
        
        _maskView = [UIView new];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:_maskAlpha];
        _maskView.userInteractionEnabled = true;
        [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
        
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor whiteColor];
        [_containerView addSubview:self];
        
        _toolBar = [MOFSToolView new];
        _toolBar.backgroundColor = [UIColor whiteColor];
        [_containerView addSubview:_toolBar];
        __weak typeof(self) weakSelf = self;
        _toolBar.cancelBlock = ^{
            [weakSelf dismiss];
        };
        
        _toolBar.commitBlock = ^{
            [weakSelf dismiss];
    
            if (weakSelf.commitBlock) {
                
                NSMutableDictionary<NSNumber *, id> *json = [NSMutableDictionary dictionary];
                
                NSInteger numberPfComponent = weakSelf.numberOfComponents;;
                
                for (NSInteger component = 0; component < numberPfComponent; component++) {
                    NSInteger row = [weakSelf selectedRowInComponent:component];
                    
                    if (weakSelf.isDynamic) {
                        id arr = [weakSelf getDataArrayForComponent:component];
                        id obj = arr[row];
                        json[@(component)] = @{@"row" : @(row), @"data" : obj};
                    } else {
                        if ([weakSelf.dataArray.firstObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = weakSelf.dataArray[component];
                            id obj = arr[row];
                            json[@(component)] = @{@"row" : @(row), @"data" : obj};
                        } else {
                            id obj = weakSelf.dataArray[row];
                            json[@(component)] = @{@"row" : @(row), @"data" : obj};
                        }
                    }
                }
                
                weakSelf.commitBlock(json);
            }
            
        };
        
        self.delegate = self;
        self.dataSource = self;
        
        //iOS 10及以上需要添加 这一行代码，否则第一次不显示中间两条分割线
        if ([self numberOfRowsInComponent:0] > 0) {}
        
    }
    return self;
}

#pragma mark - update frame

- (void)updateFrame {
    CGRect frame = _parentView.bounds;
    _maskView.frame = frame;
    
    CGRect rect = _containerView.frame;
    rect.origin.x = self.layout.marginLeft;
    rect.size.width = frame.size.width - self.layout.marginLeft - self.layout.marginRight;
    rect.size.height = self.layout.height;
    _containerView.frame = rect;
    
    _toolBar.frame = CGRectMake(0, 0, rect.size.width, self.layout.toolBarHeight);
    
    self.frame = CGRectMake(0, self.layout.toolBarHeight, rect.size.width, rect.size.height - self.layout.toolBarHeight);
    
}

#pragma mark - search data

/**
 * 获取某个component下的 数组
 */
- (nullable NSArray *)getDataArrayForComponent:(NSInteger)component {
    if (_isDynamic) {
        if (component == 0) {
            return self.dataArray;
        }
        NSInteger index = 1;
        NSInteger row = [self selectedRowInComponent:0];
        id obj = nil;
        if (row < self.dataArray.count) {
            obj = self.dataArray[row];
            while (index <= component) {
                if (!obj) {
                    break;
                }
                row = [self selectedRowInComponent:index - 1];
                if ([obj isKindOfClass:[NSArray class]]) {
                    if (row < [obj count]) {
                        obj = obj[row];
                    } else {
                        obj = nil;
                        break;
                    }
                } else if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSObject class]]) {
                    obj = [self getArrayForObject:obj inComponent:(index- 1)];
                    if (!obj) {
                        break;
                    }
                } else {
                    obj = nil;
                    break;
                }
                index++;
            }
        }
        
        if (![obj isKindOfClass:[NSArray class]]) {
            obj = [self getArrayForObject:obj inComponent:component];
        }
        
        return obj;
    } else {
        if ([self.dataArray.firstObject isKindOfClass:[NSArray class]]) {
            if (component < self.dataArray.count) {
                NSArray *arr = self.dataArray[component];
                return arr;
            }
            return nil;
        } else {
            return self.dataArray;
        }
    }
    
}

- (nullable NSArray *)getArrayForObject:(id)obj inComponent:(NSInteger)component {
    if (!obj) {
        return nil;
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    id result;
    NSString *key = self.dataKeys ? self.dataKeys[@(component)] : nil;
    if (!key) {
        key = self.dataKeys[@(0)];
    }
    if (key) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            result = obj[key];
        } else if ([obj isKindOfClass:[NSObject class]]) {
            result = [obj valueForKey:key];
        }
    } else {
        result = nil;
    }
    return result;
}

/**
 * 获取某个 component 下的 obj的 文字内容
 */
- (nullable NSString *)getTextForComponent:(NSInteger)component object:(id)object {
    NSString *text;
    
    if ([object isKindOfClass:[NSString class]]) {
        text = object;
    } else if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSObject class]]) {
        NSString *key = self.dataTextKeys ? self.dataTextKeys[@(component)] : nil;
        if (!key) {
            key = self.dataTextKeys[@0];
        }
        if (key) {
            if ([object isKindOfClass:[NSDictionary class]]) {
                text = object[key];
            } else {
                text = [object valueForKey:key];
            }
        } else {
            text = @"undefined";
        }
    } else {
        text = @"undefined";
    }
    
    return [text isKindOfClass:[NSString class]] ? text : @"undefined";
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _isDynamic ? _numberOfSection : ([self.dataArray.firstObject isKindOfClass:[NSArray class]] ? self.dataArray.count : 1);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (_isDynamic) {
        id obj = [self getDataArrayForComponent:component];
        return [obj isKindOfClass:[NSArray class]] ? [obj count] : 0;
    } else {
        id obj = self.dataArray[component];
        if ([obj isKindOfClass:[NSArray class]]) {
            return [obj count];
        } else if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSObject class]]) {
            return self.dataArray.count;
        } else {
            return 0;
        }
    }
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (_isDynamic) {
        id arr = [self getDataArrayForComponent:component];
        id obj = arr[row];
        return [self getTextForComponent:component object:obj];
    } else {
        NSArray *arr = [self getDataArrayForComponent:component];
        if (row < arr.count) {
            id obj = arr[row];
            return [self getTextForComponent:component object:obj];
        } else {
            return @"undefined";
        }
//        if ([self.dataArray.firstObject isKindOfClass:[NSArray class]]) {
//            NSArray *arr = self.dataArray[component];
//            id obj = arr[row];
//            return [self getTextForComponent:component object:obj];
//        } else {
//            id obj = self.dataArray[row];
//            return [self getTextForComponent:component object:obj];
//        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.font = [UIFont systemFontOfSize:16];
        pickerLabel.textColor = [UIColor blackColor];
    }
    
    NSString *text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    pickerLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:_textAttributes];
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_isDynamic) {
        if (component < _numberOfSection - 1) {
            for (NSInteger i = component + 1; i < _numberOfSection; i++) {
                [pickerView reloadComponent:i];
                [pickerView selectRow:0 inComponent:i animated:false];
            }
        }
    }
}

- (void)show {
    
    if (!_parentView) {
        self.parentView = [UIApplication sharedApplication].keyWindow;
    }
    
    [self updateFrame];
    
    [self.parentView addSubview:_maskView];
    [self.parentView addSubview:_containerView];
    
    CGFloat height = self.parentView.frame.size.height;
    
    __block CGRect frame = _containerView.frame;
    frame.origin.y = height;
    _containerView.frame = frame;
    _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    
    [UIView animateWithDuration:0.3 animations:^{
        frame.origin.y = height - self.containerView.frame.size.height - self.layout.marginBottom;
        self.containerView.frame = frame;
        self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:self.maskAlpha];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)dismiss {
    CGFloat height = self.parentView.frame.size.height;
    __block CGRect frame = _containerView.frame;
    frame.origin.y = height;
    [UIView animateWithDuration:0.3 animations:^{
        self.containerView.frame = frame;
        self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self.containerView removeFromSuperview];
    }];
}

@end



@interface LQYYearAndMonthPickerView ()

@property (nonatomic, strong) NSMutableArray *minimumMonthArr;
@property (nonatomic, strong) NSMutableArray *maximumMonthArr;
@property (nonatomic, strong) NSMutableArray *fullMonthArr;

@property (nonatomic, strong) NSDictionary *selectedMonth;

@end

@implementation LQYYearAndMonthPickerView

#pragma mark - setter

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate;
    [self getDataArray];
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    _maximumDate = maximumDate;
    [self getDataArray];
}

#pragma mark - getter

- (NSMutableArray *)fullMonthArr {
    if (!_fullMonthArr) {
        _fullMonthArr = [NSMutableArray array];
        for (NSInteger i = 1; i <= 12; i++) {
            [_fullMonthArr addObject:@{@"name" : [NSString stringWithFormat:@"%ld月", i], @"value" : @(i)}];
        }
    }
    return _fullMonthArr;
}

#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isDynamic = true;
        self.dataKeys = @{@0 : @"months"};
        self.dataTextKeys = @{@0 : @"name"};
        self.numberOfSection = 2;
    }
    return self;
}

#pragma mark - get data

- (void)getDataArray {
    if (_minimumDate && _maximumDate) {
        NSComparisonResult result = [_minimumDate compare:_maximumDate];
        if (result != NSOrderedAscending) {
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDateFormatter *df = [NSDateFormatter new];
            df.dateFormat = @"yyyy-M";
            
            NSString *minimumDateStr = [df stringFromDate:self->_minimumDate];
            NSString *maximumDateStr = [df stringFromDate:self->_maximumDate];
            
            NSArray<NSString *> *minimumDateArr = [minimumDateStr componentsSeparatedByString:@"-"];
            NSArray<NSString *> *maximumDateArr = [maximumDateStr componentsSeparatedByString:@"-"];
            
            NSInteger minimumYear = [minimumDateArr.firstObject integerValue];
            NSInteger minimumMonth = [minimumDateArr.lastObject integerValue];
            
            NSInteger maximumYear = [maximumDateArr.firstObject integerValue];
            NSInteger maximumMonth = [maximumDateArr.lastObject integerValue];
            
            NSMutableArray *arr = [NSMutableArray array];
            
            self.minimumMonthArr = [NSMutableArray array];
            for (NSInteger i = minimumMonth; i <= 12; i++) {
                [self.minimumMonthArr addObject:@{@"name" : [NSString stringWithFormat:@"%ld月", i], @"value" : @(i)}];
            }
            
            self.maximumMonthArr = [NSMutableArray array];
            for (NSInteger i = 1; i <= maximumMonth; i++) {
                [self.maximumMonthArr addObject:@{@"name" : [NSString stringWithFormat:@"%ld月", i], @"value" : @(i)}];
            }
            
            for (NSInteger year = minimumYear; year <= maximumYear; year++) {
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : [NSString stringWithFormat:@"%ld年", year], @"value" : @(year), @"months" : self.fullMonthArr}];
                if (year == minimumYear) {
                    json[@"months"] = self.minimumMonthArr;
                } else if (year == maximumYear) {
                    json[@"months"] = self.maximumMonthArr;
                }
                [arr addObject:json];
            }
            
            self.dataArray = arr;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadAllComponents];
                [self selectRow:([self numberOfRowsInComponent:0] - 1) inComponent:0 animated:false];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self reloadComponent:1];
                    [self selectRow:([self numberOfRowsInComponent:1] - 1) inComponent:1 animated:false];
                    self.selectedMonth = self.maximumMonthArr.lastObject;
                });
            });
            
        });
        
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [pickerView reloadComponent:1];
        NSArray *arr = [self getDataArrayForComponent:1];
        NSInteger selectedRow = [self selectedRowInComponent:1];
        NSDictionary *selectedMonth = arr.lastObject;
        if (selectedRow < arr.count) {
            selectedMonth = arr[selectedRow];
        }
        NSNumber *oldValue = _selectedMonth[@"value"];
        NSNumber *newValue = selectedMonth[@"value"];
        if (![newValue isEqualToNumber:oldValue]) {
            NSArray *filterArr = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self.value == %@", oldValue]]];
            if (filterArr.firstObject) {
                NSInteger index = [arr indexOfObject:filterArr.firstObject];
                [self selectRow:index inComponent:1 animated:false];
            } else {
                _selectedMonth = selectedMonth;
            }
        }
        
    } else {
        NSArray *arr = [self getDataArrayForComponent:1];
        if (row < arr.count) {
            _selectedMonth = arr[row];
        }
    }
    
}


#pragma mark - public method

- (void)show {
    if (!_minimumDate) {
        self.minimumDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    if (!_maximumDate) {
        self.maximumDate = [NSDate date];
    }
    [super show];
}

@end
