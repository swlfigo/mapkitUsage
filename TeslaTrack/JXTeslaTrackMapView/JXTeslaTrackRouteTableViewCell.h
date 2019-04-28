//
//  JXTeslaTrackRouteTableViewCell.h
//  TeslaTrack
//
//  Created by Sylar on 2019/4/28.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TeslaRouteModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface JXTeslaTrackRouteTableViewCell : UITableViewCell

@property(nonatomic,strong)UIImageView *routeMapImageView;
@property(nonatomic,strong)UILabel *statLocationLabel;
@property(nonatomic,strong)UILabel *endLocationLabel;
@property(nonatomic,strong)TeslaRouteModel *routeModel;
@end

NS_ASSUME_NONNULL_END
