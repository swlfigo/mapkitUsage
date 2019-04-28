//
//  JXTeslaTrackLoginManager.h
//  TeslaTrack
//
//  Created by Sylar on 2019/4/25.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JXTeslaTrackLoginManager : NSObject
+(instancetype) shareInstance;
@property(nonatomic,assign,getter= logined )BOOL isLogined;
@property(nonatomic,strong)NSString *userTeslaID;
@end

NS_ASSUME_NONNULL_END
