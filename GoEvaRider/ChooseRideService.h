//
//  ChooseRideService.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/18/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ChooseRideService : UIViewController{
    AppDelegate *appDel;
    IBOutlet UIButton *btnPickCar, *btnNearestCar, *btnClose;
}
@property (strong, nonatomic) UIWindow *window;
- (IBAction)pickCar:(UIButton *)sender;
- (IBAction)nearestCar:(UIButton *)sender;
- (IBAction)closeView:(UIButton *)sender;
@end
