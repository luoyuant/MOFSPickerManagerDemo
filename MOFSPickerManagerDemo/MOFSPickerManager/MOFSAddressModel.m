//
//  MOFSAddressModel.m
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/31.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import "MOFSAddressModel.h"

NSErrorDomain const MOFSSearchErrorDomain = @"MOFSSearchErrorDomain";

@implementation MOFSAddressModel

- (NSMutableArray *)list {
    if (!_list) {
        _list = [NSMutableArray array];
    }
    return _list;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        if (dictionary) {
            self.name = dictionary[@"name"];
            self.zipcode = dictionary[@"zipcode"];
        }
    }
    return self;
}

@end


@implementation MOFSAddressSelectedModel

- (instancetype)initWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName districtName:(NSString *)districtName {
    if (self = [super init]) {
        _provinceName = provinceName;
        _cityName = cityName;
        _districtName = districtName;
    }
    return self;
}

+ (instancetype)initWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName districtName:(NSString *)districtName {
    MOFSAddressSelectedModel *model = [MOFSAddressSelectedModel new];
    model.provinceName = provinceName;
    model.cityName = cityName;
    model.districtName = districtName;
    return model;
}

- (instancetype)initWithProvinceZipcode:(NSString *)provinceZipcode cityZipcode:(NSString *)cityZipcode districtZipcode:(NSString *)districtZipcode {
    if (self = [super init]) {
        _provinceZipcode = provinceZipcode;
        _cityZipcode = cityZipcode;
        _districtZipcode = districtZipcode;
    }
    return self;
}

+ (instancetype)initWithProvinceZipcode:(NSString *)provinceZipcode cityZipcode:(NSString *)cityZipcode districtZipcode:(NSString *)districtZipcode {
    MOFSAddressSelectedModel *model = [MOFSAddressSelectedModel new];
    model.provinceZipcode = provinceZipcode;
    model.cityZipcode = cityZipcode;
    model.districtZipcode = districtZipcode;
    return model;
}

- (instancetype)initWithProvinceIndex:(NSInteger)provinceIndex cityIndex:(NSInteger)cityIndex districtIndex:(NSInteger)districtIndex {
    if (self = [super init]) {
        _provinceIndex = provinceIndex;
        _cityIndex = cityIndex;
        _districtIndex = districtIndex;
    }
    return self;
}

+ (instancetype)initWithProvinceIndex:(NSInteger)provinceIndex cityIndex:(NSInteger)cityIndex districtIndex:(NSInteger)districtIndex {
    MOFSAddressSelectedModel *model = [MOFSAddressSelectedModel new];
    model.provinceIndex = provinceIndex;
    model.cityIndex = cityIndex;
    model.districtIndex = districtIndex;
    return model;
}

- (void)copyModel:(MOFSAddressSelectedModel *)model {
    _provinceName = model.provinceName;
    _provinceZipcode = model.provinceZipcode;
    
    _cityName = model.cityName;
    _cityZipcode = model.cityZipcode;
    
    _districtName = model.districtName;
    _districtZipcode = model.districtZipcode;
}

@end


@implementation MOFSSearchAddressModel



@end
