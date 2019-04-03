//
//  TeslaTrackModel.h
//  TeslaTrack
//
//  Created by Sylar on 2019/3/29.
//  Copyright © 2019年 Sylar. All rights reserved.
//
#import <UIKit/UIKit.h>

#import <Foundation/Foundation.h>
#import <NSObject+YYModel.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN

@interface TeslaTrackModel : NSObject

@property(nonatomic,assign)CGFloat gooLatitude;
@property(nonatomic,assign)CGFloat gooLongitude;
@property(nonatomic,assign)CGFloat baiduLatitude;
@property(nonatomic,assign)CGFloat baiduLongitude;
@property(nonatomic,assign)CGFloat speed;
@property(nonatomic)CLLocation *goolocation;
@property(nonatomic)CLLocation *baidulocation;
@property(nonatomic,strong)NSString *shiftState;
@end

NS_ASSUME_NONNULL_END
