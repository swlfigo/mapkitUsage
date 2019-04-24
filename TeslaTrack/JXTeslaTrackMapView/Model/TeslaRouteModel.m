//
//  TeslaRouteModel.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/19.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "TeslaRouteModel.h"

@implementation TeslaRouteModel
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"routeID" : @"id",
             };
}
@end
