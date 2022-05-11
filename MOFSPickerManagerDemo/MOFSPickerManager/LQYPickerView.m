//
//  LQYPickerView.m
//  MOFSPickerManager
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


@interface LQYPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

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

- (NSString *)objectPointer {
    return [NSString stringWithFormat:@"%p", self];
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
        
        _toolBar = [MOFSToolView new];
        _toolBar.backgroundColor = [UIColor whiteColor];
        [_containerView addSubview:_toolBar];
        
        [_toolBar.cancelBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)]];
        [_toolBar.commitBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commitAction)]];
        
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

#pragma mark - ToolBar Action

- (void)cancelAction {
    [self dismiss];
}

- (void)commitAction {
    [self dismiss];

    if (self.commitBlock) {
        
        NSMutableDictionary<NSNumber *, id> *json = [NSMutableDictionary dictionary];
        
        NSInteger numberPfComponent = self.numberOfComponents;;
        
        for (NSInteger component = 0; component < numberPfComponent; component++) {
            NSInteger row = [self selectedRowInComponent:component];
            
            if (self.isDynamic) {
                id arr = [self getDataArrayForComponent:component];
                id obj = arr[row];
                json[@(component)] = @{@"row" : @(row), @"data" : obj};
            } else {
                if ([self.dataArray.firstObject isKindOfClass:[NSArray class]]) {
                    NSArray *arr = self.dataArray[component];
                    id obj = arr[row];
                    json[@(component)] = @{@"row" : @(row), @"data" : obj};
                } else {
                    id obj = self.dataArray[row];
                    json[@(component)] = @{@"row" : @(row), @"data" : obj};
                }
            }
        }
        
        self.commitBlock(json);
    }
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
                        obj = [obj firstObject];
                        break;
                    }
                } else if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSObject class]]) {
                    obj = [self getArrayForObject:obj inComponent:index - 1];
                    if (!obj) {
                        break;
                    }
                } else {
                    obj = nil;
                    break;
                }
                if (![obj isKindOfClass:[NSArray class]]) {
                    obj = [self getArrayForObject:obj inComponent:index];
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
- (nullable NSString *)textForComponent:(NSInteger)component object:(id)object {
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
        return [self textForComponent:component object:obj];
    } else {
        NSArray *arr = [self getDataArrayForComponent:component];
        if (row < arr.count) {
            id obj = arr[row];
            return [self textForComponent:component object:obj];
        } else {
            return @"undefined";
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
    
    [_containerView addSubview:self];
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
        [self removeFromSuperview];
        [self.maskView removeFromSuperview];
        [self.containerView removeFromSuperview];
    }];
}

#pragma mark - Dealloc

- (void)dealloc {
    
}

@end

@interface LQYDatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<NSNumber *> *> *dataJson;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *months;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *days_28;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *days_29;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *days_30;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *days_31;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *hours;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *minutes;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *seconds;
@property (nonatomic, strong) NSDictionary<NSNumber*, NSDictionary<NSString *, NSString *> *> *filterJson;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, NSString *> *> *dateFormatJson;

@property (nonatomic, strong) NSCalendar *calendar;
//@property (nonatomic, strong) NSDateComponents *dateComponents;
@property (nonatomic, strong) NSDateComponents *minComponents;
@property (nonatomic, strong) NSDateComponents *maxComponents;
@property (nonatomic, strong) NSArray<NSNumber *> *unitFlags;
@property (nonatomic, strong) NSArray<NSString *> *dateComponentKeys;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MOFSPickerDelegateObject *> *delegatesDict;
@property (readwrite, nonatomic, strong) NSLock *lock;

@end

const NSString *LQYFormatTypeBeforeKey = @"LQYFormatTypeBeforeKey";
const NSString *LQYFormatTypeAfterKey = @"LQYFormatTypeAfterKey";

@implementation LQYDatePickerView

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

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
        _lock.name = @"com.ly.datePicker.lock";
    }
    return _lock;
}

- (NSMutableDictionary<NSString *, MOFSPickerDelegateObject *> *)delegatesDict {
    if (!_delegatesDict) {
        _delegatesDict = [NSMutableDictionary dictionary];
    }
    return _delegatesDict;
}

