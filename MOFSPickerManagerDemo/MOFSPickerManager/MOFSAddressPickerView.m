//
//  MOFSAddressPickerView.m
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/31.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import "MOFSAddressPickerView.h"

#define UISCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define UISCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface MOFSAddressPickerView() <UIPickerViewDelegate, UIPickerViewDataSource, NSXMLParserDelegate>

@property (nonatomic, strong) NSXMLParser *parser;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSMutableArray<MOFSAddressModel *> *dataArr;

@property (nonatomic, assign) NSInteger selectedIndex_province;
@property (nonatomic, assign) NSInteger selectedIndex_city;
@property (nonatomic, assign) NSInteger selectedIndex_area;

@property (nonatomic, assign) BOOL isGettingData;
@property (nonatomic, strong) void (^getDataCompleteBlock)(void);

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MOFSPickerDelegateObject *> *delegatesDict;
@property (readwrite, nonatomic, strong) NSLock *lock;

@property (nonatomic, strong) NSString *objectPointer;

@end

@implementation MOFSAddressPickerView

#pragma mark - setter

- (void)setAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    _attributes = attributes;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadAllComponents];
    });
}

- (void)setNumberOfSection:(NSInteger)numberOfSection {
    if (numberOfSection <= 0 || numberOfSection > 3) {
        _numberOfSection = 3;
    } else {
        _numberOfSection = numberOfSection;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadAllComponents];
    });
}

- (void)setUsedXML:(BOOL)usedXML {
    if (usedXML != _usedXML) {
        _usedXML = usedXML;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self getData];
            dispatch_queue_t queue = dispatch_queue_create("my.current.queue", DISPATCH_QUEUE_CONCURRENT);
            dispatch_barrier_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadAllComponents];
                });
            });
        });
    }
}

#pragma mark - getter

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
        _lock.name = @"com.ly.addressPicker.lock";
    }
    return _lock;
}

- (NSMutableDictionary<NSString *, MOFSPickerDelegateObject *> *)delegatesDict {
    if (!_delegatesDict) {
        _delegatesDict = [NSMutableDictionary dictionary];
    }
    return _delegatesDict;
}

- (NSMutableArray<MOFSAddressModel *> *)addressDataArray {
    return _dataArr;
}

- (NSString *)objectPointer {
    return [NSString stringWithFormat:@"%p", self];
}

#pragma mark - create UI

