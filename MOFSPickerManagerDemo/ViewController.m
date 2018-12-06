//
//  ViewController.m
//  MOFSPickerManagerDemo
//
//  Created by luoyuan on 16/9/5.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import "ViewController.h"
#import "MOFSPickerManager.h"

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
        [MOFSPickerManager shareManger].datePicker.toolBar.titleBarTitle = @"选择日期";
        [MOFSPickerManager shareManger].datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        [[MOFSPickerManager shareManger] showDatePickerWithTitle:@"Chose your birthday" cancelTitle:@"Cancel" commitTitle:@"Confirm" firstDate:nil minDate:nil maxDate:nil datePickerMode:UIDatePickerModeDate tag:0 commitBlock:^(NSDate *date) {
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
        a.userId = 0001;

        Model *b = [Model new];
        b.age = 18;
        b.name = @"刀锋意志";
        b.userId = 0002;

        Model *c = [Model new];
        c.age = 22;
        c.name = @"诡术妖姬";
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
        MOFSPickerView *p = [MOFSPickerView new];
        p.toolBar.titleBarTitle = @"";
        [p showMOFSPickerViewWithCustomDataArray:@[a, b, c] keyMapper:@"name" commitBlock:^(id model) {
            
        } cancelBlock:^{
            
        }];
        
    } else if (lb.tag == 3) {
        //[MOFSPickerManager shareManger].addressPicker.numberOfSection = 2;
//        [[MOFSPickerManager shareManger] showMOFSAddressPickerWithDefaultAddress:@"广西壮族自治区-玉林市-容县" title:@"选择地址" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *address, NSString *zipcode) {
//            lb.text = address;
//        } cancelBlock:^{
//
//        }];

        [[MOFSPickerManager shareManger] showMOFSAddressPickerWithDefaultZipcode:@"450000-450900-450921" title:@"选择地址" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString * _Nullable address, NSString * _Nullable zipcode) {
            lb.text = address;
            NSLog(@"%@", zipcode);
            
        } cancelBlock:^{
            
        }];
        
        NSLog(@"%@", [MOFSPickerManager shareManger].addressPicker.addressDataArray);
        
    }
    
}


@end


@implementation Model


@end