- (NSMutableDictionary<NSString *, NSMutableArray<NSNumber *> *> *)dataJson {
    if (!_dataJson) {
        _dataJson = [NSMutableDictionary dictionary];
    }
    return _dataJson;
}

- (NSMutableArray<NSNumber *> *)months {
    if (!_months) {
        _months = [NSMutableArray array];
        for (NSInteger month = 1; month <= 12; month++) {
            [_months addObject:@(month)];
        }
    }
    return _months;
}

- (NSMutableArray<NSNumber *> *)days_28 {
    if (!_days_28) {
        _days_28 = [NSMutableArray array];
        for (NSInteger day = 1; day <= 28; day++) {
            [_days_28 addObject:@(day)];
        }
    }
    return _days_28;
}

- (NSMutableArray<NSNumber *> *)days_29 {
    if (!_days_29) {
        _days_29 = [NSMutableArray array];
        for (NSInteger day = 1; day <= 29; day++) {
            [_days_29 addObject:@(day)];
        }
    }
    return _days_29;
}

- (NSMutableArray<NSNumber *> *)days_30 {
    if (!_days_30) {
        _days_30 = [NSMutableArray array];
        for (NSInteger day = 1; day <= 30; day++) {
            [_days_30 addObject:@(day)];
        }
    }
    return _days_30;
}

- (NSMutableArray<NSNumber *> *)days_31 {
    if (!_days_31) {
        _days_31 = [NSMutableArray array];
        for (NSInteger day = 1; day <= 31; day++) {
            [_days_31 addObject:@(day)];
        }
    }
    return _days_31;
}

- (NSMutableArray<NSNumber *> *)hours {
    if (!_hours) {
        _hours = [NSMutableArray array];
        for (NSInteger hour = 0; hour < 24; hour++) {
            [_hours addObject:@(hour)];
        }
    }
    return _hours;
}

- (NSMutableArray<NSNumber *> *)minutes {
    if (!_minutes) {
        _minutes = [NSMutableArray array];
        for (NSInteger minute = 0; minute < 60; minute++) {
            [_minutes addObject:@(minute)];
        }
    }
    return _minutes;
}

- (NSMutableArray<NSNumber *> *)seconds {
    if (!_seconds) {
        _seconds = [NSMutableArray array];
        for (NSInteger second = 0; second < 60; second++) {
            [_seconds addObject:@(second)];
        }
    }
    return _seconds;
}

- (NSDictionary<NSNumber*, NSDictionary<NSString *, NSString *> *> *)filterJson {
    if (!_filterJson) {
        _filterJson = @{@(LQYDateComponentMonth) : @{@"min" : @"minMonths", @"max" : @"maxMonths"},
                        @(LQYDateComponentDay) : @{@"min" : @"minDays", @"max" : @"maxDays"},
                        @(LQYDateComponentHour) : @{@"min" : @"minHours", @"max" : @"maxHours"},
                        @(LQYDateComponentMinute) : @{@"min" : @"minMinutes", @"max" : @"maxMinutes"},
                        @(LQYDateComponentSecond) : @{@"min" : @"minSeconds", @"max" : @"maxSeconds"}
        };
    }
    return _filterJson;
}

