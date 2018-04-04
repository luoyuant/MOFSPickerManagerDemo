//
//  ViewController.h
//  MOFSPickerManagerDemo
//
//  Created by luoyuan on 16/9/5.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Model;

@interface ViewController : UIViewController


@end

@interface Model : NSObject

@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, copy) NSString *name;

@end
