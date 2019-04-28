//
//  TeslaRouteModel.h
//  TeslaTrack
//
//  Created by Sylar on 2019/4/19.
//  Copyright © 2019年 Sylar. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <NSObject+YYModel.h>
NS_ASSUME_NONNULL_BEGIN

@interface TeslaRouteModel : NSObject

@property(nonatomic,strong)NSString *routeID;
@property(nonatomic,strong)NSString *routeMapImageURL;
@property(nonatomic,strong)NSString *starLocationName;
@property(nonatomic,strong)NSString *endLocationName;


//偷懒Cell计算写在此处
@property(nonatomic,assign)CGFloat cellHeight;
@property(nonatomic,assign)CGFloat coverWidth;
@property(nonatomic,assign)CGFloat coverHeight;

@end

NS_ASSUME_NONNULL_END
