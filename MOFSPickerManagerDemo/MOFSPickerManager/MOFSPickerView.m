//
//  MOFSPickerView.m
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/30.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import "MOFSPickerView.h"
#import <objc/runtime.h>

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MOFSPickerView() <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) NSInteger selectedRow;

@property (nonatomic, copy) NSString *keyMapper; //自定义解析Key

@property (nonatomic, strong) NSMutableDictionary<NSString *, MOFSPickerDelegateObject *> *delegatesDict;
@property (readwrite, nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSString *objectPointer;

@end

@implementation MOFSPickerView

#pragma mark - setter

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    _attributes = attributes;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadAllComponents];
    });
}

#pragma mark - gettter

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
        _lock.name = @"com.ly.picker.lock";
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
        self.backgroundColor = [UIColor whiteColor];
       
        self.delegate = self;
        self.dataSource = self;
        
        [self initBgView];
    }
    return self;
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
}

#pragma mark - Action

/**
 * 显示选择器
 * @param array 字符数组
 * @param title 标题
 */
- (void)showWithDataArray:(NSArray<NSString *> * _Nonnull)array
                    title:(NSString * _Nullable)title
              commitBlock:(void(^ _Nullable)(id _Nullable model))commitBlock
              cancelBlock:(void(^ _Nullable)(void))cancelBlock {
    [self showWithDataArray:array title:title commitTitle:@"确定" cancelTitle:@"取消" commitBlock:commitBlock cancelBlock:cancelBlock];
}

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
              cancelBlock:(void(^ _Nullable)(void))cancelBlock {
    [self showWithDataArray:array keyMapper:nil title:title commitTitle:commitTitle cancelTitle:cancelTitle commitBlock:commitBlock cancelBlock:cancelBlock];
}

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
              cancelBlock:(void(^ _Nullable)(void))cancelBlock {
    [self showWithDataArray:array keyMapper:keyMapper title:title commitTitle:@"确定" cancelTitle:@"取消" commitBlock:commitBlock cancelBlock:cancelBlock];
}

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
              cancelBlock:(void(^ _Nullable)(void))cancelBlock {
    if (array.count <= 0) {
        return;
    }
    self.dataArr = array.copy;
    self.keyMapper = keyMapper;
    
    self.toolBar.titleBarTitle = title;
    self.toolBar.commitBarTitle = commitTitle;
    self.toolBar.cancelBarTitle = cancelTitle;
    
    [self reloadAllComponents];
//    self.selectedRow = 0;
//    if (tag != NSNotFound) {
//        self.selectedRow = [self.recordDict[@(tag)] integerValue];
//    }
//    if (tag > 0) {
//        @try {
//            [self selectRow:self.selectedRow inComponent:0 animated:NO];
//        } @catch (NSException *exception) {
//
//        } @finally {
//
//        }
//    }
    
    [self showWithAnimation];
    
    MOFSPickerDelegateObject *delegate = [MOFSPickerDelegateObject initWithCancelBlock:cancelBlock commitPickerBlock:commitBlock];
    [self addDelegate:delegate];
}

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
    if (delegate.commitPickerBlock && self.selectedRow < self.dataArr.count) {
        delegate.commitPickerBlock(self.dataArr[self.selectedRow]);
    }
    
    [self removeDelegate:delegate];
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

#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.dataArr.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.keyMapper) {
        id value = [self.dataArr[row] valueForKey:self.keyMapper];
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        } else {
            return @"解析出错";
        }
    }
    return self.dataArr[row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.font = [UIFont systemFontOfSize:16];
        pickerLabel.textColor = [UIColor colorWithRed:12.f/255.f green:14.f/255.f blue:14.f/255.f alpha:1];
    }
    
    NSString *text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    pickerLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:_attributes];
    
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedRow = row;
}

#pragma mark - Dealloc

- (void)dealloc {
    
}

@end
