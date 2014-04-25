//
//  ListViewController.m
//  GPSLogger
//
//  Created by chao han on 14-4-25.
//
//

#import "DetailViewController.h"
#import "TrackPoint.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize track = __track;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return NSLocalizedString(@"Track Information", nil);
    }else if (section == 1) {
        return NSLocalizedString(@"Track Points", nil);
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return self.track.sotredTrackPoints.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Name", nil);
            
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *text = [formatter stringFromDate:self.track.created];
            cell.detailTextLabel.text = text;
        }else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Number of Track Points", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",self.track.sotredTrackPoints.count];
        }
    }
    else if (indexPath.section == 1) {
        TrackPoint *trackPoint = [self.track.sotredTrackPoints objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%f %f",trackPoint.longitude.floatValue,trackPoint.latitude.floatValue];
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %f%@ %@ %f%@",NSLocalizedString(@"Altitude", nil), trackPoint.altitude.floatValue,NSLocalizedString(@"m", nil),NSLocalizedString(@"Speed", nil), trackPoint.speed.floatValue,NSLocalizedString(@"m/s", nil)];
    }

    
    
    return cell;
}

- (void)update
{
    [self.tableView reloadData];
    
    // move last row
    NSUInteger sectionCount = [self.tableView numberOfSections];
    if (sectionCount) {
        
        NSUInteger rowCount = [self.tableView numberOfRowsInSection:sectionCount-1];
        if (rowCount) {
            
            NSUInteger indexs[2] = {sectionCount-1, rowCount - 1};
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:indexs length:2];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }  
    }
}

@end
