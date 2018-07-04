//
//  Splash.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 8/4/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface Splash : UIViewController <CLLocationManagerDelegate>{
    AppDelegate *appDel;
    IBOutlet UIView *viewLocationServiceDisabled;
    NSMutableArray *riderArray;
    NSMutableArray *settingArray;
}
@property (strong, nonatomic) UIWindow *window;
@property CLLocationManager * locationManager;
@end


//Please register your email IDs used in non-smtp mails through cpanel plugin. Unregistered email IDs will not be allowed in non-smtp emails sent through scripts. Go to Mail section and find "Registered Mail IDs" plugin in paper_lantern theme