- (NSMutableDictionary<NSNumber *, NSMutableDictionary<NSString *, NSString *> *> *)dateFormatJson {
    if (!_dateFormatJson) {
        NSMutableDictionary<NSString *, NSString *> *yearDict = [NSMutableDictionary dictionaryWithObject:@"年" forKey:LQYFormatTypeAfterKey];
        NSMutableDictionary<NSString *, NSString *> *monthDict = [NSMutableDictionary dictionaryWithObject:@"月" forKey:LQYFormatTypeAfterKey];
        NSMutableDictionary<NSString *, NSString *> *dayDict = [NSMutableDictionary dictionaryWithObject:@"日" forKey:LQYFormatTypeAfterKey];
        NSMutableDictionary<NSString *, NSString *> *hourDict = [NSMutableDictionary dictionaryWithObject:@"点" forKey:LQYFormatTypeAfterKey];
        NSMutableDictionary<NSString *, NSString *> *minuteyDict = [NSMutableDictionary dictionaryWithObject:@"分" forKey:LQYFormatTypeAfterKey];
        NSMutableDictionary<NSString *, NSString *> *secondDict = [NSMutableDictionary dictionaryWithObject:@"秒" forKey:LQYFormatTypeAfterKey];
        
        _dateFormatJson = [[NSMutableDictionary alloc] initWithDictionary:@{@(LQYDateComponentYear) : yearDict,
                                @(LQYDateComponentMonth) : monthDict,
                                @(LQYDateComponentDay) : dayDict,
                                @(LQYDateComponentHour) : hourDict,
                                @(LQYDateComponentMinute) : minuteyDict,
                                @(LQYDateComponentSecond) : secondDict
        }];
    }
    return _dateFormatJson;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (NSArray<NSNumber *> *)unitFlags {
    if (!_unitFlags) {
        _unitFlags = @[@(NSCalendarUnitYear),
                       @(NSCalendarUnitMonth),
                       @(NSCalendarUnitDay),
                       @(NSCalendarUnitHour),
                       @(NSCalendarUnitMinute),
                       @(NSCalendarUnitSecond)];
    }
    return _unitFlags;
}

- (NSArray<NSString *> *)dateComponentKeys {
    if (!_dateComponentKeys) {
        _dateComponentKeys = @[@"year", @"month", @"day", @"hour", @"minute", @"second"];
    }
    return _dateComponentKeys;
}


#pragma mark - init

- (instancetype)init {
    self = [super init];
    if (self) {
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-MM-dd";
        _minimumDate = [df dateFromString:@"2000-01-01"];
        _maximumDate = [NSDate date];
        _minimumComponent = LQYDateComponentYear;
        _maximumComponent = LQYDateComponentDay;
        
        [self.toolBar.cancelBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)]];
        [self.toolBar.commitBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commitAction)]];
        
        [self getDataArray];
    }
    return self;
}

#pragma mark - ToolBar Action

- (void)cancelAction {
    [self dismiss];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
    
    MOFSPickerDelegateObject *delegate = self.delegatesDict[self.objectPointer];
    if (delegate) {
        if (delegate.cancelBlock) {
            delegate.cancelBlock();
        }
        [self removeDelegate:delegate];
    }
    
}

- (void)commitAction {
    [self dismiss];
    if (self.dateCommitBlock) {
        self.dateCommitBlock([self dateComponentsInComponent:self.numberOfSection - 1]);
    }
    
    MOFSPickerDelegateObject *delegate = self.delegatesDict[self.objectPointer];
    if (delegate) {
        if (delegate.commitLYQDateBlock) {
            delegate.commitLYQDateBlock([self dateComponentsInComponent:self.numberOfSection - 1]);
        }
        [self removeDelegate:delegate];
    }
}

#pragma mark - get data

