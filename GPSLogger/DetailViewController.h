//
//  ListViewController.h
//  GPSLogger
//
//  Created by chao han on 14-4-25.
//
//

#import <UIKit/UIKit.h>
#import "Track.h"

@interface DetailViewController : UITableViewController

@property (strong, nonatomic) Track *track;

- (void)update;

@end
