# iOS PickerView整合，一行代码调用（省市区三级联动+日期选择+普通选择）

支持CocoaPods安装，

pod 'MOFSPickerManager'即可

## 预览图

![image](https://github.com/memoriesofsnows/MOFSPickerManagerDemo/blob/master/images/tap9.gif)

## 用法
1.日期选择器调用（有多种调用方式，看demo即可）

```objective-c
[[MOFSPickerManager shareManger].datePicker showWithTitle:@"选择日期" commitTitle:@"确定" cancelTitle:@"取消" selectedDate:selectedDate minDate:nil maxDate:nil datePickerMode:UIDatePickerModeDate commitBlock:^(NSDate * _Nullable date) {
    NSLog(@"%@", [df stringFromDate:date]);
 } cancelBlock:^{

 }];
```
 
参数说明

* @param title : 中间标题，一般为nil

* @param cancelTitle : 左边标题 “取消”

* @param commitTitle : 右边标题 “确定”

* @param selectedDate : 默认选中日期

* @param minDate : 可选择的最小日期，不限制则为nil

* @param maxDate : 可选择的最大日期，不限制则为nil

* @param model : UIDatePickerMode 日期模式，有四种 UIDatePickerModeTime,   UIDatePickerModeDate, UIDatePickerModeDateAndTime, UIDatePickerModeCountDownTimer

2.普通选择器调用

```objective-c
[[MOFSPickerManager shareManger].pickView showWithDataArray:@[@"疾风剑豪",@"刀锋意志",@"诡术妖姬",@"狂战士"] title:nil commitBlock:^(id  _Nullable model) {
            
} cancelBlock:^{
            
}];
```

3.地址选择器调用

```objective-c
[[MOFSPickerManager shareManger].addressPicker showWithTitle:@"选择地址" commitTitle:@"确定" cancelTitle:@"取消" commitBlock:^(MOFSAddressSelectedModel * _Nullable selectedModel) {
    lb.text = [NSString stringWithFormat:@"%@-%@-%@", selectedModel.provinceName, selectedModel.cityName, selectedModel.districtName];
} cancelBlock:^{

}];
```

地址选择器附带根据地址查询区域码或者根据区域码查询地址功能：

用法：

①根据区域码查询地址等信息

```objective-c
[[MOFSPickerManager shareManger].addressPicker searchType:MOFSAddressSearchTypeByZipcode keyModel:[MOFSAddressSelectedModel initWithProvinceZipcode:@"450000" cityZipcode:@"450900" districtZipcode:@"450921"] block:^(MOFSSearchAddressModel * _Nullable result) {
            
}];
```

②根据地址查询区域码等信息

```objective-c
[[MOFSPickerManager shareManger].addressPicker searchType:MOFSAddressSearchTypeByAddress keyModel:[MOFSAddressSelectedModel initWithProvinceName:@"广西壮族自治区" cityName:@"玉林市" districtName:@"容县"] block:^(MOFSSearchAddressModel * _Nullable result) {
            
}];
```
    
    
[详情请查看](http://www.jianshu.com/p/578065eab5ab)
    
    
如果发现有bug，call me！

luoyuant@163.com
