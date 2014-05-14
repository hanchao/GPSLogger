//
//  Track.m
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import "Track.h"
#import "TrackPoint.h"


@implementation Track

@dynamic name;
@dynamic created;
@dynamic trackpoints;


- (NSArray *)sotredTrackPoints
{
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
    return [self.trackpoints sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
}

- (double)distance
{
    double distance = 0.0;
    
    NSArray *trackPoints = self.sotredTrackPoints;
    CLLocation* locations[trackPoints.count];
    
    int i = 0;
    for (TrackPoint *trackPoint in trackPoints)
    {
        locations[i] = [[CLLocation alloc] initWithLatitude:trackPoint.latitude.doubleValue longitude:trackPoint.longitude.doubleValue];
        i++;
    }
    
    for (int i=1; i<trackPoints.count; i++)
    {
        CLLocationDistance newDistance = [locations[i-1] distanceFromLocation:locations[i]];
        distance += newDistance;
    }
    
    return distance;
}

- (NSTimeInterval )usedTime
{
    NSTimeInterval time = 0.0;
    NSArray *trackPoints = self.sotredTrackPoints;
    
    if (trackPoints.count>0)
    {
        TrackPoint *startPoint = (TrackPoint *)[trackPoints firstObject];
        TrackPoint *endPoint = (TrackPoint *)[trackPoints lastObject];
        time = [endPoint.created timeIntervalSinceDate:startPoint.created];
    }
    
    return time;
}

- (double)maxSpeed
{
    double maxSpeed = 0.0;
    
    NSArray *trackPoints = self.sotredTrackPoints;
    if (trackPoints.count == 0)
    {
        return 0.0;
    }
    for (TrackPoint *trackPoint in trackPoints)
    {
        if (trackPoint.speed.floatValue > maxSpeed)
        {
            maxSpeed = trackPoint.speed.floatValue;
        }
    }
    return maxSpeed;
}

- (double)minSpeed
{
    double minSpeed = 1.79769313486232E+308;
    
    NSArray *trackPoints = self.sotredTrackPoints;
    if (trackPoints.count == 0)
    {
        return 0.0;
    }
    for (TrackPoint *trackPoint in trackPoints)
    {
        if (trackPoint.speed.floatValue < minSpeed)
        {
            minSpeed = trackPoint.speed.floatValue;
        }
    }
    return minSpeed;
}

- (double)averageSpeed
{
    double allSpeed = 0.0;
    
    NSArray *trackPoints = self.sotredTrackPoints;
    if (trackPoints.count == 0)
    {
        return 0.0;
    }
    for (TrackPoint *trackPoint in trackPoints)
    {
        allSpeed += trackPoint.speed.floatValue;
    }
    return allSpeed / trackPoints.count;
}

- (double)maxAltitude
{
    double maxAltitude = 0.0;
    
    NSArray *trackPoints = self.sotredTrackPoints;
    if (trackPoints.count == 0)
    {
        return 0.0;
    }
    for (TrackPoint *trackPoint in trackPoints)
    {
        if (trackPoint.altitude.floatValue > maxAltitude)
        {
            maxAltitude = trackPoint.altitude.floatValue;
        }
    }
    return maxAltitude;
}

- (double)minAltitude
{
    double minAltitude = 1.79769313486232E+308;
    
    NSArray *trackPoints = self.sotredTrackPoints;
    if (trackPoints.count == 0)
    {
        return 0.0;
    }
    for (TrackPoint *trackPoint in trackPoints)
    {
        if (trackPoint.altitude.floatValue < minAltitude)
        {
            minAltitude = trackPoint.altitude.floatValue;
        }
    }
    return minAltitude;
}

- (double)averageAltitude
{
    double allAltitude = 0.0;
    
    NSArray *trackPoints = self.sotredTrackPoints;
    if (trackPoints.count == 0)
    {
        return 0.0;
    }
    for (TrackPoint *trackPoint in trackPoints)
    {
        allAltitude += trackPoint.altitude.floatValue;
    }
    return allAltitude / trackPoints.count;
}

@end
