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
             @"routeMapImageURL":@"url",
             @"starLocationName":@"start.name",
             @"endLocationName":@"end.name",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    
    _coverWidth = [UIScreen mainScreen].bounds.size.width - 12 * 2;
    _coverHeight = ceil(_coverWidth * 3 / 4.0f);
    _cellHeight = 10 + _coverHeight + 10 + 20 + 10 + 20+ 5;
    return YES;
}
@end
