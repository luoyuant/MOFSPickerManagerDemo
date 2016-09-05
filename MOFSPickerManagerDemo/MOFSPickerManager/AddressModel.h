//
//  AddressModel.h
//  MOFSPickerManager
//
//  Created by lzqhoh@163.com on 16/8/31.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"

@class CityModel,DistrictModel;
@interface AddressModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSMutableArray *list;

- (instancetype)initWithXML:(GDataXMLElement *)xml;

@end

@interface CityModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, strong) NSMutableArray *list;

- (instancetype)initWithXML:(GDataXMLElement *)xml;

@end

@interface DistrictModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *zipcode;

- (instancetype)initWithXML:(GDataXMLElement *)xml;


@end