- (void)getDataArray {
    if (_minimumDate && _maximumDate) {
        NSComparisonResult result = [_minimumDate compare:_maximumDate];
        if (result != NSOrderedAscending) {
            return;
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            if (self.minimumComponent > self.maximumComponent) {
                self.minimumComponent = LQYDateComponentYear;
                self.maximumComponent = LQYDateComponentSecond;
            }
            
            self.numberOfSection = self.maximumComponent - self.minimumComponent + 1;
            
//            废弃（耗性能）
//            NSMutableArray *arr = [NSMutableArray array];
//            NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
//            NSDateComponents *minComponents = [self.calendar components:unitFlags fromDate:self.minimumDate];
//            NSDateComponents *maxComponents = [self.calendar components:unitFlags fromDate:self.maximumDate];
//            switch (self.minimumComponent) {
//                case LQYDateComponentMonth:
//                    maxComponents.year = minComponents.year;
//                    break;
//                case LQYDateComponentDay:
//                    maxComponents.year = minComponents.year;
//                    maxComponents.month = minComponents.month;
//                    break;
//                case LQYDateComponentHour:
//                    maxComponents.year = minComponents.year;
//                    maxComponents.month = minComponents.month;
//                    maxComponents.day = minComponents.day;
//                    break;
//                case LQYDateComponentMinute:
//                    maxComponents.year = minComponents.year;
//                    maxComponents.month = minComponents.month;
//                    maxComponents.day = minComponents.day;
//                    maxComponents.hour = minComponents.hour;
//                    break;
//                case LQYDateComponentSecond:
//                    maxComponents.year = minComponents.year;
//                    maxComponents.month = minComponents.month;
//                    maxComponents.day = minComponents.day;
//                    maxComponents.hour = minComponents.hour;
//                    maxComponents.minute = minComponents.minute;
//                    break;
//                default:
//                    break;
//            }
//            /**
//             * 数据格式: @[{@"name" : "2019" : list: @[@{@"name" : @"1"}]}]
//             */
//            [self handleData:arr minComponents:minComponents maxComponents:maxComponents components:[NSDateComponents new] currentComponent:self.minimumComponent dataDict:nil];
//            self.dataArray = arr;
            
            NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;

            self.minComponents = [self.calendar components:unitFlags fromDate:self.minimumDate];
            self.maxComponents = [self.calendar components:unitFlags fromDate:self.maximumDate];
            
            NSDateComponents *minComponents = [self.calendar components:unitFlags fromDate:self.minimumDate];
            NSDateComponents *maxComponents = [self.calendar components:unitFlags fromDate:self.maximumDate];

            switch (self.minimumComponent) {
                case LQYDateComponentMonth:
                    maxComponents.year = minComponents.year;
                    break;
                case LQYDateComponentDay:
                    maxComponents.year = minComponents.year;
                    maxComponents.month = minComponents.month;
                    break;
                case LQYDateComponentHour:
                    maxComponents.year = minComponents.year;
                    maxComponents.month = minComponents.month;
                    maxComponents.day = minComponents.day;
                    break;
                case LQYDateComponentMinute:
                    maxComponents.year = minComponents.year;
                    maxComponents.month = minComponents.month;
                    maxComponents.day = minComponents.day;
                    maxComponents.hour = minComponents.hour;
                    break;
                case LQYDateComponentSecond:
                    maxComponents.year = minComponents.year;
                    maxComponents.month = minComponents.month;
                    maxComponents.day = minComponents.day;
                    maxComponents.hour = minComponents.hour;
                    maxComponents.minute = minComponents.minute;
                    break;
                default:
                    break;
            }
            
            [self.dataJson removeAllObjects];
            
            //年份
            NSMutableArray<NSNumber *> *years = [NSMutableArray array];
            for (NSInteger year = minComponents.year; year <= maxComponents.year; year++) {
                [years addObject:@(year)];
            }
            [self.dataJson setValue:years forKey:@"years"];
            
            for (NSNumber *component in self.filterJson) {
                LQYDateComponent currentComponent = component.unsignedIntegerValue;
                NSString *minKey = self.filterJson[component][@"min"];
                NSString *maxKey = self.filterJson[component][@"max"];
                NSMutableArray<NSNumber *> *minArr = [self getLimitDataForCurrentComponent:currentComponent components:minComponents isMinimum:true];
                NSMutableArray<NSNumber *> *maxArr = [self getLimitDataForCurrentComponent:currentComponent components:maxComponents isMinimum:false];
                [self.dataJson setValue:minArr forKey:minKey];
                [self.dataJson setValue:maxArr forKey:maxKey];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadAllComponents];
            });
            
        });
        
    }
}

- (NSMutableArray<NSNumber *> *)getLimitDataForCurrentComponent:(LQYDateComponent)currentComponent components:(NSDateComponents *)components isMinimum:(BOOL)isMinimum {
    NSRange range = [self.calendar rangeOfUnit:self.unitFlags[currentComponent].unsignedIntegerValue inUnit:self.unitFlags[currentComponent - 1].unsignedIntegerValue forDate:[self.calendar dateFromComponents:components]];
    NSInteger first = isMinimum ? [[components valueForKey:self.dateComponentKeys[currentComponent]] integerValue] : (currentComponent > LQYDateComponentDay) ? 0 : 1;
    NSInteger last = !isMinimum ? [[components valueForKey:self.dateComponentKeys[currentComponent]] integerValue] : (currentComponent > LQYDateComponentDay) ? (range.length - 1) : range.length;
    NSMutableArray<NSNumber *> *arr = [NSMutableArray array];
    for (NSInteger i = first; i <= last; i++) {
        [arr addObject:@(i)];
    }
    return arr;
}

/**
 * (废弃，耗性能)数据处理
 */
