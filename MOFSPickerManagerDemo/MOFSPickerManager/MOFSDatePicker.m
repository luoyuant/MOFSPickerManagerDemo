//
//  MOFSDatePicker.m
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/26.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import "MOFSDatePicker.h"

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MOFSDatePicker()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MOFSPickerDelegateObject *> *delegatesDict;
@property (readwrite, nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSString *objectPointer;

@end


@implementation MOFSDatePicker

#pragma mark - Getter

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

- (NSString *)objectPointer {
    return [NSString stringWithFormat:@"%p", self];
}

#pragma mark - create UI

- (instancetype)initWithFrame:(CGRect)frame {
    
    [self initToolBar];
    [self initContainerView];
    
    CGRect initialFrame;
    if (CGRectIsEmpty(frame)) {
        initialFrame = CGRectMake(0, self.toolBar.frame.size.height, UISCREEN_WIDTH, 216);
    } else {
        initialFrame = frame;
    }
    self = [super initWithFrame:initialFrame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor whiteColor];
        self.tintColor = [UIColor whiteColor];
        self.datePickerMode = UIDatePickerModeDate;
        self.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        if (@available(iOS 13.4, *)) {
            self.preferredDatePickerStyle = UIDatePickerStyleWheels;
        } else {
            // Fallback on earlier versions
        }
        
        [self initBgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = self.frame;
    frame.origin.x = 0;
    frame.origin.y = self.bgView.bounds.size.height - frame.size.height;
    frame.size.width = self.bgView.frame.size.width;
    self.frame = frame;
    
}

- (void)initToolBar {
    self.toolBar = [[MOFSToolView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, 44)];
    self.toolBar.backgroundColor = [UIColor whiteColor];
    [self.toolBar.cancelBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelAction)]];
    [self.toolBar.commitBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commitAction)]];
}

- (void)initContainerView {
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_WIDTH, UISCREEN_HEIGHT)];
    self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    self.containerView.userInteractionEnabled = YES;
    [self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerViewClickedAction)]];
}

- (void)initBgView {
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, UISCREEN_HEIGHT - self.frame.size.height - 44, UISCREEN_WIDTH, self.frame.size.height + self.toolBar.frame.size.height)];
    self.bgView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - public method

/**
 * 显示日期选择器
 * @param selectedDate 默认选中的日期
 */
- (void)showWithSelectedDate:(NSDate * _Nullable)selectedDate
                      commit:(CommitBlock _Nullable)commitBlock
                      cancel:(CancelBlock _Nullable)cancelBlock {
    MOFSPickerDelegateObject *delegate = [MOFSPickerDelegateObject initWithCancelBlock:cancelBlock commitDateBlock:commitBlock];
    [self showWithDelegate:delegate date:selectedDate];
}


/**
 * 显示日期选择器
 * @param title 选择器toolBar中间标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 * @param selectedDate 默认选中的日期
 * @param minDate 选择器最小日期
 * @param maxDate 选择器最大日期
 * @param mode 选择器模式
 */
- (void)showWithTitle:(NSString * _Nullable)title
          commitTitle:(NSString * _Nullable)commitTitle
          cancelTitle:(NSString * _Nullable)cancelTitle
         selectedDate:(NSDate * _Nullable)selectedDate
              minDate:(NSDate * _Nullable)minDate
              maxDate:(NSDate * _Nullable)maxDate
       datePickerMode:(UIDatePickerMode)mode
          commitBlock:(CommitBlock _Nullable )commitBlock
          cancelBlock:(CancelBlock _Nullable )cancelBlock {
    
    self.toolBar.titleBarTitle = title;
    self.toolBar.commitBarTitle = commitTitle;
    self.toolBar.cancelBarTitle = cancelTitle;

    self.minimumDate = minDate;
    self.maximumDate = maxDate;
    
    self.datePickerMode = mode;
    
    MOFSPickerDelegateObject *delegate = [MOFSPickerDelegateObject initWithCancelBlock:cancelBlock commitDateBlock:commitBlock];
    [self showWithDelegate:delegate date:selectedDate];
}

#pragma mark - private method

- (void)showWithDelegate:(MOFSPickerDelegateObject *)delegate date:(NSDate *)date {
    if (!delegate) {
        return;
    }
    if (date) {
        self.date = date;
    }
    
    [self showWithAnimation];

    [self addDelegate:delegate];
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

#pragma mark - ToolBar Action

- (void)cancelAction {
    [self hiddenWithAnimation];
    MOFSPickerDelegateObject *delegate = self.delegatesDict[self.objectPointer];
    if (delegate.cancelBlock) {
        delegate.cancelBlock();
    }
    [self removeDelegate:delegate];
}

- (void)commitAction {
    [self hiddenWithAnimation];
    MOFSPickerDelegateObject *delegate = self.delegatesDict[self.objectPointer];
    if (delegate.commitDateBlock) {
        delegate.commitDateBlock(self.date);
    }
    
    [self removeDelegate:delegate];
}

#pragma mark - Action

- (void)showWithAnimation {
    [self addViews];
    self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    CGFloat height = self.bgView.frame.size.height;
    self.bgView.center = CGPointMake(UISCREEN_WIDTH / 2, UISCREEN_HEIGHT + height / 2);
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(UISCREEN_WIDTH / 2, UISCREEN_HEIGHT - height / 2);
        self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }];
    
}

- (void)hiddenWithAnimation {
    CGFloat height = self.bgView.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(UISCREEN_WIDTH / 2, UISCREEN_HEIGHT + height / 2);
        self.containerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    } completion:^(BOOL finished) {
        [self hiddenViews];
    }];
}

- (void)containerViewClickedAction {
    if (self.containerViewClickedBlock) {
        self.containerViewClickedBlock();
    }
    [self hiddenWithAnimation];
}

- (void)addViews {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.containerView];
    [window addSubview:self.bgView];
    [self.bgView addSubview:self.toolBar];
    [self.bgView addSubview:self];
}

- (void)hiddenViews {
    [self removeFromSuperview];
    [self.toolBar removeFromSuperview];
    [self.bgView removeFromSuperview];
    [self.containerView removeFromSuperview];
}

#pragma mark - Dealloc

- (void)dealloc {
    
}

@end
