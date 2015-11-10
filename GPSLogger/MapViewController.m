//
//  MapViewController.m
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GPX.h"
#import "MapViewController.h"
#import "TrackPoint.h"
#import "IBCoreDataStore.h"
#import "IBFunctions.h"
#import "NSManagedObject+InnerBand.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"
#import "PhotoViewController.h"

@interface MapViewController ()
//- (id <RMTileSource>)getTilesource;
- (void)showLog;
- (void)updateOverlay;
@end

@interface MapViewController (MGLMapViewDelegate)  <MGLMapViewDelegate>

@end

@interface MapViewController (MWPhotoBrowserDelegate) <MWPhotoBrowserDelegate>

@end

@interface TrackPointAnnotation : MGLPointAnnotation
@property (nonatomic,strong) UIImage * trackImage;
@end
//
//@interface TrackLineAnnotation : RMPolylineAnnotation
//
//@end

@implementation MapViewController

@synthesize mapView = __mapView;
@synthesize track = __track;


#define STREETS_MAP_ID @"examples.map-vyofok3q"

#define TERRAIN_MAP_ID @"hanchao.i8ao15fd"

#define SATELLITE_MAP_ID @"examples.map-qfyrx5r8"

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.mapView];
    
    self.mapView.showsUserLocation = YES;
    
    self.mapView.delegate = self;
    
//    id <RMTileSource> tileSource = [self getTilesource];
//    
//    if(tileSource == nil)
//        return;
//    
//    
//    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:tileSource];
//    
//    [self.view addSubview:self.mapView];
//    
//    self.mapView.showsUserLocation = YES;
//    
//    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    
//    self.mapView.delegate = self;
    
    if (self.track) {
        [self showLog];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateOverlay];
    [self performSelector:@selector(updateOverlay) withObject:nil afterDelay:0.5];
//    
//    RMUserTrackingBarButtonItem *userTrackingBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
//    
//    UIBarButtonItem *rightBarButtonItem = self.tabBarController.navigationItem.rightBarButtonItem;
//    self.tabBarController.navigationItem.rightBarButtonItems = @[rightBarButtonItem,userTrackingBarButtonItem];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UIBarButtonItem *rightBarButtonItem = self.tabBarController.navigationItem.rightBarButtonItem;
    
    self.tabBarController.navigationItem.rightBarButtonItems = @[rightBarButtonItem];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)update
{
    [self updateOverlay];
}

//- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
//{
//    if (![annotation isKindOfClass:[TrackPointAnnotation class]]) {
//        return;
//    }
//    
//    TrackPointAnnotation *trackPointAnnotation = (TrackPointAnnotation *)annotation;
//
//    MWPhoto *photo = [MWPhoto photoWithImage:trackPointAnnotation.trackImage];
//    photo.caption = trackPointAnnotation.title;
//    
//    PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
//    
//    photoViewController.photo = photo;
//    
//    [self.navigationController pushViewController:photoViewController animated:YES];
//}

#pragma mark - Private methods

//- (id <RMTileSource>)getTilesource
//{
//    RMMapboxSource *tileSource;
//    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *tileJSON = [defaults stringForKey:TERRAIN_MAP_ID];
//    if (tileJSON)
//    {
//        tileSource = [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
//    }
//    else
//    {
//        tileSource = [[RMMapboxSource alloc] initWithMapID:TERRAIN_MAP_ID];
//        if (tileSource)
//        {
//            [defaults setObject:tileSource.tileJSON forKey:TERRAIN_MAP_ID];
//            [defaults synchronize];
//        }
//    }
//    return tileSource;
//}

- (void)showLog
{
    [self updateOverlay];
    
    if (self.track.trackpoints.count == 0) {
        // initialize map position
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.907333, 116.391083);
        
        //[self.mapView setZoom:12 atCoordinate:coordinate animated:NO];
        [self.mapView setCenterCoordinate:coordinate
                                zoomLevel:12
                                 animated:NO];
        
        //self.mapView.userTrackingMode = RMUserTrackingModeFollow;
        self.mapView.userTrackingMode = MGLUserTrackingModeFollow;

        return;
    }
    
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
//    
//    CLLocationCoordinate2D southWest;
//    CLLocationCoordinate2D northEast;
//    
//    southWest.longitude = 180;
//    southWest.latitude = 90;
//    northEast.longitude = -180;
//    northEast.latitude = -90;
//    for (TrackPoint *trackPoint in self.track.trackpoints) {
//        if (trackPoint.longitude.floatValue < southWest.longitude) {
//            southWest.longitude = trackPoint.longitude.floatValue;
//        }
//        if (trackPoint.longitude.floatValue > northEast.longitude) {
//            northEast.longitude = trackPoint.longitude.floatValue;
//        }
//        if (trackPoint.latitude.floatValue < southWest.latitude) {
//            southWest.latitude = trackPoint.latitude.floatValue;
//        }
//        if (trackPoint.latitude.floatValue > northEast.latitude) {
//            northEast.latitude = trackPoint.latitude.floatValue;
//        }
//    }
//    double width = northEast.longitude - southWest.longitude;
//    southWest.longitude -= width/4;
//    northEast.longitude += width/4;
//    
//    double height  = northEast.latitude - southWest.latitude;
//    southWest.latitude -= height/4;
//    northEast.latitude += height/4;
//    
//    MGLCoordinateBounds bounds;
//    bounds.sw = southWest;
//    bounds.ne = northEast;
//    
//    [self.mapView setVisibleCoordinateBounds:bounds animated:NO];
//   // [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:southWest northEast:northEast animated:NO];
}

