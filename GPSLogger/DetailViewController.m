//
//  ListViewController.m
//  GPSLogger
//
//  Created by chao han on 14-4-25.
//
//

#import "DetailViewController.h"
#import "TrackPoint.h"
#import "IBCoreDataStore.h"

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
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
        return 9;
    }
    return self.track.sotredTrackPoints.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Name", nil);
            cell.detailTextLabel.text = self.track.name;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Number of Track Points", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",self.track.sotredTrackPoints.count];
        }else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Distance", nil);
            
            double distance = self.track.distance;
            
            NSString *distanceString;
            if (distance < 1000) {
                distanceString = [NSString stringWithFormat:@"%f%@", distance, NSLocalizedString(@"m", nil)];
            }
            else
            {
                distanceString = [NSString stringWithFormat:@"%f%@", distance/1000, NSLocalizedString(@"km", nil)];
            }
            
            cell.detailTextLabel.text = distanceString;
        }else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Max Speed", nil);
            
            double speed = self.track.maxSpeed;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f%@", speed, NSLocalizedString(@"m/s", nil)];
        }else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Min Speed", nil);
                
            double speed = self.track.minSpeed;
                
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f%@", speed, NSLocalizedString(@"m/s", nil)];
        }else if (indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Average Speed", nil);
            
            double speed = self.track.averageSpeed;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f%@", speed, NSLocalizedString(@"m/s", nil)];
        }else if (indexPath.row == 6) {
            cell.textLabel.text = NSLocalizedString(@"Max Altitude", nil);
            
            double altitude = self.track.maxAltitude;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f%@", altitude, NSLocalizedString(@"m", nil)];;
        }else if (indexPath.row == 7) {
            cell.textLabel.text = NSLocalizedString(@"Min Altitude", nil);
            
            double altitude = self.track.minAltitude;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f%@", altitude, NSLocalizedString(@"m", nil)];
        }else if (indexPath.row == 8) {
            cell.textLabel.text = NSLocalizedString(@"Average Altitude", nil);
            
            double altitude = self.track.averageAltitude;
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%f%@", altitude, NSLocalizedString(@"m", nil)];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && indexPath.row == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Input Name", nil) message:@"" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)  otherButtonTitles:NSLocalizedString(@"OK", nil) ,nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *tfName=[alert textFieldAtIndex:0];
        tfName.text = self.track.name;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1)
    {
        UITextField *tfName=[alertView textFieldAtIndex:0];
        self.track.name = tfName.text;
        [[IBCoreDataStore mainStore] save];
        [self.tableView reloadData];
    }
}

@end