- (instancetype)initWithFrame:(CGRect)frame {
    
    self.semaphore = dispatch_semaphore_create(1);
    
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self getData];
            dispatch_queue_t queue = dispatch_queue_create("my.current.queue", DISPATCH_QUEUE_CONCURRENT);
            dispatch_barrier_async(queue, ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadAllComponents];
                });
            });
        });
    }
    return self;
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated {
    if (component >= self.numberOfComponents) {
        return;
    }
    [super selectRow:row inComponent:component animated:animated];
    switch (component) {
        case 0:
            self.selectedIndex_province = row;
            self.selectedIndex_city = 0;
            self.selectedIndex_area = 0;
            if (self.numberOfSection > 1) {
                [self reloadComponent:1];
            }
            if (self.numberOfSection > 2) {
                [self reloadComponent:2];
            }
            break;
        case 1:
            self.selectedIndex_city = row;
            self.selectedIndex_area = 0;
            if (self.numberOfSection > 2) {
                [self reloadComponent:2];
            }
            break;
        case 2:
            self.selectedIndex_area = row;
            break;
        default:
            break;
    }
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
    if (delegate.commitAddressBlock) {
        
        if (self.dataArr.count > 0) {
            MOFSAddressModel *provinceModel = self.dataArr[self.selectedIndex_province];
            MOFSAddressModel *cityModel;
            MOFSAddressModel *districtModel;
            if (provinceModel.list.count > 0 && self.numberOfComponents > 1) {
                cityModel = provinceModel.list[self.selectedIndex_city];
            }
            if (cityModel && cityModel.list.count > 0 && self.numberOfComponents > 2) {
                districtModel = cityModel.list[self.selectedIndex_area];
            }
            
            MOFSAddressSelectedModel *selectedModel = [MOFSAddressSelectedModel new];
            selectedModel.provinceName = provinceModel.name;
            selectedModel.provinceZipcode = provinceModel.zipcode;
            selectedModel.provinceIndex = provinceModel.index;
            selectedModel.cityName = cityModel.name;
            selectedModel.cityZipcode = cityModel.zipcode;
            selectedModel.cityIndex = cityModel.index;
            selectedModel.districtName = districtModel.name;
            selectedModel.districtZipcode = districtModel.zipcode;
            selectedModel.districtIndex = districtModel.index;
            
            delegate.commitAddressBlock(selectedModel);
        }
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

#pragma mark - Action

/**
 * 显示选择器
 * @param title 选择器toolBar中间标题
 * @param commitTitle 确定标题
 * @param cancelTitle 取消标题
 */
- (void)showWithTitle:(NSString * _Nullable)title
          commitTitle:(NSString * _Nullable)commitTitle
          cancelTitle:(NSString * _Nullable)cancelTitle
          commitBlock:(void (^ _Nullable)(MOFSAddressSelectedModel * _Nullable selectedModel))commitBlock
          cancelBlock:(void (^ _Nullable)(void))cancelBlock {
    [self showWithSelectedAddress:nil title:title commitTitle:commitTitle cancelTitle:cancelTitle commitBlock:commitBlock cancelBlock:cancelBlock];
}

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
                    commitBlock:(void (^ _Nullable)(MOFSAddressSelectedModel * _Nullable selectedModel))commitBlock
                    cancelBlock:(void (^ _Nullable)(void))cancelBlock {
    if (self.numberOfSection <= 0 || self.numberOfComponents > 3) {
        self.numberOfSection = 3;
    }
    
    self.toolBar.titleBarTitle = title;
    self.toolBar.commitBarTitle = commitTitle;
    self.toolBar.cancelBarTitle = cancelTitle;
    
    //iOS 10及以上需要添加 这一行代码，否则第一次不显示中间两条分割线
    if ([self numberOfRowsInComponent:0] > 0) {}
    
    [self showWithAnimation];
    
    MOFSPickerDelegateObject *delegate = [MOFSPickerDelegateObject initWithCancelBlock:cancelBlock commitAddressBlock:commitBlock];
    [self addDelegate:delegate];
    
    if (selectedAddress) {
        [self searchType:MOFSAddressSearchTypeByAddress keyModel:selectedAddress block:^(MOFSSearchAddressModel * _Nullable result) {
            if (!result.error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self selectRow:result.provinceIndex inComponent:0 animated:NO];
                    [self selectRow:result.cityIndex inComponent:1 animated:NO];
                    [self selectRow:result.districtIndex inComponent:2 animated:NO];
                });
            }
        }];
    }
    
}

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
                    cancelBlock:(void(^_Nullable)(void))cancelBlock {
    if (self.numberOfSection <= 0 || self.numberOfComponents > 3) {
        self.numberOfSection = 3;
    }
    
    self.toolBar.titleBarTitle = title;
    self.toolBar.commitBarTitle = commitTitle;
    self.toolBar.cancelBarTitle = cancelTitle;
    
    //iOS 10及以上需要添加 这一行代码，否则第一次不显示中间两条分割线
    if ([self numberOfRowsInComponent:0] > 0) {}
    
    [self showWithAnimation];
    
    MOFSPickerDelegateObject *delegate = [MOFSPickerDelegateObject initWithCancelBlock:cancelBlock commitAddressBlock:commitBlock];
    [self addDelegate:delegate];
    
    if (selectedZipcode) {
        [self searchType:MOFSAddressSearchTypeByZipcode keyModel:selectedZipcode block:^(MOFSSearchAddressModel * _Nullable result) {
            if (!result.error) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self selectRow:result.provinceIndex inComponent:0 animated:NO];
                    [self selectRow:result.cityIndex inComponent:1 animated:NO];
                    [self selectRow:result.districtIndex inComponent:2 animated:NO];
                });
            }
        }];
    }
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

#pragma mark - get data

