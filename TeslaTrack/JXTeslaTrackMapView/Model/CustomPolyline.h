//
//  CustomPolyline.h
//  TeslaTrack
//
//  Created by Sylar on 2019/3/28.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import <Mapbox/Mapbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomPolyline : MGLPolyline
@property(nonatomic,strong)UIColor *color;
@end

NS_ASSUME_NONNULL_END
