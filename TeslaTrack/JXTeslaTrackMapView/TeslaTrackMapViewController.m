//
//  TeslaTrackMapViewController.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/1.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "TeslaTrackMapViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import "TeslaTrackModel.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface TeslaTrackMapViewController ()<BMKMapViewDelegate>{
    NSTimer *_timer;
}
@property(nonatomic,strong)BMKPolyline *customPolyline;
@property(nonatomic,strong)BMKMapView *mapView;
@property (nonatomic,strong) NSMutableArray<TeslaTrackModel *> *locations;

@property (nonatomic) NSInteger currentIndex;
@property (nonatomic,assign)BOOL isUseGooSystem;
@property (nonatomic,strong)UIButton *animateButton;

@property(nonatomic,assign)CGFloat centerLng;
@property(nonatomic,assign)CGFloat centerLat;
@property(nonatomic,assign)CGFloat oriZoomLevel;
@property(nonatomic,strong)BMKMapStatus *mapStatue;

@property (nonatomic, strong) NSURLSessionTask *operation; // 请求操作

@property (nonatomic, assign) CLLocationDistance totalDistance; //总长度
@property (nonatomic, assign) NSInteger totalTime;
@property(nonatomic,assign)CGFloat animationTime; //动画每秒时长
@end

@implementation TeslaTrackMapViewController

- (void)dealloc
{
    
    _mapView.delegate = nil;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_timer invalidate];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isUseGooSystem = YES;
    
    _currentIndex = 1;
    _totalTime = _totalDistance = 0;
    _animationTime = 0.05;
    //设置为GCJ02坐标
    if (_isUseGooSystem) {
       [BMKMapManager setCoordinateTypeUsedInBaiduMapSDK: BMK_COORDTYPE_COMMON];
    }else{
        [BMKMapManager setCoordinateTypeUsedInBaiduMapSDK: BMK_COORDTYPE_BD09LL];
    }

    
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    _locations = [[NSMutableArray alloc]init];
    UIButton *switchBtn = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 0, 60, 60)];
    switchBtn.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:switchBtn];
    [switchBtn addTarget:self action:@selector(switchMapTypeMethod:) forControlEvents:UIControlEventTouchUpInside];
    
    _animateButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _animateButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_animateButton];
    [_animateButton addTarget:self action:@selector(beginAnimate:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self configJSON];
    [self requestData];
}


#pragma mark - Animate
-(void)beginAnimate:(UIButton*)sender{
    _currentIndex = 1;
    _animateButton.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _mapView.zoomLevel = 15;
        _timer = [NSTimer scheduledTimerWithTimeInterval:_animationTime target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    });
    
}

- (void)tick:(NSTimer*)timer {

    if (self.currentIndex >= self.locations.count) {
        [_timer invalidate];
//        [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(_centerLat, _centerLng) animated:YES];
//        _mapView.zoomLevel = _oriZoomLevel;
//
//        [_mapView showAnnotations:@[_customPolyline] animated:YES];
        _animateButton.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_mapView setMapStatus:_mapStatue withAnimation:YES withAnimationTime:3.0f];

        });

    }
    NSArray<TeslaTrackModel*> *currentLocations = [self.locations subarrayWithRange:NSMakeRange(0, _currentIndex)];
    @autoreleasepool {
        CLLocationCoordinate2D coordinates[currentLocations.count];
        
        for (NSUInteger i = 0; i < currentLocations.count; i++) {
            if (_isUseGooSystem) {
                coordinates[i] = currentLocations[i].goolocation.coordinate;
            }else{
                coordinates[i] = currentLocations[i].baidulocation.coordinate;
            }
            
        }
        [_customPolyline setPolylineWithCoordinates:coordinates count:currentLocations.count];
        
        if (_isUseGooSystem) {
            [_mapView setCenterCoordinate:(currentLocations.lastObject).goolocation.coordinate animated:YES];
        }else{
            [_mapView setCenterCoordinate:(currentLocations.lastObject).baidulocation.coordinate animated:YES];
        }

    }
    _currentIndex += 1;
    
    
}