- (void)updateOverlay
{
    if (!self.track) {
        return;
    }
    
    NSArray *trackPoints = self.track.sotredTrackPoints;
    
    if (trackPoints.count == 0) {
        return;
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    //[self.mapView removeAllAnnotations];
    
//    NSMutableArray *locations = [[NSMutableArray alloc] init];
//    
//    for (TrackPoint *trackPoint in trackPoints) {
//        CLLocation *location = [[CLLocation alloc] initWithLatitude:trackPoint.latitude.floatValue longitude:trackPoint.longitude.floatValue];
//        [locations addObject:location];
//        
//        if (trackPoint.name != nil) {
//            TrackPointAnnotation * annotation = [[TrackPointAnnotation alloc] initWithMapView:self.mapView coordinate:trackPoint.coordinate andTitle:trackPoint.name];
//            if (trackPoint.image != nil) {
//                annotation.trackImage = [UIImage imageWithData:trackPoint.image];
//            }
//            [self.mapView addAnnotation:annotation];
//        }
//    }
    
    //TrackLineAnnotation *annotation = [[TrackLineAnnotation alloc] initWithMapView:self.mapView points:locations];
    
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D *)malloc(trackPoints.count * sizeof(CLLocationCoordinate2D));
    //CLLocationCoordinate2D *coordinates = new CLLocationCoordinate2D[trackPoints.count];
    int count = 0;
    for (TrackPoint *trackPoint in trackPoints) {
        coordinates[count++] = CLLocationCoordinate2DMake(trackPoint.latitude.floatValue, trackPoint.longitude.floatValue);
        if (trackPoint.name != nil) {
            TrackPointAnnotation *annotation = [[TrackPointAnnotation alloc] init];
            annotation.coordinate = CLLocationCoordinate2DMake(trackPoint.latitude.floatValue, trackPoint.longitude.floatValue);
            annotation.title = trackPoint.name;
            if (trackPoint.image != nil) {
                annotation.trackImage = [UIImage imageWithData:trackPoint.image];
            }
            [self.mapView addAnnotation:annotation];
        }
    }
    //[self.mapView addAnnotation:annotation];
    MGLPolyline *shape = [MGLPolyline polylineWithCoordinates:coordinates count:count];
    
    free(coordinates);
    // Add the shape to the map
    [self.mapView addAnnotation:shape];
}

@end


#pragma mark -
@implementation MapViewController (MGLMapViewDelegate)

- (BOOL)mapView:(MGLMapView *)mapView annotationCanShowCallout:(id <MGLAnnotation>)annotation {
    return YES;
}

- (nullable UIView *)mapView:(MGLMapView *)mapView rightCalloutAccessoryViewForAnnotation:(id <MGLAnnotation>)annotation
{
    if ([annotation isKindOfClass:[TrackPointAnnotation class]]) {
        TrackPointAnnotation *trackPointAnnotation = (TrackPointAnnotation *)annotation;
        return trackPointAnnotation.trackImage;
    }
    return nil;
}

- (CGFloat)mapView:(MGLMapView *)mapView alphaForShapeAnnotation:(MGLShape *)annotation
{
    // Set the alpha for shape annotations to 0.5 (half opacity)
    return 0.5f;
}

- (UIColor *)mapView:(MGLMapView *)mapView strokeColorForShapeAnnotation:(MGLShape *)annotation
{
    // Set the stroke color for shape annotations
    return [UIColor blueColor];
}

@end

@implementation TrackPointAnnotation
@end

//@implementation TrackPointAnnotation
//- (RMMapLayer *)layer
//{
//    if(layer == nil)
//    {
//        RMMarker *marker = (RMMarker*)[super layer];
//    
//        if (self.trackImage != nil) {
//            if (marker.leftCalloutAccessoryView == nil) {
//                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//                imageView.image = self.trackImage;
//                marker.leftCalloutAccessoryView = imageView;
//            }
//
//        if (marker.rightCalloutAccessoryView == nil) {
//            marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        }
//    }
//    
//        return marker;
//    }
//    else
//    {
//        return [super layer];
//    }
//}
//@end
//
//@implementation TrackLineAnnotation
//- (RMMapLayer *)layer
//{
//    if(layer == nil)
//    {
//        RMShape *shape = (RMShape*)[super layer];
//    
//        shape.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
//        shape.lineWidth = 5.0;
//        
//        shape.lineCap = kCALineCapRound;
//        shape.lineJoin = kCALineJoinRound;
//        return shape;
//    }
//    else
//    {
//        return [super layer];
//    }
//    
//}
//@end



