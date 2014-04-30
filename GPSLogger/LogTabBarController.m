//
//  LogTabBarController.m
//  GPSLogger
//
//  Created by chao han on 14-4-24.
//
//

#import "LogTabBarController.h"
#import "MapViewController.h"
#import "DetailViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GPX.h"
#import "TrackPoint.h"
// Inngerband
#import "CoreDataStore.h"
#import "Functions.h"
#import "NSManagedObject+InnerBand.h"
#import "Coord.h"
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"

@interface LogTabBarController ()
@property (strong, nonatomic) UIDocumentInteractionController *interactionController;
@property (strong, nonatomic) CLLocationManager *locationManager;
- (void)startLogging;
@end

@interface LogTabBarController (CLLocationManagerDelegate) <CLLocationManagerDelegate>
@end

@interface LogTabBarController (UIActionSheetDelegate) <UIActionSheetDelegate>
- (NSString *)gpxFilePath;
- (NSString *)createGPX;
- (void)openFile:(NSString *)filePath;
- (void)mailFile:(NSString *)filePath;
@end

@interface LogTabBarController (MFMailComposeViewControllerDelegate) <MFMailComposeViewControllerDelegate>
@end

@interface LogTabBarController (OSMUpload)
- (GTMOAuthAuthentication *)osmAuth;
- (void)signIntoOSM:(GTMOAuthAuthentication *)auth;
-(void)uploadGpx:(NSString *)filePath;
@end

@interface OSMRequestSerializer : AFHTTPRequestSerializer

@property (nonatomic,strong) GTMOAuthAuthentication * auth;

@end

@implementation LogTabBarController

@synthesize track = __track;
@synthesize locationManager = __locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.edgesForExtendedLayout=UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars=NO;
//    self.automaticallyAdjustsScrollViewInsets=NO;
    
    
    if (!self.track) {
        [self startLogging];
    }
    
    self.HUD = [[MBProgressHUD alloc] init];
    
    for (UIViewController *viewController in self.viewControllers) {
        
        if([viewController isKindOfClass:[MapViewController class]]){
            MapViewController *mapViewController = (MapViewController *)viewController;
            mapViewController.track = self.track;
        }
        
        if([viewController isKindOfClass:[DetailViewController class]]){
            DetailViewController *detailViewController = (DetailViewController *)viewController;
            detailViewController.track = self.track;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Upload to OSM", nil)];
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    // set cancel action position
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons -1;
    
    [actionSheet showInView:self.view];
}

#pragma mark - Private methods

- (void)startLogging
{
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

@end

#pragma mark -
@implementation LogTabBarController (CLLocationManagerDelegate)

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation) {
        TrackPoint *trackpoint = [TrackPoint create];
        trackpoint.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
        trackpoint.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
        trackpoint.altitude = [NSNumber numberWithFloat:newLocation.altitude];
        trackpoint.speed = [NSNumber numberWithFloat:newLocation.speed];
        trackpoint.created = [NSDate date];
        [self.track addTrackpointsObject:trackpoint];
        
        [[CoreDataStore mainStore] save];
        
        if([self.selectedViewController isKindOfClass:[MapViewController class]]){
            MapViewController *mapViewController = (MapViewController *)self.selectedViewController;
            [mapViewController update:newLocation];
        }
        
        if([self.selectedViewController isKindOfClass:[DetailViewController class]]){
            DetailViewController *detailViewController = (DetailViewController *)self.selectedViewController;
            [detailViewController update];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error, %@", error);
}

@end

#pragma mark -
@implementation LogTabBarController (UIActionSheetDelegate)

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
        gpxTrackPoint.speed = trackPoint.speed.floatValue;
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
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        
        if (buttonIndex == 2) {
            GTMOAuthAuthentication * auth = [self osmAuth];
            if([auth canAuthorize])
            {
                [self.view addSubview:self.HUD];
                self.HUD.mode = MBProgressHUDModeIndeterminate;
                self.HUD.labelText = NSLocalizedString(@"Saving", nil);
                [self.HUD show:YES];
                
                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                    
                    NSString *filePath = [self createGPX];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //[self.HUD hide:YES];
                        if (filePath) {
                            [self uploadGpx:filePath];
                        }
                    });
                });
            }
            else
            {
                [self signIntoOSM:auth];
            }
        }
        else
        {
            [self.view addSubview:self.HUD];
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.labelText = NSLocalizedString(@"Saving", nil);
            [self.HUD show:YES];
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                NSString *filePath = [self createGPX];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.HUD hide:YES];
                    if (filePath) {
                        if (buttonIndex == 0) {
                            [self openFile:filePath];
                        }
                        else if (buttonIndex == 1) {
                            [self mailFile:filePath];
                        }
                    }
                });
            });
        }
    }
    
    
    
}

