//
//  MapViewController.h
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Mapbox.h"
#import "Track.h"

@interface MapViewController : UIViewController

@property (strong, nonatomic) MGLMapView *mapView;
@property (strong, nonatomic) Track *track;

- (void)update;

@end
