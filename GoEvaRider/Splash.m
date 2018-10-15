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
#import "ChooseRideService.h"
#import "AfterBookingRestartApp.h"

#import "Constant.h"
#import <Stripe/Stripe.h>
#import "CardMaster.h"
#import <AFNetworking/AFNetworking.h>

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
            [MyUtils setUserDefault:@"cancellation_charge" value:[[settingArray objectAtIndex:0] cancellation_charge]];
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
    [MyUtils setUserDefault:@"riderEmail" value:[[riderArray objectAtIndex:0] rider_email] == (id)[NSNull null]?@"":[[riderArray objectAtIndex:0] rider_email]];
    [MyUtils setUserDefault:@"profileImage" value:[[riderArray objectAtIndex:0] profile_pic]];
    [MyUtils setUserDefault:@"riderName" value:[[riderArray objectAtIndex:0] rider_name] == (id)[NSNull null]?@"NO NAME":[[riderArray objectAtIndex:0] rider_name]];
    [MyUtils setUserDefault:@"riderRating" value:[[riderArray objectAtIndex:0] ratting]];
    
    if ([MyUtils getUserDefault:@"bookingID"]!=nil) {
        [self getDefaultCard]; // Get default card
    }
    else{
    [DashboardCaller homepageSelector:self];
    //[self chooseRideServiceSelector];
    }
    
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

-(void)checkIncompleteRideInRiderEnd{
    if([RestCallManager hasConnectivity]){
        [NSThread detachNewThreadSelector:@selector(requestToServerGetTripDetails) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerGetTripDetails{
    NSMutableDictionary *bSuccess;
    bSuccess = [[RestCallManager sharedInstance] checkIncompleteRideInRiderEnd:[MyUtils getUserDefault:@"bookingID"]];
    
    if ([[GlobalVariable getGlobalMessage] isEqualToString:@"0"]) {
        [self performSelectorOnMainThread:@selector(responsefetchTripDetails:) withObject:bSuccess waitUntilDone:YES];
    }
    else if ([[GlobalVariable getGlobalMessage] isEqualToString:@"1"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [DashboardCaller homepageSelector:self];
        });
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void)responsefetchTripDetails:(NSMutableDictionary *)notificationDict{
    
    LocationData *pickupLocation =[[LocationData alloc] init];
    pickupLocation.locationAddress = [notificationDict valueForKey:@"pickup_location"];
    pickupLocation.latitude = [notificationDict valueForKey:@"ride_source_lat"];
    pickupLocation.longitude = [notificationDict valueForKey:@"ride_source_long"];
    [MyUtils saveCustomObject:pickupLocation key:@"pickupLocation"];
    
    LocationData *dropLocation =[[LocationData alloc] init];
    dropLocation.locationAddress = [notificationDict valueForKey:@"drop_location"];
    dropLocation.latitude = [notificationDict valueForKey:@"ride_dest_lat"];
    dropLocation.longitude = [notificationDict valueForKey:@"ride_dest_long"];
    [MyUtils saveCustomObject:dropLocation key:@"dropLocation"];
    
    AfterBookingRestartApp *registerController;
    if (appDel.iSiPhone5) {
        registerController = [[AfterBookingRestartApp alloc] initWithNibName:@"AfterBookingRestartApp" bundle:nil];
    }
    else{
        registerController = [[AfterBookingRestartApp alloc] initWithNibName:@"AfterBookingRestartAppLow" bundle:nil];
    }
    registerController.notificationDriverDetailsDict = notificationDict;
    registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:registerController animated:YES completion:nil];
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

-(void) chooseRideServiceSelector{
    if ([MyUtils getUserDefault:@"rideMode"]==nil){
    ChooseRideService *loginController;
    if(appDel.iSiPhone5){
        loginController = [[ChooseRideService alloc] initWithNibName:@"ChooseRideService" bundle:nil];
    }else{
        loginController = [[ChooseRideService alloc] initWithNibName:@"ChooseRideServiceLow" bundle:nil];
    }
    loginController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:loginController animated:YES completion:nil];
    }
    else{
        [DashboardCaller homepageSelector:self];
    }
}


-(void)getDefaultCard{
    
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    [self.view setUserInteractionEnabled:NO];
    NSString *URL = [NSString stringWithFormat:@"%@get_default_card.php",BackendBaseURL];
    NSDictionary *params =  @{
                              @"rider_id": [MyUtils getUserDefault:@"riderID"]
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKey:@"status"] isEqualToString:@"0"]) {
            NSData *JSONdata = [[responseObject valueForKey:@"Mycard"] dataUsingEncoding:NSUTF8StringEncoding];
            if (JSONdata != nil) {
                NSError * error =nil;
                NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
                NSMutableArray * arr = [[NSMutableArray alloc]init];
                for (int i = 0; i < [jsonUserInfo count]; i++) {
                    CardMaster * fund = [[CardMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                    [arr addObject:fund];
                }
                [[DataStore sharedInstance] addCards:arr];
            }
            
            [self checkIncompleteRideInRiderEnd]; 
        }
        else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self exampleViewController:self didFinishWithError:error];
    }];
    
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error {
    [self.view setUserInteractionEnabled:YES];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        //[self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
