//
//  JXTeslaTrackLoginManager.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/25.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "JXTeslaTrackLoginManager.h"

@implementation JXTeslaTrackLoginManager

static JXTeslaTrackLoginManager* _instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        NSUserDefaults *defalut = [NSUserDefaults standardUserDefaults];
        [defalut registerDefaults:@{@"logined":@(NO),@"userID":@""}];
        _instance.isLogined = [defalut boolForKey:@"logined"];
        _instance.userTeslaID = [defalut valueForKey:@"userID"];
    }) ;
    
    return _instance ;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [JXTeslaTrackLoginManager shareInstance] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [JXTeslaTrackLoginManager shareInstance] ;
}

@end
