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
// Inngerband
#import "CoreDataStore.h"
#import "Functions.h"
#import "NSManagedObject+InnerBand.h"
#import "Coord.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"

@interface MapViewController ()
- (void)showLog;
@end

@interface MapViewController (MKMapViewDelegate) <MKMapViewDelegate>
- (void)updateOverlay;
@end

@implementation MapViewController

@synthesize mapView = __mapView;
@synthesize track = __track;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    GpsCoorEncrypt(&coordinate.longitude, &coordinate.latitude);
    
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
        MKCoordinateSpan span = MKCoordinateSpanMake(0.05f, 0.05f);
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
        [self.mapView setRegion:region];
        return;
    }
    //
    // Thanks for elegant code!
    // https://gist.github.com/915374
    //
    MKMapRect zoomRect = MKMapRectNull;
    for (TrackPoint *trackPoint in self.track.trackpoints) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(trackPoint.latitude.floatValue, trackPoint.longitude.floatValue);
        
        GpsCoorEncrypt(&coordinate.longitude, &coordinate.latitude);
        
        MKMapPoint annotationPoint = MKMapPointForCoordinate(coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    zoomRect = MKMapRectInset(zoomRect,-zoomRect.size.width/4,-zoomRect.size.height/4);
    
    [self.mapView setVisibleMapRect:zoomRect animated:NO];
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

    CLLocationCoordinate2D coors[trackPoints.count];
    
    int i = 0;
    for (TrackPoint *trackPoint in trackPoints) {
        coors[i] = trackPoint.coordinate;
        
        GpsCoorEncrypt(&coors[i].longitude, &coors[i].latitude);
        i++;
    }
    
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coors count:trackPoints.count];

    // replace overlay
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView addOverlay:line];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineView *overlayView = [[MKPolylineView alloc] initWithOverlay:overlay];
    overlayView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
    overlayView.lineWidth = 5.f;
    
    return overlayView;
}

@end


