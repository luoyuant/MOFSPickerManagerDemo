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
        [MOFSPickerManager shareManger].datePicker.toolBar.cancelBarTintColor = [UIColor redColor];
        [MOFSPickerManager shareManger].datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
        [[MOFSPickerManager shareManger] showDatePickerWithTag:1 commitBlock:^(NSDate *date) {
            lb.text = [df stringFromDate:date];
        } cancelBlock:^{
            
        }];
    } else if (lb.tag == 2) {
        [[MOFSPickerManager shareManger] showPickerViewWithDataArray:@[@"疾风剑豪",@"刀锋意志",@"诡术妖姬",@"狂战士"] tag:1 title:nil cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *string) {
            lb.text = string;
        } cancelBlock:^{
            
        }];
    } else if (lb.tag == 3) {
        //[MOFSPickerManager shareManger].addressPicker.numberOfSection = 2;
        [[MOFSPickerManager shareManger] showMOFSAddressPickerWithDefaultAddress:@"广西壮族自治区-玉林市-容县" title:@"" cancelTitle:@"取消" commitTitle:@"确定" commitBlock:^(NSString *address, NSString *zipcode) {
            lb.text = address;
        } cancelBlock:^{
            
        }];

        
    }
    
}


@end
