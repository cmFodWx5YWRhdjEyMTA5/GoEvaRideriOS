//
//  ChooseRideService.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/18/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import "ChooseRideService.h"
#import "DashboardCaller.h"
#import "MyUtils.h"
@interface ChooseRideService ()

@end

@implementation ChooseRideService

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    btnPickCar.layer.cornerRadius=22;
    btnNearestCar.layer.cornerRadius=22;
    if ([MyUtils getUserDefault:@"rideMode"]==nil)
        btnClose.hidden=YES;
    else
        btnClose.hidden=NO;
}

- (IBAction)pickCar:(UIButton *)sender{
    [MyUtils setUserDefault:@"rideMode" value:@"2"];
    [DashboardCaller homepageSelector:self];
}
- (IBAction)nearestCar:(UIButton *)sender{
    [MyUtils setUserDefault:@"rideMode" value:@"1"];
    [DashboardCaller homepageSelector:self];
}
- (IBAction)closeView:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