- (void)handleData:(const NSMutableArray *)dataArr minComponents:(NSDateComponents *)minComponents maxComponents:(NSDateComponents *)maxComponents components:(NSDateComponents *)components currentComponent:(LQYDateComponent)currentComponent dataDict:(const NSMutableDictionary * _Nullable)dataDict {
    NSInteger first = 0;
    NSInteger last  = 0;
    if (currentComponent == LQYDateComponentYear) {
        first = minComponents.year;
        last  = maxComponents.year;
    } else {
        NSRange range = [self.calendar rangeOfUnit:self.unitFlags[currentComponent].unsignedIntegerValue inUnit:self.unitFlags[currentComponent - 1].unsignedIntegerValue forDate:[self.calendar dateFromComponents:components]];
        first = [self dateComponents:minComponents isEqualToDateComponents:components fromComponent:self.minimumComponent toComponent:currentComponent - 1] ? [[minComponents valueForKey:self.dateComponentKeys[currentComponent]] integerValue] : 1;
        last = [self dateComponents:maxComponents isEqualToDateComponents:components fromComponent:self.minimumComponent toComponent:currentComponent - 1] ? [[maxComponents valueForKey:self.dateComponentKeys[currentComponent]] integerValue] : range.length;
    }
    for (NSInteger i = first; i <= last; i++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:[NSString stringWithFormat:@"%ld", i] forKey:@"name"];
        if (self.minimumComponent < currentComponent) {
            [dataDict[@"list"] addObject:dict];
        } else if (self.minimumComponent == currentComponent) {
            [dataArr addObject:dict];
        }
        if (currentComponent < self.maximumComponent) {
            dict[@"list"] = [NSMutableArray array];
            [components setValue:@(i) forKey:self.dateComponentKeys[currentComponent]];
            [self handleData:dataArr minComponents:minComponents maxComponents:maxComponents components:components currentComponent:currentComponent + 1 dataDict:dict];
        }
    }
}

- (BOOL)dateComponents:(NSDateComponents *)aComponents isEqualToDateComponents:(NSDateComponents *)bComponents fromComponent:(NSInteger)fromComponent toComponent:(NSInteger)toComponent {
    BOOL flag = true;
    for (NSInteger i = fromComponent; i <= toComponent; i++) {
        NSString *key = self.dateComponentKeys[i];
        if ([aComponents valueForKey:key] != [bComponents valueForKey:key]) {
            flag = false;
            break;
        }
    }
    return flag;
}

- (BOOL)isMinimumBeforeComponent:(NSInteger)component {
    BOOL flag = true;
    for (NSInteger i = 0; i < component; i++) {
        NSInteger row = [self selectedRowInComponent:i];
        if (row != 0) {
            flag = false;
            break;
        }
    }
    return flag;
}

- (BOOL)isMaximumBeforeComponent:(NSInteger)component {
    if (component == 0) {
        return false;
    }
    BOOL flag = true;
    for (NSInteger i = 0; i < component; i++) {
        NSInteger row = [self selectedRowInComponent:i];
        NSInteger totalRows = [self numberOfRowsInComponent:i];
        if (row < totalRows - 1) {
            flag = false;
            break;
        }
    }
    if (self.minimumComponent > LQYDateComponentYear && flag) {
        if ([self dateComponents:self.minComponents isEqualToDateComponents:self.maxComponents fromComponent:LQYDateComponentYear toComponent:component - self.minimumComponent]) {
            flag = true;
        } else {
            flag = false;
        }
    }
    return flag;
}

- (NSDateComponents *)dateComponentsInComponent:(NSInteger)component {
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponents = [self.calendar components:unitFlags fromDate:self.minimumDate];
    for (NSInteger i = 0; i <= component; i++) {
        NSArray<NSNumber *> *arr = [self dataArrayInComponent:i];
        NSInteger row = [self selectedRowInComponent:i];
        NSNumber *number = row < arr.count ? arr[row] : @0;
        [dateComponents setValue:number forKey:self.dateComponentKeys[i + self.minimumComponent]];
    }
    return dateComponents;
}

