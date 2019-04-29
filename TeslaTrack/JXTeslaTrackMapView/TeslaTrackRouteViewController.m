//
//  TeslaTrackRouteViewController.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/15.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "TeslaTrackRouteViewController.h"
#import "TeslaTrackMapViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "TeslaRouteModel.h"
#import "JXTeslaTrackLoginManager.h"
#import "JXTeslaTrackRouteTableViewCell.h"
@interface TeslaTrackRouteViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *mainTableView;
@property(nonatomic,strong)NSMutableArray<TeslaRouteModel*> *souceArray;
@property (nonatomic, strong) NSURLSessionTask *operation; // 请求操作
@end

@implementation TeslaTrackRouteViewController

- (void)dealloc
{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _souceArray = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    _mainTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_mainTableView registerClass:[JXTeslaTrackRouteTableViewCell class] forCellReuseIdentifier:NSStringFromClass([JXTeslaTrackRouteTableViewCell class])];
    
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStylePlain target:self action:@selector(exitLogin)];
    self.navigationItem.rightBarButtonItem = anotherButton;

    
    [self.view addSubview:_mainTableView];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [self requestData];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)exitLogin{
    Class loginVCClass = NSClassFromString(@"JXTeslaTrackLoginViewController");
    UIViewController *loginVC = [[loginVCClass alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
    [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    [[UIApplication  sharedApplication].keyWindow makeKeyAndVisible];
}

-(void)requestData{
    
    if ([JXTeslaTrackLoginManager shareInstance].isLogined == NO || ![JXTeslaTrackLoginManager shareInstance].userTeslaID) return;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 设置请求头
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    // 设置接收的Content-Type
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//返回格式 JSON
    //设置返回C的ontent-type
    manager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://47.111.65.165:8088/getUserCarRecordList?car_id=%@",[JXTeslaTrackLoginManager shareInstance].userTeslaID];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Loading";
    self.operation = [manager GET:urlString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *routeDic = responseObject;
            if ([routeDic isKindOfClass:[NSDictionary class]]) {
                NSArray *routeArray = routeDic[@"data"];
                if (routeArray && [routeArray isKindOfClass:[NSArray class]]) {
                    for (int i = 0; i < routeArray.count; ++i) {
                        TeslaRouteModel *model = [TeslaRouteModel yy_modelWithJSON:routeArray[i]];
                        [_souceArray addObject:model];
                    }
                    [_mainTableView reloadData];
                }
                
            }
            [hud hideAnimated:YES];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
}


#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _souceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JXTeslaTrackRouteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JXTeslaTrackRouteTableViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.routeModel = _souceArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _souceArray[indexPath.row].cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TeslaTrackMapViewController *vc = [[TeslaTrackMapViewController alloc]init];
    vc.routeID = _souceArray[indexPath.row].routeID;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
