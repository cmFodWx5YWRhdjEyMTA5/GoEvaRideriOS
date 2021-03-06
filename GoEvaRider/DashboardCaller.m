//
//  DashboardCaller.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 2/7/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import "DashboardCaller.h"
#import "Dashboard.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "PickCar.h"
#import "MyUtils.h"

#define CDV_IsIPhone5() ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] bounds].size.width == 320)

@implementation DashboardCaller

static UIViewController *mvc;
-(id)init
{
    self = [super init];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}

+ (Dashboard *)homeController {
    
    Dashboard *merchantList;
    if (CDV_IsIPhone5()) {
        merchantList = [[Dashboard alloc] initWithNibName:@"Dashboard" bundle:nil];
    }
    else{
        merchantList = [[Dashboard alloc] initWithNibName:@"DashboardLow" bundle:nil];
    }
    merchantList.pageTitle=@"HOME";
    return merchantList;
}

/*+ (PickCar *)pickCarController {
    
    PickCar *merchantList;
    if (CDV_IsIPhone5()) {
        merchantList = [[PickCar alloc] initWithNibName:@"PickCar" bundle:nil];
    }
    else{
        merchantList = [[PickCar alloc] initWithNibName:@"PickCarLow" bundle:nil];
    }
    merchantList.pageTitle=@"Pick Car";
    return merchantList;
}*/

+ (UINavigationController *)navigationController {
    /*if ([[MyUtils getUserDefault:@"rideMode"] isEqualToString:@"1"]) {*/
        return [[UINavigationController alloc]
                initWithRootViewController:[self homeController]];
    /*}
    else{
        return [[UINavigationController alloc]
                initWithRootViewController:[self pickCarController]];
    }*/
    
}

+(void)homepageSelector:(UIViewController *)controller{
    mvc = controller;
    SideMenuViewController *leftMenuViewController;
    SideMenuViewController *rightMenuViewController;
    if (CDV_IsIPhone5()) {
        leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
        rightMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    }
    else{
        leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewControllerLow" bundle:nil];
        rightMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewControllerLow" bundle:nil];
    }
    
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[self navigationController]
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    container.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [mvc presentViewController:container animated:YES completion:nil];
    
}

@end