- (NSArray<NSNumber *> *)dataArrayInComponent:(NSInteger)component {
    LQYDateComponent currentComponent = component + self.minimumComponent;
    BOOL isMin = [self isMinimumBeforeComponent:component];
    BOOL isMax = [self isMaximumBeforeComponent:component];
    switch (currentComponent) {
        case LQYDateComponentYear:
            return self.dataJson[@"years"];
            break;
        case LQYDateComponentMonth:
            return isMin ? self.dataJson[@"minMonths"] : (isMax ? self.dataJson[@"maxMonths"] : self.months);
            break;
        case LQYDateComponentDay: {
            NSDateComponents *components = [self dateComponentsInComponent:component - 1];
            NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[self.calendar dateFromComponents:components]];
            if (isMin) {
                return self.dataJson[@"minDays"];
            }
            if (isMax) {
                return self.dataJson[@"maxDays"];
            }
            switch (range.length) {
                case 28:
                    return self.days_28;
                    break;
                case 29:
                    return self.days_29;
                    break;
                case 30:
                    return self.days_30;
                    break;
                case 31:
                    return self.days_31;
                default:
                    return 0;
                    break;
            }
        }
            break;
        case LQYDateComponentHour:
            return isMin ? self.dataJson[@"minHours"] : (isMax ? self.dataJson[@"maxHours"] : self.hours);
            break;
        case LQYDateComponentMinute:
            return isMin ? self.dataJson[@"minMinutes"] : (isMax ? self.dataJson[@"maxMinutes"] : self.minutes);
            break;
        case LQYDateComponentSecond:
            return isMin ? self.dataJson[@"minSeconds"] : (isMax ? self.dataJson[@"maxSeconds"] : self.seconds);
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark - UIPickerViewDelegate, UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.numberOfSection;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    NSArray<NSNumber *> *dataArr = [self dataArrayInComponent:component];
    return dataArr.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSArray<NSNumber *> *dataArr = [self dataArrayInComponent:component];
    NSDictionary *formatJson = self.dateFormatJson[@(component + self.minimumComponent)];
    NSString *beforeText = formatJson && formatJson[LQYFormatTypeBeforeKey] ? formatJson[LQYFormatTypeBeforeKey] : @"";
    NSString *afterText = formatJson && formatJson[LQYFormatTypeAfterKey] ? formatJson[LQYFormatTypeAfterKey] : @"";
    NSNumber *number = row < dataArr.count ? dataArr[row] : dataArr.firstObject;
    NSString *text = [NSString stringWithFormat:@"%@%@%@", beforeText, number, afterText];
    return text;
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
    
    pickerLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:self.textAttributes];
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component < self.numberOfSection - 1) {
        for (NSInteger i = component + 1; i < self.numberOfSection; i++) {
            [pickerView reloadComponent:i];
        }
    }
}

#pragma mark - delegate

- (void)addDelegate:(MOFSPickerDelegateObject *)delegate {
    [self.lock lock];
    self.delegatesDict[self.objectPointer] = delegate;
    [self.lock unlock];
}

- (void)removeDelegate:(MOFSPickerDelegateObject *)delegate {
    [self.lock lock];
    [self.delegatesDict removeObjectForKey:self.objectPointer];
    [self.lock unlock];
}

#pragma mark - public method

- (void)setDateFormat:(NSString *)dateFormat formatType:(LQYFormatType)formatType component:(LQYDateComponent)component {
    const NSString *key = formatType == LQYFormatTypeBefore ? LQYFormatTypeBeforeKey : LQYFormatTypeAfterKey;
    if (self.dateFormatJson[@(component)]) {
        self.dateFormatJson[@(component)][key] = dateFormat;
    } else {
        NSMutableDictionary<NSString *, NSString *> *dict = [NSMutableDictionary dictionaryWithObject:dateFormat forKey:key];
        self.dateFormatJson[@(component)] = dict;
    }
    NSInteger section = component = self.minimumComponent;
    if (section >= 0) {
        [self reloadComponent:section];
    }
}

- (void)showWithCommitBlock:(void (^)(NSDateComponents * _Nonnull))commitBlock cancelBlock:(void (^)(void))cancelBlock {
    MOFSPickerDelegateObject *delegate = [MOFSPickerDelegateObject initWithCancelBlock:cancelBlock commitLQYDateBlock:commitBlock];
    [self addDelegate:delegate];
    [self show];
}

#pragma mark - Dealloc

- (void)dealloc {
    
}

@end


