//
//  TeslaTrackMapBoxViewController.m
//  TeslaTrack
//
//  Created by Sylar on 2019/4/3.
//  Copyright © 2019年 Sylar. All rights reserved.
//

#import "TeslaTrackMapBoxViewController.h"
#import "TeslaTrackModel.h"
#import "CustomPolyline.h"

@interface TeslaTrackMapBoxViewController ()<MGLMapViewDelegate>{
    int _currentIndex;
    NSTimer *_timer;
}
@property(nonatomic,strong)CustomPolyline *locationPolyline;
@property (nonatomic) MGLMapView *mapView;
@property (nonatomic) MGLShapeSource *polylineSource;
@property (nonatomic,strong) NSMutableArray<TeslaTrackModel *> *locations;
@property (nonatomic,assign)BOOL isUseGooSystem;
@property (nonatomic,strong)UIButton *animateButton;
@end

@implementation TeslaTrackMapBoxViewController

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
    // Do any additional setup after loading the view.
    _isUseGooSystem = NO;
    _locations = [[NSMutableArray alloc]init];
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.mapView];
    
    self.mapView.delegate = self;
    _animateButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _animateButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_animateButton];
    [_animateButton addTarget:self action:@selector(animatePolyline) forControlEvents:UIControlEventTouchUpInside];
}

// Wait until the map is loaded before adding to the map.
- (void)mapViewDidFinishLoadingMap:(MGLMapView *)mapView {
    [self configJSON];
    [self.mapView showAnnotations:@[_locationPolyline] animated:NO];
    [self.mapView addAnnotation:_locationPolyline];
    [self addPolylineToStyle:mapView.style];
//    [self animatePolyline];
}

- (void)addPolylineToStyle:(MGLStyle *)style {
    // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
    MGLShapeSource *source = [[MGLShapeSource alloc] initWithIdentifier:@"polyline" features:@[] options:nil];
    [style addSource:source];
    self.polylineSource = source;
    
    // Add a layer to style our polyline.
    MGLLineStyleLayer *layer = [[MGLLineStyleLayer alloc] initWithIdentifier:@"polyline" source:source];
    layer.lineJoin = [NSExpression expressionForConstantValue:@"round"];
    layer.lineCap = layer.lineJoin = [NSExpression expressionForConstantValue:@"round"];
    layer.lineColor = [NSExpression expressionForConstantValue:[UIColor redColor]];
    
    // The line width should gradually increase based on the zoom level.
    layer.lineWidth = [NSExpression expressionWithFormat:@"mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
  @{@14: @5, @18: @20}];
    [self.mapView.style addLayer:layer];
}

- (void)animatePolyline {
    _currentIndex = 1;
    
    // Start a timer that will simulate adding points to our polyline. This could also represent coordinates being added to our polyline from another source, such as a CLLocationManagerDelegate.
    [self.mapView removeAnnotation:_locationPolyline];
    [self.mapView setZoomLevel:12.0f animated:YES];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)tick {
    if (_currentIndex > self.locations.count) {
        [_timer invalidate];
        _timer = nil;
//        [self.mapView resetPosition];
        [self.mapView addAnnotation:_locationPolyline];
        [self.mapView showAnnotations:@[_locationPolyline] animated:YES];
        CLLocationCoordinate2D coordinates[1];
        if (_isUseGooSystem) {
            coordinates[0] = self.locations[0].goolocation.coordinate;
        }else{
            coordinates[0] = self.locations[0].baidulocation.coordinate;
        }
        
        MGLPolylineFeature *polyline = [MGLPolylineFeature polylineWithCoordinates:coordinates count:1];
        self.polylineSource.shape = polyline;
        return;
    }
    
    // Create a subarray of locations up to the current index.
    NSArray *currentLocations = [self.locations subarrayWithRange:NSMakeRange(0, _currentIndex)];
    
    // Update our MGLShapeSource with the current locations.
    [self updatePolylineWithLocations:currentLocations];
    
    _currentIndex++;
}

- (void)updatePolylineWithLocations:(NSArray<TeslaTrackModel *> *)telsaTrackModelArray {
    CLLocationCoordinate2D coordinates[telsaTrackModelArray.count];
    
    for (NSUInteger i = 0; i < telsaTrackModelArray.count; i++) {
        if (_isUseGooSystem) {
            coordinates[i] = telsaTrackModelArray[i].goolocation.coordinate;
        }else{
            coordinates[i] = telsaTrackModelArray[i].baidulocation.coordinate;
        }
        
    }
    
    MGLPolylineFeature *polyline = [MGLPolylineFeature polylineWithCoordinates:coordinates count:telsaTrackModelArray.count];
    
    self.polylineSource.shape = polyline;
    if (_isUseGooSystem) {
        [self.mapView setCenterCoordinate:telsaTrackModelArray.lastObject.goolocation.coordinate animated:YES];
    }else{
        [self.mapView setCenterCoordinate:telsaTrackModelArray.lastObject.baidulocation.coordinate animated:YES];
    }

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
        _locationPolyline = [CustomPolyline polylineWithCoordinates:coordinatesPoint count:locationMaxCountArray.count];
        
        free(coordinatesPoint);
        

    }
}
@end
