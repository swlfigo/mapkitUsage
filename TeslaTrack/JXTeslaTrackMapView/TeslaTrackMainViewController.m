//
//  TeslaTrackMainViewController.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/3.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "TeslaTrackMainViewController.h"

@interface TeslaTrackMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *mainTableView;
@property(nonatomic,strong)NSArray *souceArray;
@end

@implementation TeslaTrackMainViewController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _souceArray = [NSArray arrayWithObjects:@"百度",@"MapBox", nil];
    _mainTableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:_mainTableView];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _souceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = _souceArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        Class class = NSClassFromString(@"TeslaTrackRouteViewController");
        UIViewController *vc = [[class alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1){
        Class class = NSClassFromString(@"TeslaTrackMapBoxViewController");
        UIViewController *vc = [[class alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
