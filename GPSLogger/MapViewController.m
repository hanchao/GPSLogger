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

@interface MapViewController ()
- (id <RMTileSource>)getTilesource;
- (void)showLog;
@end

@interface MapViewController (MKMapViewDelegate) <RMMapViewDelegate>
- (void)updateOverlay;
@end

@implementation MapViewController

@synthesize mapView = __mapView;
@synthesize track = __track;

#define STREETS_MAP_ID @"examples.map-vyofok3q"

#define TERRAIN_MAP_ID @"examples.map-9ijuk24y"

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)update:(CLLocation *)newLocation
{
    [self updateOverlay];
    
    CLLocationCoordinate2D coordinate = newLocation.coordinate;

    // set new location as center
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}

#pragma mark - Private methods

- (id <RMTileSource>)getTilesource
{
    RMMapboxSource *tileSource;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tileJSON = [defaults stringForKey:@"tileJSON"];
    if (tileJSON)
    {
        tileSource = [[RMMapboxSource alloc] initWithTileJSON:tileJSON];
    }
    else
    {
        tileSource = [[RMMapboxSource alloc] initWithMapID:TERRAIN_MAP_ID];
        if (tileSource)
        {
            [defaults setObject:tileSource.tileJSON forKey:@"tileJSON"];
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

    NSMutableArray *locations = [[NSMutableArray alloc] init];

    for (TrackPoint *trackPoint in trackPoints) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:trackPoint.latitude.floatValue longitude:trackPoint.longitude.floatValue];
        [locations addObject:location];
    }
    
    RMPolylineAnnotation *annotation = [[RMPolylineAnnotation alloc] initWithMapView:self.mapView points:locations];
       
    annotation.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    annotation.lineWidth = 5.0;
    
    RMShape* shape = (RMShape*)annotation.layer;
    shape.lineCap = @"round";
    shape.lineJoin = @"round";
    
    [self.mapView removeAllAnnotations];
    [self.mapView addAnnotation:annotation];
}

@end