- (void)getData {
    if (self.isGettingData) {
        return;
    }
    self.isGettingData = YES;
    NSString *extName = _usedXML ? @"xml" : @"json";
    NSString *path = [[NSBundle mainBundle] pathForResource:@"province_data" ofType:extName];
    if (path == nil) {
        for (NSBundle *bundle in [NSBundle allFrameworks]) {
            path = [bundle pathForResource:@"province_data" ofType:extName];
            if (path != nil) {
                break;
            }
        }
    }
    
    if (path == nil) {
        self.isGettingData = NO;
        if (self.getDataCompleteBlock) {
            self.getDataCompleteBlock();
        }
        return;
    }
    
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    if (_dataArr.count != 0) {
        [_dataArr removeAllObjects];
    }
    
    if (_usedXML) {
        self.parser = [[NSXMLParser alloc] initWithData:[NSData dataWithContentsOfFile:path]];
        self.parser.delegate = self;
        [self.parser parse];
    } else {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if (dict[@"province"] && [dict[@"province"] isKindOfClass:[NSArray class]]) {
            NSArray *arr = dict[@"province"];
            for (NSDictionary *provinceJson in arr) {
                MOFSAddressModel *provinceModel = [[MOFSAddressModel alloc] initWithDictionary:provinceJson];
                provinceModel.index = self.dataArr.count;
                if (provinceJson[@"city"] && [provinceJson[@"city"] isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *cityJson in provinceJson[@"city"]) {
                        MOFSAddressModel *cityModel = [[MOFSAddressModel alloc] initWithDictionary:cityJson];
                        cityModel.index = provinceModel.list.count;
                        [provinceModel.list addObject:cityModel];
                        if (cityJson[@"district"] && [cityJson[@"district"] isKindOfClass:[NSArray class]]) {
                            for (NSDictionary *districtJson in cityJson[@"district"]) {
                                MOFSAddressModel *model = [[MOFSAddressModel alloc] initWithDictionary:districtJson];
                                model.index = cityModel.list.count;
                                [cityModel.list addObject:model];
                            }
                        }
                    }
                }
                [self.dataArr addObject:provinceModel];
            }
        }
        
        self.isGettingData = NO;
        if (self.getDataCompleteBlock) {
            self.getDataCompleteBlock();
        }
        
    }
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"province"]) {
        MOFSAddressModel *model = [[MOFSAddressModel alloc] initWithDictionary:attributeDict];
        model.index = self.dataArr.count;
        [self.dataArr addObject:model];
    } else if ([elementName isEqualToString:@"city"]) {
        MOFSAddressModel *model = [[MOFSAddressModel alloc] initWithDictionary:attributeDict];
        model.index = self.dataArr.lastObject.list.count;
        [self.dataArr.lastObject.list addObject:model];
    } else if ([elementName isEqualToString:@"district"]) {
        MOFSAddressModel *model = [[MOFSAddressModel alloc] initWithDictionary:attributeDict];
        model.index = self.dataArr.lastObject.list.lastObject.list.count;
        [self.dataArr.lastObject.list.lastObject.list addObject: model];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.isGettingData = NO;
    if (self.getDataCompleteBlock) {
        self.getDataCompleteBlock();
    }
}

#pragma mark - search

- (void)searchType:(MOFSAddressSearchType)searchType keyModel:(MOFSAddressSelectedModel *)keyModel block:(void (^)(MOFSSearchAddressModel * _Nullable))block {
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    
    NSString *searchKeyName = @"";
    
    switch (searchType) {
        case MOFSAddressSearchTypeByAddress:
            searchKeyName = @"name";
            break;
        case MOFSAddressSearchTypeByZipcode:
            searchKeyName = @"zipcode";
            break;
        case MOFSAddressSearchTypeByIndex:
            searchKeyName = @"index";
            break;
        default:
            break;
    }
    
    if (self.isGettingData || !self.dataArr || self.dataArr.count == 0) {
        __weak typeof(self) weakSelf = self;
        self.getDataCompleteBlock = ^{
            if (block) {
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    block([weakSelf searchByKeyModel:keyModel searchType:searchType keyName:searchKeyName]);
                });
                
                dispatch_semaphore_signal(weakSelf.semaphore);
            }
        };
    } else {
        if (block) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                block([self searchByKeyModel:keyModel searchType:searchType keyName:searchKeyName]);
            });
            dispatch_semaphore_signal(self.semaphore);
        }
    }

}


