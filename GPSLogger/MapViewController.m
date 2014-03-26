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

@interface MapViewController ()
@property (strong, nonatomic) UIDocumentInteractionController *interactionController;
@property (strong, nonatomic) CLLocationManager *locationManager;
- (void)startLogging;
- (void)showLog;
@end

@interface MapViewController (CLLocationManagerDelegate) <CLLocationManagerDelegate>
@end

@interface MapViewController (MKMapViewDelegate) <MKMapViewDelegate>
- (void)updateOverlay;
@end

@interface MapViewController (UIActionSheetDelegate) <UIActionSheetDelegate>
- (NSString *)gpxFilePath;
- (NSString *)createGPX;
- (void)openFile:(NSString *)filePath;
- (void)mailFile:(NSString *)filePath;
@end

@interface MapViewController (MFMailComposeViewControllerDelegate) <MFMailComposeViewControllerDelegate>
@end



@implementation MapViewController

@synthesize mapView = __mapView;
@synthesize track = __track;
@synthesize locationManager = __locationManager;
@synthesize interactionController = __interactionController;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.track) {
        [self startLogging];
    } else {
        [self showLog];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Actions

- (IBAction)close:(id)sender
{    
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
    }

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)action:(id)sender
{
    UIActionSheet *actionSheet = [UIActionSheet new];
    actionSheet.delegate = self;

    // setup actions
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Open In ...", nil)];
    if ([MFMailComposeViewController canSendMail]) {
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Mail this Log", nil)];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];

    // set cancel action position
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons -1;
    
    [actionSheet showInView:self.view];
}


#pragma mark - Private methods

- (void)startLogging
{
    // initialize map position
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(37.332408, -122.030490);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05f, 0.05f);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [self.mapView setRegion:region];

    // initialize location manager
    if (![CLLocationManager locationServicesEnabled]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                            message:NSLocalizedString(@"Location Service not enabeld.", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        
    } else {
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Stop Logging", nil);
        
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager startUpdatingLocation];
        
        self.track = [Track create];
        self.track.created = [NSDate date];
        [[CoreDataStore mainStore] save];
    }
}

- (void)showLog
{
    [self updateOverlay];
    
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
    [self.mapView setVisibleMapRect:zoomRect animated:NO];
}

@end


#pragma mark -
@implementation MapViewController (CLLocationManagerDelegate)

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
        TrackPoint *trackpoint = [TrackPoint create];
        trackpoint.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
        trackpoint.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
        trackpoint.altitude = [NSNumber numberWithFloat:newLocation.altitude];
        trackpoint.created = [NSDate date];
        [self.track addTrackpointsObject:trackpoint];

        [[CoreDataStore mainStore] save];

        // update annotation and overlay
        [self updateOverlay];
        
        CLLocationCoordinate2D coordinate = newLocation.coordinate;
        GpsCoorEncrypt(&coordinate.longitude, &coordinate.latitude);

        // set new location as center
        [self.mapView setCenterCoordinate:coordinate animated:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error, %@", error);
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
    overlayView.strokeColor = [UIColor blueColor];
    overlayView.lineWidth = 5.f;
    
    return overlayView;
}

@end


#pragma mark -
@implementation MapViewController (UIActionSheetDelegate)

- (NSString *)gpxFilePath
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterFullStyle];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [NSString stringWithFormat:@"log_%@.gpx", dateString];
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

- (NSString *)createGPX
{
    // gpx
    GPXRoot *gpx = [GPXRoot rootWithCreator:@"GPSLogger"];
    
    // gpx > trk
    GPXTrack *gpxTrack = [gpx newTrack];
    gpxTrack.name = @"New Track";
    
    // gpx > trk > trkseg > trkpt
    for (TrackPoint *trackPoint in self.track.sotredTrackPoints) {
        GPXTrackPoint *gpxTrackPoint = [gpxTrack newTrackpointWithLatitude:trackPoint.latitude.floatValue longitude:trackPoint.longitude.floatValue];
        gpxTrackPoint.elevation = trackPoint.altitude.floatValue;
        gpxTrackPoint.time = trackPoint.created;
    }
    
    NSString *gpxString = gpx.gpx;
    
    // write gpx to file
    NSError *error;
    NSString *filePath = [self gpxFilePath];
    if (![gpxString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        if (error) {
            NSLog(@"error, %@", error);
        }

        return nil;
    }

    return filePath;
}

- (void)openFile:(NSString *)filePath
{
    NSURL *url = [NSURL fileURLWithPath:filePath];
    self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];

    if (![self.interactionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                        message:NSLocalizedString(@"No application can be found to open the file.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailFile:(NSString *)filePath
{
    MFMailComposeViewController *controller = [MFMailComposeViewController new];
    controller.mailComposeDelegate = self;
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [controller addAttachmentData:data mimeType:@"application/gpx+xml" fileName:[filePath lastPathComponent]];
    
    [self presentModalViewController:controller animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {

        NSString *filePath = [self createGPX];
        
        if (filePath) {
            if (buttonIndex == 0) {
                [self openFile:filePath];
            }
            if (buttonIndex == 1) {
                [self mailFile:filePath];
            }
        }
    }
}

@end


#pragma mark -
@implementation MapViewController (MFMailComposeViewControllerDelegate)

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

@end

