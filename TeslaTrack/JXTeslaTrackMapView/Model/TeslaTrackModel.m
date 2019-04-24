//
//  TeslaTrackModel.m
//  TeslaTrack
//
//  Created by Sylar on 2019/3/29.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "TeslaTrackModel.h"

@implementation TeslaTrackModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
//             @"gooLatitude" : @"goo_lat",
             @"gooLatitude" : @"correctedLatitude",
             @"gooLongitude" : @"correctedLongitude",
             @"baiduLatitude" : @"bdm_lat",
             @"baiduLongitude":@"bdm_long",
             @"speed":@"speed",
//             @"shiftState":@"shift_state",
             @"shiftState":@"shiftState",
             @"timeStamp":@"timestamp",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    _goolocation = [[CLLocation alloc]initWithLatitude:_gooLatitude longitude:_gooLongitude];
    _baidulocation = [[CLLocation alloc]initWithLatitude:_baiduLatitude longitude:_baiduLongitude];
    return YES;
}
@end