#pragma mark - SwitchType
-(void)switchMapTypeMethod:(UIButton*)sender{
    static NSInteger mapType = 0;
    if (mapType % 2 == 1) {
        [_mapView setMapType:BMKMapTypeStandard]; //切换为标准地图
    }else{
        [_mapView setMapType:BMKMapTypeSatellite]; //切换为标准地图
    }
    mapType += 1;
}

#pragma mark Parser JSON
-(void)configJSON{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"position"
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    NSMutableArray<TeslaTrackModel*> *locationModels = [[NSMutableArray alloc]init];
    NSMutableArray<NSArray*> *timesArray = [[NSMutableArray alloc]init];  //每次
    
    if (!error && data[@"RECORDS"]) {
        NSArray *array = data[@"RECORDS"];
        for (int i = 0 ; i < array.count; ++i) {
            TeslaTrackModel *model = [TeslaTrackModel yy_modelWithJSON:array[i]];
            [locationModels addObject:model];
        }
        
        //分离P档
        NSInteger beginIndex = 0;
        for (int i = 0; i < locationModels.count; ++i) {
            if ([locationModels[i].shiftState isEqualToString:@"P"]) {
                NSArray *perArray = [locationModels subarrayWithRange:NSMakeRange(beginIndex, i - beginIndex)];
                [timesArray addObject:perArray];
                beginIndex = i + 1;
            }
        }
        
        if (!timesArray.count) return;
        
        //取最大
        NSInteger maxCountArrayIndex = 0;
        for (int i = 0; i < timesArray.count; ++i) {
            if (timesArray[i].count > timesArray[maxCountArrayIndex].count) {
                maxCountArrayIndex = i;
            }
        }
        
        
        
        NSArray *locationMaxCountArray = timesArray[maxCountArrayIndex];
        
        //DrawArray
        CLLocationCoordinate2D *coordinatesPoint = (CLLocationCoordinate2D *)malloc(locationMaxCountArray.count  * sizeof(CLLocationCoordinate2D));
        NSMutableArray *colorArray = [[NSMutableArray alloc]init];
        
        //Fix
        CGFloat maxLng = 0,minLng = 0 ,maxLat = 0,minLat = 0;
        
        for (int i = 0; i < locationMaxCountArray.count; ++i) {
            TeslaTrackModel *model = locationMaxCountArray[i];
            [_locations addObject:model];
            if (i == 0) {
                if (_isUseGooSystem) {
                    maxLng = model.gooLongitude;
                    minLng = model.gooLongitude;
                    maxLat = model.gooLatitude;
                    minLat = model.gooLatitude;
                }else{
                    maxLng = model.baiduLongitude;
                    minLng = model.baiduLongitude;
                    maxLat = model.baiduLatitude;
                    minLat = model.baiduLatitude;
                }
            }
            if (_isUseGooSystem) {
                coordinatesPoint[i] = CLLocationCoordinate2DMake(model.gooLatitude, model.gooLongitude);
                if (model.gooLongitude > maxLng) maxLng = model.gooLongitude;
                if (model.gooLongitude < minLng) minLng = model.gooLongitude;
                if (model.gooLatitude > maxLat) maxLat = model.gooLatitude;
                if (model.gooLatitude < minLat) minLat = model.gooLatitude;
                
            }else{
                coordinatesPoint[i] = CLLocationCoordinate2DMake(model.baiduLatitude, model.baiduLongitude);
                
                if (model.baiduLongitude > maxLng) maxLng = model.baiduLongitude;
                if (model.baiduLongitude < minLng) minLng = model.baiduLongitude;
                if (model.baiduLatitude > maxLat) maxLat = model.baiduLatitude;
                if (model.baiduLatitude < minLat) minLat = model.baiduLatitude;
            }

            if (model.speed < 30 ) {
                [colorArray addObject:@(0)];
            }else if (model.speed > 30 && model.speed < 70){
                [colorArray addObject:@(1)];
            }else{
                [colorArray addObject:@(2)];
            }
        }
        _centerLng = (maxLng + minLng) / 2.0f;
        _centerLat = (maxLat + minLat) / 2.0f;
        NSArray *zoomArray = @[@"50",@"100",@"200",@"500",@"1000",@"2000",@"5000",@"10000",@"20000",@"25000",@"50000",@"100000",@"200000",@"500000",@"1000000",@"2000000"];
        BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(maxLat, maxLng));
        
        BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(minLat,minLng));
        
        CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
        
        
        
        for (int i = 0 ; i < zoomArray.count; ++i) {
            if ([zoomArray[i] floatValue] - distance > 0) {
                _oriZoomLevel = 18 - i + 3;
                break;
            }
        }
        
        
        //configDraw
        _customPolyline = [BMKPolyline polylineWithCoordinates:coordinatesPoint count:locationMaxCountArray.count textureIndex:colorArray];
        
        
        
        free(coordinatesPoint);
        

        
        
    }
}




- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{
//    _mapView.zoomLevel = _oriZoomLevel;
//
//    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(_centerLat, _centerLng) animated:YES];
//
//    [_mapView addOverlay:_customPolyline];
//
//    [_mapView showAnnotations:@[_customPolyline] animated:YES];
//
//    _mapStatue = [_mapView getMapStatus];
    
    
}

- (void)mapViewDidFinishRendering:(BMKMapView *)mapView{

    
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [UIColor redColor];
        polylineView.lineWidth = 2.0;
        polylineView.colors = [NSArray arrayWithObjects:[UIColor redColor], [UIColor yellowColor], [UIColor greenColor], nil];
        return polylineView;
    }
    return nil;
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
    

    NSString *urlString = [NSString stringWithFormat:@"http://47.111.65.165:8088/getUserCarRecordDetail?car_id=67002747908124670&log_id=%@",self.routeID];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.label.text = @"Loading";
    self.operation = [manager GET:urlString parameters:@{} progress:^(NSProgress * _Nonnull downloadProgress) {
        hud.progressObject = downloadProgress;
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (![responseObject isKindOfClass:[NSDictionary class]]) return ;
            NSDictionary *dataDic = responseObject[@"data"][@"attr"];
            if (![dataDic isKindOfClass:[NSDictionary class]]) return;
            NSMutableArray *dataArrayTemp = [[NSMutableArray alloc]init];
            [dataDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                [dataArrayTemp addObject:obj];
            }];
            NSSortDescriptor *classWithSort = [[NSSortDescriptor alloc]initWithKey:@"timestamp" ascending:YES];
             NSArray *dataArray = [dataArrayTemp sortedArrayUsingDescriptors:@[classWithSort]];       //使用描述器排序
            
            NSMutableArray<TeslaTrackModel*> *locationModels = [[NSMutableArray alloc]init];
            
            for (int i = 0 ; i < dataArray.count; ++i) {
                TeslaTrackModel *model = [TeslaTrackModel yy_modelWithJSON:dataArray[i]];
                [locationModels addObject:model];
            }
            
            //DrawArray
            CLLocationCoordinate2D *coordinatesPoint = (CLLocationCoordinate2D *)malloc(locationModels.count  * sizeof(CLLocationCoordinate2D));
            NSMutableArray *colorArray = [[NSMutableArray alloc]initWithCapacity:locationModels.count];
            
            //Fix
            CGFloat maxLng = 0,minLng = 0 ,maxLat = 0,minLat = 0;
            
            for (int i = 0; i < locationModels.count; ++i) {
                TeslaTrackModel *model = locationModels[i];
                [_locations addObject:model];
                if (i != locationModels.count - 1) {
                    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(model.gooLatitude, model.gooLongitude));
                    TeslaTrackModel *modelNext = locationModels[i+1];
                    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(modelNext.gooLatitude,modelNext.gooLongitude));
                    _totalTime += modelNext.timeStamp - model.timeStamp;
                    _totalDistance += BMKMetersBetweenMapPoints(point1,point2);
                }
                if (i == 0) {
                    if (_isUseGooSystem) {
                        maxLng = model.gooLongitude;
                        minLng = model.gooLongitude;
                        maxLat = model.gooLatitude;
                        minLat = model.gooLatitude;
                    }else{
                        maxLng = model.baiduLongitude;
                        minLng = model.baiduLongitude;
                        maxLat = model.baiduLatitude;
                        minLat = model.baiduLatitude;
                    }
                }
                if (_isUseGooSystem) {
                    coordinatesPoint[i] = CLLocationCoordinate2DMake(model.gooLatitude, model.gooLongitude);
                    if (model.gooLongitude > maxLng) maxLng = model.gooLongitude;
                    if (model.gooLongitude < minLng) minLng = model.gooLongitude;
                    if (model.gooLatitude > maxLat) maxLat = model.gooLatitude;
                    if (model.gooLatitude < minLat) minLat = model.gooLatitude;
                    
                }else{
                    coordinatesPoint[i] = CLLocationCoordinate2DMake(model.baiduLatitude, model.baiduLongitude);
                    
                    if (model.baiduLongitude > maxLng) maxLng = model.baiduLongitude;
                    if (model.baiduLongitude < minLng) minLng = model.baiduLongitude;
                    if (model.baiduLatitude > maxLat) maxLat = model.baiduLatitude;
                    if (model.baiduLatitude < minLat) minLat = model.baiduLatitude;
                }
                
                if (model.speed < 30 ) {
                    [colorArray addObject:@(0)];
                }else if (model.speed > 30 && model.speed < 70){
                    [colorArray addObject:@(1)];
                }else{
                    [colorArray addObject:@(2)];
                }
            }
            if (_locations.count > 2) {
                //可计算时间
                //毫秒
                NSInteger maxTime = _locations.lastObject.timeStamp;
                NSInteger minTime = _locations.firstObject.timeStamp;
                //现实路上每秒走的速度
                CGFloat avgSpeed = _totalDistance /  ((maxTime - minTime) / 1000);
                CGFloat time = (1 / avgSpeed) - 0.02;
                if (time > 1) {
                    _animationTime = avgSpeed;
                    
                }else{
                   _animationTime = time;
                }
                
                
            }
            
            _centerLng = (maxLng + minLng) / 2.0f;
            _centerLat = (maxLat + minLat) / 2.0f;
            NSArray *zoomArray = @[@"50",@"100",@"200",@"500",@"1000",@"2000",@"5000",@"10000",@"20000",@"25000",@"50000",@"100000",@"200000",@"500000",@"1000000",@"2000000"];
            BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(maxLat, maxLng));
            
            BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(minLat,minLng));
            
            CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
            
            
            
            for (int i = 0 ; i < zoomArray.count; ++i) {
                if ([zoomArray[i] floatValue] - distance > 0) {
                    _oriZoomLevel = 18 - i + 3;
                    break;
                }
            }
            
            
            //configDraw
            _customPolyline = [BMKPolyline polylineWithCoordinates:coordinatesPoint count:locationModels.count textureIndex:colorArray];
            
            free(coordinatesPoint);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _mapView.zoomLevel = _oriZoomLevel;
            
                [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(_centerLat, _centerLng) animated:YES];
            
                [_mapView addOverlay:_customPolyline];
            
                [_mapView showAnnotations:@[_customPolyline] animated:YES];
            
                _mapStatue = [_mapView getMapStatus];
                
                [hud hideAnimated:YES];
            });
            
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [hud hideAnimated:YES];
    }];
}

@end