- (MOFSSearchAddressModel * _Nullable)searchByKeyModel:(MOFSAddressSelectedModel *)keyModel searchType:(MOFSAddressSearchType)searchType keyName:(NSString *)keyName {
    
    if (!keyModel) {
        return nil;
    }

    MOFSSearchAddressModel *resultModel = [MOFSSearchAddressModel new];
    [resultModel copyModel:keyModel];
    
    id provinceValue, cityValue, districtValue;
    switch (searchType) {
        case MOFSAddressSearchTypeByAddress:
            provinceValue = keyModel.provinceName;
            cityValue = keyModel.cityName;
            districtValue = keyModel.districtName;
            break;
        case MOFSAddressSearchTypeByZipcode:
            provinceValue = keyModel.provinceZipcode;
            cityValue = keyModel.cityZipcode;
            districtValue = keyModel.districtZipcode;
            break;
        case MOFSAddressSearchTypeByIndex:
            provinceValue = @(keyModel.provinceIndex);
            cityValue = @(keyModel.cityIndex);
            districtValue = @(keyModel.districtIndex);
            break;
        default:
            break;
    }
    
    MOFSAddressModel *provinceModel = (MOFSAddressModel *)[self searchModelInArr:_dataArr key:keyName value:provinceValue];
    if (provinceModel) {
        resultModel.provinceName = provinceModel.name;
        resultModel.provinceZipcode = provinceModel.zipcode;
        resultModel.provinceIndex = provinceModel.index;
        
        MOFSAddressModel *cityModel = (MOFSAddressModel *)[self searchModelInArr:provinceModel.list key:keyName value:cityValue];
        if (cityModel) {
            resultModel.cityName = cityModel.name;
            resultModel.cityZipcode = cityModel.zipcode;
            resultModel.cityIndex = cityModel.index;
            
            MOFSAddressModel *districtModel = (MOFSAddressModel *)[self searchModelInArr:cityModel.list key:keyName value:districtValue];
            if (districtModel) {
                resultModel.districtName = districtModel.name;
                resultModel.districtZipcode = districtModel.zipcode;
                resultModel.districtIndex = districtModel.index;
            } else {
                resultModel.error = [NSError errorWithDomain:MOFSSearchErrorDomain code:MOFSSearchErrorCodeDistrictNotFound userInfo:nil];
            }
        } else {
            resultModel.error = [NSError errorWithDomain:MOFSSearchErrorDomain code:MOFSSearchErrorCodeCityNotFound userInfo:nil];
        }
    } else {
        resultModel.error = [NSError errorWithDomain:MOFSSearchErrorDomain code:MOFSSearchErrorCodeProvinceNotFound userInfo:nil];
    }

    return resultModel;
}

- (NSObject *)searchModelInArr:(NSArray *)arr key:(NSString *)key value:(id)value {
    NSArray *filterArr = [arr filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.%@ = %@", key, value]];
    return filterArr.firstObject;
}


#pragma mark - UIPickerViewDelegate,UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.numberOfSection;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    MOFSAddressModel *provinceModel;
    if (self.dataArr.count > 0) {
        provinceModel = self.dataArr[self.selectedIndex_province];
    }
   
    MOFSAddressModel *cityModel;
    if (provinceModel && provinceModel.list.count > 0) {
        cityModel = provinceModel.list[self.selectedIndex_city];
    }
    if (self.dataArr.count != 0) {
        if (component == 0) {
            return self.dataArr.count;
        } else if (component == 1) {
            return provinceModel == nil ? 0 : provinceModel.list.count;
        } else if (component == 2) {
            return cityModel == nil ? 0 : cityModel.list.count;
        } else {
            return 0;
        }
    } else {
        return 0;
    }

}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (component == 0) {
        MOFSAddressModel *provinceModel = self.dataArr[row];
        return provinceModel.name;
    } else if (component == 1) {
        MOFSAddressModel *provinceModel = self.dataArr[self.selectedIndex_province];
        MOFSAddressModel *cityModel = provinceModel.list[row];
        return cityModel.name;
    } else if (component == 2) {
        MOFSAddressModel *provinceModel = self.dataArr[self.selectedIndex_province];
        MOFSAddressModel *cityModel = provinceModel.list[self.selectedIndex_city];
        MOFSAddressModel *districtModel = cityModel.list[row];
        return districtModel.name;
    } else {
        return nil;
    }
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
    switch (component) {
        case 0:
            self.selectedIndex_province = row;
            self.selectedIndex_city = 0;
            self.selectedIndex_area = 0;
            if (self.numberOfSection > 1) {
                [pickerView reloadComponent:1];
                [pickerView selectRow:0 inComponent:1 animated:NO];
            }
            if (self.numberOfSection > 2) {
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:NO];
            }
            break;
        case 1:
            self.selectedIndex_city = row;
            self.selectedIndex_area = 0;
            if (self.numberOfSection > 2) {
                [pickerView reloadComponent:2];
                [pickerView selectRow:0 inComponent:2 animated:NO];
            }
            break;
        case 2:
            self.selectedIndex_area = row;
            break;
        default:
            break;
    }
}

#pragma mark - Dealloc

- (void)dealloc {
   
}

@end
