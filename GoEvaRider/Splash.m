//
//  Splash.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 8/4/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "Splash.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "MyUtils.h"
#import "Dashboard.h"
#import "CredentailPage.h"
#import "LoginPage.h"
#import "CompleteRide.h"
#import "RateUsDriver.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "GlobalVariable.h"
#import "DashboardCaller.h"

@interface Splash ()

@end

@implementation Splash

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [viewLocationServiceDisabled setHidden:YES];
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [_locationManager requestWhenInUseAuthorization];
        
    } else {
        //Will update location immediately
    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //NSLog(@"Location access Permit");
        //NSLog(@"ID: %@",[MyUtils getUserDefault:@"riderID"]);
        [viewLocationServiceDisabled setHidden:YES];
        [self getSettingData]; // Get setting Data
        if ([MyUtils getUserDefault:@"riderID"]==nil) {
            if ([MyUtils getUserDefault:@"loginMode"]==nil) {
                [self performSelector:@selector(credentialSelector) withObject:self afterDelay:3.0 ];
            }
            else{
                [self performSelector:@selector(loginSelectior) withObject:self afterDelay:3.0 ];
            }
            
        }
        else{
            [self homeSelector];
            //[self performSelector:@selector(homepageSelector) withObject:self afterDelay:3.0 ];
            
        }
    }
    else if (status == kCLAuthorizationStatusDenied) {
        //NSLog(@"Location access denied");
        [viewLocationServiceDisabled setHidden:NO];
        //home button press programmatically
        /*UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        
        //wait 2 seconds while app is going background
        [NSThread sleepForTimeInterval:2.0];
        
        //exit app when app is in background
        exit(0);*/
    }
}

-(void) getSettingData{
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        [NSThread detachNewThreadSelector:@selector(requestToServerGetSetting) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerGetSetting{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getSettings:@"1"];
    if(bSuccess)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            settingArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getSetting]];
            [MyUtils setUserDefault:@"search_radius" value:[[settingArray objectAtIndex:0] search_radius]];
            [MyUtils setUserDefault:@"min_duration_for_cancellation_charge" value:[[settingArray objectAtIndex:0] min_duration_for_cancellation_charge]];
        });
    }
    else{
        //[self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
        dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:@"We are having an issue connecting to the server. Please try again." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self getSettingData];
            
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [NSThread sleepForTimeInterval:2.0];
            exit(0);
        }];
        [alertController addAction:action];
        [alertController addAction:action2];
        [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}


-(void)homeSelector{
    if([RestCallManager hasConnectivity]){
        [NSThread detachNewThreadSelector:@selector(requestToServerGetProfile) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerGetProfile{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getRiderDetails:[MyUtils getUserDefault:@"riderID"] userType:[GlobalVariable getUserType]];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responsefetchProfile) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responsefetchProfile{
    riderArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getRider]];
    settingArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getSetting]];
    [MyUtils setUserDefault:@"riderMobileNo" value:[[riderArray objectAtIndex:0] rider_mobile]];
    [MyUtils setUserDefault:@"riderEmail" value:[[riderArray objectAtIndex:0] rider_email]];
    [MyUtils setUserDefault:@"profileImage" value:[[riderArray objectAtIndex:0] profile_pic]];
    [MyUtils setUserDefault:@"riderName" value:[[riderArray objectAtIndex:0] rider_name] == (id)[NSNull null]?@"NO NAME":[[riderArray objectAtIndex:0] rider_name]];
    [MyUtils setUserDefault:@"riderRating" value:[[riderArray objectAtIndex:0] ratting]];
    [DashboardCaller homepageSelector:self];
}

-(void)responseFailed{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:@"We are having an issue connecting to the server. Please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            [self homeSelector];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        [NSThread sleepForTimeInterval:2.0];
        exit(0);
    }];
    [alertController addAction:action];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void) credentialSelector{
    CredentailPage *loginController;
    if(appDel.iSiPhone5){
        loginController = [[CredentailPage alloc] initWithNibName:@"CredentailPage" bundle:nil];
    }else{
        loginController = [[CredentailPage alloc] initWithNibName:@"CredentailPageLow" bundle:nil];
    }
    loginController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:loginController animated:YES completion:nil];
}
-(void) loginSelectior{
    LoginPage *loginController;
    if(appDel.iSiPhone5){
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPage" bundle:nil];
    }else{
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPageLow" bundle:nil];
    }
    loginController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:loginController animated:YES completion:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
