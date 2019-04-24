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

@interface TeslaTrackRouteViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *mainTableView;
@property(nonatomic,strong)NSMutableArray<TeslaRouteModel*> *souceArray;
@property (nonatomic, strong) NSURLSessionTask *operation; // 请求操作
@end

@implementation TeslaTrackRouteViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _souceArray = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    _mainTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:_mainTableView];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    [self requestData];
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)requestData{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 设置请求头
    [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    // 设置接收的Content-Type
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//返回格式 JSON
    //设置返回C的ontent-type
    manager.responseSerializer.acceptableContentTypes=[[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    
    
    NSString *urlString = [NSString stringWithFormat:@"http://47.111.65.165:8088/getUserCarRecordList?car_id=67002747908124670"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = _souceArray[indexPath.row].routeID;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TeslaTrackMapViewController *vc = [[TeslaTrackMapViewController alloc]init];
    vc.routeID = _souceArray[indexPath.row].routeID;
    [self.navigationController pushViewController:vc animated:YES];
}

@end