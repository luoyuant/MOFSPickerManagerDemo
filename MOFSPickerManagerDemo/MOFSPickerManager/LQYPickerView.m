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

@synthesize selectedJson = _selectedJson;

#pragma mark - setter

- (void)setParentView:(UIView *)parentView {
    _parentView = parentView;
    if (_parentView) {
        [self updateFrame];
    }
}

- (void)setDataKeys:(NSDictionary<NSNumber *,NSString *> *)dataKeys {
    _dataKeys = dataKeys;
    [_dataKeys enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        self.selectedJson[key] = @0;
    }];
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadAllComponents];
    });
}

#pragma mark - getter

- (NSMutableDictionary<NSNumber *, NSNumber *> *)selectedJson {
    if (!_selectedJson) {
        _selectedJson = [NSMutableDictionary dictionary];
    }
    return _selectedJson;
}

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
                    NSInteger row = [weakSelf.selectedJson[@(component)] integerValue];
                    if (weakSelf.isDynamic) {
                        id arr = [weakSelf searchArrayForComponent:component];
                        id obj = arr[row];
                        json[@(component)] = obj;
                    } else {
                        if ([weakSelf.dataArray.firstObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = weakSelf.dataArray[component];
                            id obj = arr[row];
                            json[@(component)] = obj;
                        } else {
                            id obj = weakSelf.dataArray[row];
                            json[@(component)] = obj;
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
 * 获取某个component下的 动态 数组
 */
- (nullable NSArray *)searchArrayForComponent:(NSInteger)component {
    if (component == 0) {
        return self.dataArray;
    }
    NSInteger index = 1;
    NSInteger row = [self.selectedJson[@0] integerValue];
    id obj = nil;
    if (row < self.dataArray.count) {
        obj = self.dataArray[row];
        while (index <= component) {
            if (!obj) {
                break;
            }
            row = [self.selectedJson[@(index - 1)] integerValue];
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
        id obj = [self searchArrayForComponent:component];
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
        id arr = [self searchArrayForComponent:component];
        id obj = arr[row];
        return [self getTextForComponent:component object:obj];
    } else {
        if ([self.dataArray.firstObject isKindOfClass:[NSArray class]]) {
            NSArray *arr = self.dataArray[component];
            id obj = arr[row];
            return [self getTextForComponent:component object:obj];
        } else {
            id obj = self.dataArray[row];
            return [self getTextForComponent:component object:obj];
        }
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
    self.selectedJson[@(component)] = @(row);
    if (_isDynamic) {
        if (component < _numberOfSection - 1) {
            for (NSInteger i = component + 1; i < _numberOfSection; i++) {
                self.selectedJson[@(i)] = @0;
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
            
            NSMutableArray<NSString *> *minimumMonthArr = [NSMutableArray array];
            for (NSInteger i = minimumMonth; i <= 12; i++) {
                [minimumMonthArr addObject:[NSString stringWithFormat:@"%ld月", i]];
            }
            
            NSMutableArray<NSString *> *maximumMonthArr = [NSMutableArray array];
            for (NSInteger i = 1; i <= maximumMonth; i++) {
                [maximumMonthArr addObject:[NSString stringWithFormat:@"%ld月", i]];
            }
            
            NSMutableArray<NSString *> *fullMonthArr = [NSMutableArray array];
            for (NSInteger i = 1; i <= 12; i++) {
                [fullMonthArr addObject:[NSString stringWithFormat:@"%ld月", i]];
            }
            
            for (NSInteger year = minimumYear; year <= maximumYear; year++) {
                NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:@{@"name" : [NSString stringWithFormat:@"%ld年", year], @"months" : fullMonthArr}];
                if (year == minimumYear) {
                    json[@"months"] = maximumMonthArr;
                } else if (year == maximumYear) {
                    json[@"months"] = maximumMonthArr;
                }
                [arr addObject:json];
            }
            
            self.dataArray = arr;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadAllComponents];
            });
            
        });
        
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedJson[@(component)] = @(row);
    if (self.isDynamic) {
        if (component < self.numberOfSection - 1) {
            for (NSInteger i = component + 1; i < self.numberOfSection; i++) {
                NSInteger selectedRow = [self.selectedJson[@(i)] integerValue];
                [pickerView reloadComponent:i];
                NSInteger numberOfRows = [self numberOfRowsInComponent:i];
                if (selectedRow >= numberOfRows) {
                    NSInteger index = numberOfRows - 1;
                    self.selectedJson[@(i)] = @(index);
                }
                
            }
        }
    }
}


#pragma mark - public method

- (void)show {
    if (!_minimumDate) {
        _minimumDate = [NSDate dateWithTimeIntervalSince1970:0];
    }
    if (!_maximumDate) {
        _maximumDate = [NSDate date];
        [self getDataArray];
    }
    [super show];
}

@end
