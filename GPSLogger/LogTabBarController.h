//
//  LogTabBarController.h
//  GPSLogger
//
//  Created by chao han on 14-4-24.
//
//

#import <UIKit/UIKit.h>
#import "Track.h"
#import "GTMOAuthAuthentication.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface LogTabBarController : UITabBarController

@property (strong, nonatomic) Track *track;

@property (nonatomic,strong) AFHTTPRequestOperationManager * httpClient;
@property (nonatomic, strong) GTMOAuthAuthentication * auth;

@property (nonatomic,strong)MBProgressHUD * HUD;

- (IBAction)close:(id)sender;
- (IBAction)share:(id)sender;

@end
