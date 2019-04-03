//
//  CustomPointAnnotation.h
//  TeslaTrack
//
//  Created by Sylar on 2019/3/28.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import <Mapbox/Mapbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomPointAnnotation : MGLPointAnnotation

@property(nonatomic,strong)NSString *reuseIdentifier;
@property(nonatomic,strong)UIImage *image;
@end

NS_ASSUME_NONNULL_END
