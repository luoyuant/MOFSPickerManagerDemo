//
//  ViewController.m
//  MOFSPickerManagerDemo
//
//  Created by luoyuan on 16/9/5.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import "ViewController.h"
#import "MOFSPickerManager.h"
#import "LQYPickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lbClick:(UITapGestureRecognizer *)sender {
    UILabel *lb = (UILabel *)(sender.view);
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"yyyy-MM-dd";
    if (lb.tag == 1) {
        
        //单例方法
        [MOFSPickerManager shareManger].datePicker.toolBar.cancelBar.textColor = [UIColor redColor];
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"yyyy-M-d";
        NSDate *date = [df dateFromString:@"2015-6-1"];
        [MOFSPickerManager shareManger].datePicker.toolBar.titleBarTitle = @"选择日期";
        [MOFSPickerManager shareManger].datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        [[MOFSPickerManager shareManger] showDatePickerWithTitle:@"Chose your birthday" cancelTitle:@"Cancel" commitTitle:@"Confirm" firstDate:date minDate:date maxDate:nil datePickerMode:UIDatePickerModeDate tag:0 commitBlock:^(NSDate *date) {
            NSLog(@"%@", [df stringFromDate:date]);
        } cancelBlock:^{

        }];
        
        //自行创建实例方法
//        MOFSDatePicker *p = [MOFSDatePicker new];
//        [p showMOFSDatePickerViewWithFirstDate:nil commit:^(NSDate *date) {
//
//        } cancel:^{
//
//        }];

    } else if (lb.tag == 2) {
//        NSString *str_a = @"疾风剑豪";
//        str_a.mofs_key = @"自定义id";
//        [[MOFSPickerManager shareManger] showPickerViewWithDataArray:@[str_a,@"刀锋意志",@"诡术妖姬",@"狂战士"] tag:1 title:@"选择英雄" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *string) {
//            lb.text = string;
//            NSLog(@"%@-%@",string, string.mofs_key);
//        } cancelBlock:^{
//
//        }];
        
        Model *a = [Model new];
        a.age = 17;
        a.name = @"疾风剑豪";
        a.nickname = @"托儿所";
        a.userId = 0001;

        Model *b = [Model new];
        b.age = 18;
        b.name = @"刀锋意志";
        b.nickname = @"刀妹";
        b.userId = 0002;

        Model *c = [Model new];
        c.age = 22;
        c.name = @"诡术妖姬";
        c.nickname = @"乐芙兰";
        c.userId = 0003;

        //单例方法
//        [[MOFSPickerManager shareManger] showPickerViewWithCustomDataArray:@[a, b, c] keyMapper:@"name" title:@"选择英雄" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(id model) {
//            Model *m = (Model *)model;
//            lb.text = m.name;
//            NSLog(@"%@-%zd", m.name, m.userId);
//        } cancelBlock:^{
//
//        }];
        
        //自行创建实例方法
//        MOFSPickerView *p = [MOFSPickerView new];
//        p.attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:17], NSForegroundColorAttributeName : [UIColor redColor]};
//        p.toolBar.titleBarTitle = @"";
//        [p showMOFSPickerViewWithCustomDataArray:@[a, b, c] keyMapper:@"name" commitBlock:^(id model) {
//
//        } cancelBlock:^{
//
//        }];
        
//        LQYPickerView *p = [LQYPickerView new];
//        p.dataArray = @[@[a, b, c], @[a, b, c]];
//        p.dataArray = @[@{@"name" : @"流浪法师", @"age" : @25},@{@"name" : @"流浪法师1", @"age" : @25}, @{@"name" : @"流浪法师2", @"age" : @25}];
//        p.dataArray = @[@"流浪法师", @"疾风剑豪", @"无双剑姬"];
//        p.dataTextKeys = @{@0 : @"name"};

//        p.toolBar.titleBar.text = @"自定义选择";
//        p.dataArray = @[@{@"name" : @"广西", @"list" : @[@{@"name" : @"南宁", @"list" : @[@"清秀", @"时区"]}, @{@"name" : @"桂林", @"list" : @[a]}]}];
////        p.dataTextKeys = @{@0 : @"name"};
////        p.dataArray = [MOFSPickerManager shareManger].addressPicker.addressDataArray;
//        p.numberOfSection = 3;
//        p.isDynamic = true;
//        p.dataKeys = @{@0 : @"list", @1 : @"list", @2 : @"list"};
//        p.dataTextKeys = @{@0 : @"name"};
//
//        [p show];
//
//        p.commitBlock = ^(NSDictionary<NSNumber *,id> * _Nonnull json) {
//            NSLog(@"%@", json);
//        };
        
//        LQYYearAndMonthPickerView *p = [LQYYearAndMonthPickerView new];
//        NSDateFormatter *df = [NSDateFormatter new];
//        df.dateFormat = @"yyyy-M";
//        NSDate *date = [df dateFromString:@"2015-6"];
//        p.minimumDate = date;
//        [p show];
//        p.commitBlock = ^(NSDictionary<NSNumber *,id> * _Nonnull json) {
//            NSLog(@"%@", json);
//        };
        
        LQYDatePickerView *p = [LQYDatePickerView new];
        [p showWithCommitBlock:^(NSDateComponents * _Nonnull components) {
            NSLog(@"%@", components);
        } cancelBlock:^{
            NSLog(@"取消");
        }];
        
        
    } else if (lb.tag == 3) {
        //[MOFSPickerManager shareManger].addressPicker.numberOfSection = 2;
//        [[MOFSPickerManager shareManger] showMOFSAddressPickerWithDefaultAddress:@"广西壮族自治区-玉林市-容县" title:@"选择地址" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *address, NSString *zipcode) {
//            lb.text = address;
//        } cancelBlock:^{
//
//        }];

//        [MOFSPickerManager shareManger].addressPicker.attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:15], NSForegroundColorAttributeName : [UIColor redColor]};
        
        
        
//        [[MOFSPickerManager shareManger] showMOFSAddressPickerWithDefaultZipcode:@"450000-450900-450921" title:@"选择地址" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString * _Nullable address, NSString * _Nullable zipcode) {
//            lb.text = address;
//            NSLog(@"%@", zipcode);
//
//        } cancelBlock:^{
//
//        }];
        [MOFSPickerManager shareManger].addressPicker.usedXML = true;
        [[MOFSPickerManager shareManger] showMOFSAddressPickerWithTitle:@"选择地址" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString * _Nullable address, NSString * _Nullable zipcode) {
            
        } cancelBlock:^{
            
        }];
        
        //修改中间分割线颜色
//        MOFSAddressPickerView *picker = [MOFSPickerManager shareManger].addressPicker;
//        [picker.subviews objectAtIndex:1].backgroundColor = [UIColor yellowColor];
//        [picker.subviews objectAtIndex:2].backgroundColor = [UIColor yellowColor];
        
    }
    
}


@end


@implementation Model


@end