@end


#pragma mark -
@implementation LogTabBarController (MFMailComposeViewControllerDelegate)

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end


#pragma mark - OSM
@implementation LogTabBarController (OSMUpload)

#define osmConsumerKey @"kIa5OHTBAhChzpuRO67gHTsnl1c3SXdARE1tuks8"
#define osmConsumerSecret @"Lu6abZQsSwz7zc83tbn050Bg3hyYhxohkJzl5idr"

- (GTMOAuthAuthentication *)osmAuth {
    if (self.auth != nil) {
        return self.auth;
    }
    NSString *myConsumerKey = osmConsumerKey;    // pre-registered with service
    NSString *myConsumerSecret = osmConsumerSecret; // pre-assigned by service
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                       consumerKey:myConsumerKey
                                                        privateKey:myConsumerSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"GPSLogger";
    
    [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"GPSLogger"
                                               authentication:auth];
    
    self.auth = auth;
    return self.auth;
}

- (void)signIntoOSM:(GTMOAuthAuthentication *)auth {
    
    
    NSURL *requestURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"http://www.openstreetmap.org/oauth/authorize"];
    NSString *scope = @"http://api.openstreetmap.org/";
    
    if (auth == nil) {
        // perhaps display something friendlier in the UI?
        NSLog(@"A valid consumer key and consumer secret are required for signing in to OSM");
    }
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:@"http://www.google.com/OAuthCallback"];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch * viewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                                             language:nil
                                                                                      requestTokenURL:requestURL
                                                                                    authorizeTokenURL:authorizeURL
                                                                                       accessTokenURL:accessURL
                                                                                       authentication:auth
                                                                                       appServiceName:@"GPSLogger"
                                                                                             delegate:self
                                                                                     finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [[self navigationController] pushViewController:viewController
                                           animated:YES];
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        NSLog(@"Authentication error: %@", error);
    } else {
        NSLog(@"Suceeed");
        
        [self.view addSubview:self.HUD];
        self.HUD.mode = MBProgressHUDModeIndeterminate;
        self.HUD.labelText = NSLocalizedString(@"Saving", nil);
        [self.HUD show:YES];
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSString *filePath = [self createGPX];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //[self.HUD hide:YES];
                if (filePath) {
                    [self uploadGpx:filePath];
                }
            });
        });
    }
}


-(AFHTTPRequestOperationManager *)httpClient
{
    if (!_httpClient) {
        NSString * baseUrl = @"http://api.openstreetmap.org/api/0.6/";
        _httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        
        AFXMLParserResponseSerializer * xmlParserResponseSerializer =  [AFXMLParserResponseSerializer serializer];
        NSMutableSet * contentTypes = [xmlParserResponseSerializer.acceptableContentTypes mutableCopy];
        [contentTypes addObject:@"text/plain"];
        xmlParserResponseSerializer.acceptableContentTypes = contentTypes;
        _httpClient.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializer],xmlParserResponseSerializer]];
        
        OSMRequestSerializer * requestSerializer = [OSMRequestSerializer serializer];
        [requestSerializer setAuth:[self osmAuth]];
        [_httpClient setRequestSerializer:requestSerializer];
    }
    return _httpClient;
}

-(void)uploadGpx:(NSString *)filePath
{
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = NSLocalizedString(@"Uploading", nil);
    
    NSDictionary * parameters = @{@"description": @"create by GPSLogger",@"tags":@"track",@"visibility":@"identifiable"};
    
    AFHTTPRequestOperation * requestOperation = [self.httpClient POST:@"gpx/create" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
        NSString *fileName = [filePathUrl lastPathComponent];
        
        [formData appendPartWithFileURL:filePathUrl name:@"file" fileName:fileName mimeType:@"application/gpx+xml" error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"ok");
        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = NSLocalizedString(@"Completed", nil);
        [self.HUD hide:YES afterDelay:2.0];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error %@",error);
        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = NSLocalizedString(@"Failed", nil);
        [self.HUD hide:YES afterDelay:2.0];
    }];
    
    [requestOperation start];
}

@end

@implementation OSMRequestSerializer

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method URLString:(NSString *)URLString parameters:(NSDictionary *)parameters error:(NSError *__autoreleasing *)error
{
    NSMutableURLRequest * request = [super requestWithMethod:method URLString:URLString parameters:parameters error:error];
    
    [request setTimeoutInterval:15];
    
    if (![method isEqualToString:@"GET"]) {
        [self.auth authorizeRequest:request];
    }
    return request;
}

@end

