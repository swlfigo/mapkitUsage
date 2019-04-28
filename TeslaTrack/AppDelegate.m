//
//  AppDelegate.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/1.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "AppDelegate.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "JXTeslaTrackLoginManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    BMKMapManager *mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [mapManager start:@"GfWCtadaas2MpgpSCDQUdcbR5GFkHN2f"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }else{
        NSLog(@"manager start success!");
    }
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    Class mainVCClass = NSClassFromString(@"TeslaTrackRouteViewController");
    Class loginVCClass = NSClassFromString(@"JXTeslaTrackLoginViewController");
    
    
    [JXTeslaTrackLoginManager shareInstance].isLogined = YES;
    [JXTeslaTrackLoginManager shareInstance].userTeslaID = @"67002747908124670";
    
    if ([JXTeslaTrackLoginManager shareInstance].logined == YES) {
        //已登录
        UIViewController *mainVC = [[mainVCClass alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainVC];
        self.window.rootViewController = nav;
    }else{
        UIViewController *loginVC = [[loginVCClass alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
        self.window.rootViewController = nav;
        
    }

    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
