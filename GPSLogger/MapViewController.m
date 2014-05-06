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
- (void)showLog;
@end

@interface MapViewController (MKMapViewDelegate) <RMMapViewDelegate>
- (void)updateOverlay;
@end

@implementation MapViewController

@synthesize mapView = __mapView;
@synthesize track = __track;

#define kNormalMapID @"examples.map-vyofok3q"
#define kRetinaMapID @"examples.map-vyofok3q"

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    RMMapboxSource *tileSource = [[RMMapboxSource alloc] initWithMapID:@"examples.map-z2effxa8"];
    
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
    
    [self.mapView removeAllAnnotations];
    [self.mapView addAnnotation:annotation];
}

@end


