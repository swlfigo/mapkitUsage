//
//  JXTeslaTrackLoginViewController.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/25.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "JXTeslaTrackLoginViewController.h"
#import "JXTeslaTrackLoginManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

@interface JXTeslaTrackLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation JXTeslaTrackLoginViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _usernameTextField.text = @"819841106@qq.com";
    _passwordTextField.text = @"Jin10Ceshi";
    
}


- (IBAction)loginMethod:(UIButton *)sender {
    if ( (_usernameTextField.text && _usernameTextField.text.length > 0) && (_passwordTextField.text && _passwordTextField.text.length > 0) ) {
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",nil];
        
        
        
        NSString *urlString = [NSString stringWithFormat:@"http://47.111.65.165:8088/setCarAccout"];
        MBProgressHUD *hudView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hudView.mode = MBProgressHUDModeText;
        hudView.label.text = @"Loading";
        [manager POST:urlString parameters:@{@"name":_usernameTextField.text,@"pwd":_passwordTextField.text} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = responseObject;
                if (dic[@"status"] && [dic[@"status"]integerValue] == 200) {
                    NSArray *dataArray = dic[@"data"];
                    if ([dataArray isKindOfClass:[NSArray class]] &&  dataArray.count) {
                        [JXTeslaTrackLoginManager shareInstance].isLogined = YES;
                        [JXTeslaTrackLoginManager shareInstance].userTeslaID = [NSString stringWithFormat:@"%@",dataArray[0]];
                        [self successLogin];
                        return ;
                    }
                }
                
            }
            [self failLogin];

            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            [self failLogin];
        }];
        
    }
}

-(void)failLogin{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"登陆失败";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
}



-(void)successLogin{
    Class mainVCClass = NSClassFromString(@"TeslaTrackRouteViewController");
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[[mainVCClass alloc]init]];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    [[UIApplication  sharedApplication].keyWindow makeKeyAndVisible];
}


@end
