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
- (id <RMTileSource>)getTilesource;
- (void)showLog;
@end

@interface MapViewController (MKMapViewDelegate) <RMMapViewDelegate>
- (void)updateOverlay;
@end

@interface MapViewController (MWPhotoBrowserDelegate) <MWPhotoBrowserDelegate>

@end

@interface TrackPointAnnotation : RMPointAnnotation
@property (nonatomic,strong) UIImage * trackImage;
@end

@interface TrackLineAnnotation : RMPolylineAnnotation

@end

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
    
    id <RMTileSource> tileSource = [self getTilesource];
    
    if(tileSource == nil)
        return;
    
    
    self.mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:tileSource];
    
    [self.view addSubview:self.mapView];
    
    self.mapView.showsUserLocation = YES;
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.mapView.delegate = self;
    
    if (self.track) {
        [self showLog];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateOverlay];
    
    RMUserTrackingBarButtonItem *userTrackingBarButtonItem = [[RMUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    
    UIBarButtonItem *rightBarButtonItem = self.tabBarController.navigationItem.rightBarButtonItem;
    self.tabBarController.navigationItem.rightBarButtonItems = @[rightBarButtonItem,userTrackingBarButtonItem];
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

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    if (![annotation isKindOfClass:[TrackPointAnnotation class]]) {
        return;
    }
    
    TrackPointAnnotation *trackPointAnnotation = (TrackPointAnnotation *)annotation;

    MWPhoto *photo = [MWPhoto photoWithImage:trackPointAnnotation.trackImage];
    photo.caption = trackPointAnnotation.title;
    
    PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
    
    photoViewController.photo = photo;
    
    [self.navigationController pushViewController:photoViewController animated:YES];
}

#pragma mark - Private methods

- (id <RMTileSource>)getTilesource
{
    RMMapboxSource *tileSource;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tileJSON = [defaults stringForKey:TERRAIN_MAP_ID];
    if (tileJSON)
    {
        tileSource = [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    }
    else
    {
        tileSource = [[RMMapboxSource alloc] initWithMapID:TERRAIN_MAP_ID];
        if (tileSource)
        {
            [defaults setObject:tileSource.tileJSON forKey:TERRAIN_MAP_ID];
            [defaults synchronize];
        }
    }
    return tileSource;
}

- (void)showLog
{
    [self updateOverlay];
    
    if (self.track.trackpoints.count == 0) {
        // initialize map position
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(39.907333, 116.391083);
        
        [self.mapView setZoom:12 atCoordinate:coordinate animated:NO];
        
        self.mapView.userTrackingMode = RMUserTrackingModeFollow;

        return;
    }
    
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
    
    southWest.longitude = 180;
    southWest.latitude = 90;
    northEast.longitude = -180;
    northEast.latitude = -90;
    for (TrackPoint *trackPoint in self.track.trackpoints) {
        if (trackPoint.longitude.floatValue < southWest.longitude) {
            southWest.longitude = trackPoint.longitude.floatValue;
        }
        if (trackPoint.longitude.floatValue > northEast.longitude) {
            northEast.longitude = trackPoint.longitude.floatValue;
        }
        if (trackPoint.latitude.floatValue < southWest.latitude) {
            southWest.latitude = trackPoint.latitude.floatValue;
        }
        if (trackPoint.latitude.floatValue > northEast.latitude) {
            northEast.latitude = trackPoint.latitude.floatValue;
        }
    }
    double width = northEast.longitude - southWest.longitude;
    southWest.longitude -= width/4;
    northEast.longitude += width/4;
    
    double height  = northEast.latitude - southWest.latitude;
    southWest.latitude -= height/4;
    northEast.latitude += height/4;
    
    [self.mapView zoomWithLatitudeLongitudeBoundsSouthWest:southWest northEast:northEast animated:NO];
}

@end


#pragma mark -
@implementation MapViewController (MKMapViewDelegate)

- (void)updateOverlay
{
    if (!self.track) {
        return;
    }

    NSArray *trackPoints = self.track.sotredTrackPoints;
    
    if (trackPoints.count == 0) {
        return;
    }

    [self.mapView removeAllAnnotations];
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];

    for (TrackPoint *trackPoint in trackPoints) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:trackPoint.latitude.floatValue longitude:trackPoint.longitude.floatValue];
        [locations addObject:location];
        
        if (trackPoint.name != nil) {
            TrackPointAnnotation * annotation = [[TrackPointAnnotation alloc] initWithMapView:self.mapView coordinate:trackPoint.coordinate andTitle:trackPoint.name];
            if (trackPoint.image != nil) {
                annotation.trackImage = [UIImage imageWithData:trackPoint.image];
            }
            [self.mapView addAnnotation:annotation];
        }
    }
    
    TrackLineAnnotation *annotation = [[TrackLineAnnotation alloc] initWithMapView:self.mapView points:locations];
       
    annotation.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    annotation.lineWidth = 5.0;
    
    
    [self.mapView addAnnotation:annotation];
}

@end

@implementation TrackPointAnnotation
- (RMMapLayer *)layer
{
    RMMarker *marker = (RMMarker*)[super layer];
    
    if (self.trackImage != nil) {
        if (marker.leftCalloutAccessoryView == nil) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            imageView.image = self.trackImage;
            marker.leftCalloutAccessoryView = imageView;
        }

        if (marker.rightCalloutAccessoryView == nil) {
            marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
    }
    
    return marker;
}
@end

@implementation TrackLineAnnotation
- (RMMapLayer *)layer
{
    RMShape *shape = (RMShape*)[super layer];

    shape.lineCap = @"round";
    shape.lineJoin = @"round";
    
    return shape;
}
@end



