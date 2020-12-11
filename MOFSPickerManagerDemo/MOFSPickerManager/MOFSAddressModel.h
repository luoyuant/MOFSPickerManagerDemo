//
//  MOFSAddressModel.h
//  MOFSPickerManager
//
//  Created by luoyuan on 16/8/31.
//  Copyright © 2016年 luoyuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GDataXMLElement;
@interface MOFSAddressModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *zipcode;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSMutableArray<MOFSAddressModel *> *list;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end

@interface MOFSAddressSelectedModel : NSObject

/**
 * 省
 */
@property (nonatomic, strong) NSString *provinceName;
@property (nonatomic, strong) NSString *provinceZipcode;
@property (nonatomic, assign) NSInteger provinceIndex;

/**
 * 市
 */
@property (nonatomic, strong) NSString *cityName;
@property (nonatomic, strong) NSString *cityZipcode;
@property (nonatomic, assign) NSInteger cityIndex;

/**
 * 区
 */
@property (nonatomic, strong) NSString *districtName;
@property (nonatomic, strong) NSString *districtZipcode;
@property (nonatomic, assign) NSInteger districtIndex;

- (instancetype)initWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName districtName:(NSString *)districtName;

+ (instancetype)initWithProvinceName:(NSString *)provinceName cityName:(NSString *)cityName districtName:(NSString *)districtName;

- (instancetype)initWithProvinceZipcode:(NSString *)provinceZipcode cityZipcode:(NSString *)cityZipcode districtZipcode:(NSString *)districtZipcode;

+ (instancetype)initWithProvinceZipcode:(NSString *)provinceZipcode cityZipcode:(NSString *)cityZipcode districtZipcode:(NSString *)districtZipcode;

- (instancetype)initWithProvinceIndex:(NSInteger)provinceIndex cityIndex:(NSInteger)cityIndex districtIndex:(NSInteger)districtIndex;

+ (instancetype)initWithProvinceIndex:(NSInteger)provinceIndex cityIndex:(NSInteger)cityIndex districtIndex:(NSInteger)districtIndex;

- (void)copyModel:(MOFSAddressSelectedModel *)model;

@end


FOUNDATION_EXPORT NSErrorDomain const MOFSSearchErrorDomain;

typedef NS_ENUM(NSInteger, MOFSSearchErrorCode) {
    MOFSSearchErrorCodeProvinceNotFound = 700,
    MOFSSearchErrorCodeCityNotFound     = 701,
    MOFSSearchErrorCodeDistrictNotFound = 702,
};

@interface MOFSSearchAddressModel : MOFSAddressSelectedModel

@property (nonatomic, strong) NSError *error;

@end
