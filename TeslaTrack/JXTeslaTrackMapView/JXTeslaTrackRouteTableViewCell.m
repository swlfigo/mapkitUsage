//
//  JXTeslaTrackRouteTableViewCell.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/28.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "JXTeslaTrackRouteTableViewCell.h"

@interface JXTeslaTrackRouteTableViewCell ()


@end

@implementation JXTeslaTrackRouteTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configUI];
    }
    return self;
}

-(void)configUI{
    _routeMapImageView = [[UIImageView alloc]init];
    [self.contentView addSubview:_routeMapImageView];
    
    _statLocationLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_statLocationLabel];
    _endLocationLabel = [[UILabel alloc]init];
    [self.contentView addSubview:_endLocationLabel];
}


- (void)setRouteModel:(TeslaRouteModel *)routeModel{
    _routeModel = routeModel;
    
    [_routeMapImageView sd_setImageWithURL:[NSURL URLWithString:_routeModel.routeMapImageURL] placeholderImage:nil];
    _routeMapImageView.frame = CGRectMake(10, 12, _routeModel.coverWidth, _routeModel.coverHeight);
    
    _statLocationLabel.text = routeModel.starLocationName;
    [_statLocationLabel sizeToFit];
    _statLocationLabel.frame = CGRectMake(10, CGRectGetMaxY(_routeMapImageView.frame) + 10, MIN(_statLocationLabel.frame.size.width, [UIScreen mainScreen].bounds.size.width / 2 - 30), 20);
    
    _endLocationLabel.text = routeModel.endLocationName;
    [_endLocationLabel sizeToFit];
    _endLocationLabel.frame = CGRectMake(CGRectGetMaxX(_statLocationLabel.frame) + 20, CGRectGetMaxY(_routeMapImageView.frame) + 10, MIN(_endLocationLabel.frame.size.width, [UIScreen mainScreen].bounds.size.width / 2 - 30), 20);
    
}
@end
