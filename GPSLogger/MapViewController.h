//
//  MapViewController.h
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Track.h"
#import "GTMOAuthAuthentication.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) Track *track;

@property (nonatomic,strong) AFHTTPRequestOperationManager * httpClient;
@property (nonatomic, strong) GTMOAuthAuthentication * auth;

@property (nonatomic,strong)MBProgressHUD * HUD;

- (IBAction)close:(id)sender;
- (IBAction)action:(id)sender;

@end
