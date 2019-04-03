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

@interface TeslaTrackMapViewController ()<BMKMapViewDelegate>{
    NSTimer *_timer;
}
@property(nonatomic,strong)BMKPolyline *customPolyline;
@property(nonatomic,strong)BMKMapView *mapView;
@property (nonatomic,strong) NSMutableArray<TeslaTrackModel *> *locations;
@property(nonatomic,assign)CGFloat animationTime;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic,assign)CGFloat zoomLevel;
@property (nonatomic,assign)BOOL isUseGooSystem;
@property (nonatomic,strong)UIButton *animateButton;
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
    _isUseGooSystem = NO;
    _animationTime = 0.05;
    _currentIndex = 1;
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
    
    [self configJSON];
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
        [_mapView removeOverlay:_customPolyline];
        [_mapView addOverlay:_customPolyline];
        [_mapView showAnnotations:@[_customPolyline] animated:YES];
        _mapView.zoomLevel = _zoomLevel;
        _animateButton.hidden = NO;
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
        for (int i = 0; i < locationMaxCountArray.count; ++i) {
            TeslaTrackModel *model = locationMaxCountArray[i];
            [_locations addObject:model];
            if (_isUseGooSystem) {
                coordinatesPoint[i] = CLLocationCoordinate2DMake(model.gooLatitude, model.gooLongitude);
            }else{
                coordinatesPoint[i] = CLLocationCoordinate2DMake(model.baiduLatitude, model.baiduLongitude);
            }

            if (model.speed < 30 ) {
                [colorArray addObject:@(0)];
            }else if (model.speed > 30 && model.speed < 70){
                [colorArray addObject:@(1)];
            }else{
                [colorArray addObject:@(2)];
            }
        }
        
        //configDraw
        _customPolyline = [BMKPolyline polylineWithCoordinates:coordinatesPoint count:locationMaxCountArray.count textureIndex:colorArray];
        
        free(coordinatesPoint);
        

        
        
    }
}

- (void)mapViewDidFinishLoading:(BMKMapView *)mapView{

}

- (void)mapViewDidFinishRendering:(BMKMapView *)mapView{
    [_mapView addOverlay:_customPolyline];
    
    [_mapView showAnnotations:@[_customPolyline] animated:YES];
    
    _zoomLevel = _mapView.zoomLevel;
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
@end
