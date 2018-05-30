//
//  AppDelegate.m
//  GoEvaRider
//
//  Created by Kalyan Paul on 09/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "AppDelegate.h"
#import "CredentailPage.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "SDKDemoAPIKey.h"
#import "Dashboard.h"
#import "GlobalVariable.h"
#import "Splash.h"
#import "YourTrips.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <Stripe/Stripe.h>
#import "Constant.h"
#import "CompleteRide.h"
#import "AfterBooking.h"

#define CDV_IsIPhone5() ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] bounds].size.width == 320)

#define CONFIRM_BOOKING  1
#define DRIVER_ONE_MIN_AWAY  2
#define DRIVER_IS_ARRIVED  3
#define START_TRIP  4
#define CANCEL_TRIP_BY_DRIVER  5
#define TRIP_COMPLETE  6
#define NO_CAB_FOUND 7

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize iSiPhone5,iSiPad;
Splash *splash;
//Dashboard *splash;
//YourTrips *splash;
//CompleteRide *splash;

AVAudioPlayer *player;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;// To disable sleep time
    
    if (StripePublishableKey) {
        [Stripe setDefaultPublishableKey:StripePublishableKey];
    }
    
    //NSLog(@"Build version: %d", __apple_build_version__);
    
    // Do a quick check to see if you've provided an API key, in a real app you wouldn't need this but
    // for the demo it means we can provide a better error message.
    if (!kAPIKey.length) {
        // Blow up if APIKeys have not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure APIKeys inside SDKDemoAPIKey.h for your  bundle `%@`, see "
        @"README.GooglePlacesDemos for more information";
        @throw [NSException exceptionWithName:@"DemoAppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    
    // Provide the Places API with your API key.
    [GMSPlacesClient provideAPIKey:kAPIKey];
    // Provide the Maps API with your API key. You may not need this in your app, however we do need
    // this for the demo app as it uses Maps.
    [GMSServices provideAPIKey:kAPIKey];
    
    // Log the required open source licenses! Yes, just NSLog-ing them is not enough but is good for
    // a demo.
    //NSLog(@"Google Maps open source licenses:\n%@", [GMSServices openSourceLicenseInfo]);
    //NSLog(@"Google Places open source licenses:\n%@", [GMSPlacesClient openSourceLicenseInfo]);
    
    
    // Start Push Notification
    // Register for Remote Notifications
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0){
        UIUserNotificationSettings *settings=[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|
                                              UIUserNotificationTypeBadge|
                                              UIUserNotificationTypeSound  categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];
    }
    /* End Push Notification */
    
    
    /* <=========== For Push notification ============> */
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification) {
        //NSLog(@"New App Launch with Notifiction");
        NSDictionary *notificationArray= [remoteNotification valueForKey:@"aps"];
        NSInteger notification_mode = [[NSString stringWithFormat:@"%@", [notificationArray valueForKey:@"notification_mode"]] integerValue];
        if (notification_mode == CONFIRM_BOOKING) {
            AfterBooking *afterBooking;
            if (CDV_IsIPhone5()) {
                afterBooking = [[AfterBooking alloc] initWithNibName:@"AfterBooking" bundle:nil];
            }
            else{
                afterBooking = [[AfterBooking alloc] initWithNibName:@"AfterBookingLow" bundle:nil];
            }
            afterBooking.notificationDriverDetailsDict = notificationArray;
            [self.window setRootViewController:afterBooking];
            [self.window makeKeyAndVisible];
        }
        
    }
    /* End */
    else{
        
        if (CDV_IsIPhone5()) {
            self.iSiPhone5 = YES;
            splash = [[Splash alloc] initWithNibName:@"Splash" bundle:nil];
            
        } else {
            self.iSiPhone5 = NO;
            splash = [[Splash alloc] initWithNibName:@"SplashLow" bundle:nil];
        }
    [self.window setRootViewController:splash];
    [self.window makeKeyAndVisible];
    }
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    splash = [[Dashboard alloc] initWithNibName:@"Dashboard" bundle:nil];
//    [self.window setRootViewController:splash];
//    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL stripeHandled = [Stripe handleStripeURLCallbackWithURL:url];
    if (stripeHandled) {
        return YES;
    } else {
        // This was not a stripe url – do whatever url handling your app
        // normally does, if any.
    }
    return NO;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.deviceToken = [[[[deviceToken description]
                          stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    [GlobalVariable setDeviceTokenPushNotification:self.deviceToken];
    //NSLog(@"Did Register for Remote Notifications with Device Token (%@)", self.deviceToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //NSLog(@"Did Fail to Register for Remote Notifications");
    //NSLog(@"%@, %@", error, error.localizedDescription);
    
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    NSDictionary *notificationArray= [userInfo valueForKey:@"aps"];
    NSString *message = [notificationArray valueForKey:@"alert"];
    NSInteger notification_mode = [[NSString stringWithFormat:@"%@", [notificationArray valueForKey:@"notification_mode"]] integerValue];
        
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        /* NSString *soundFilePath = [NSString stringWithFormat:@"%@/foo.mp3",[[NSBundle mainBundle] resourcePath]];
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSError *error;
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:&error];
        player.numberOfLoops = -1; //Infinite
        [player play];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Booking Confirmed!!!"
                                                        message:@"Driver is 5 min away from you."
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        alert.tag=200;
        [alert show];*/
        if (notification_mode==CONFIRM_BOOKING) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForBookConfirmation" object:nil userInfo:userInfo];
        }
        else if(notification_mode == NO_CAB_FOUND){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForNoCabFound" object:nil userInfo:userInfo];
        }
        else if(notification_mode == DRIVER_IS_ARRIVED || notification_mode == START_TRIP){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForDriverArrivalAndStartTrip" object:nil userInfo:userInfo];
        }
        else if(notification_mode == CANCEL_TRIP_BY_DRIVER){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForCancelTrip" object:nil userInfo:userInfo];
        }
        else if(notification_mode == TRIP_COMPLETE){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForTripComplete" object:nil userInfo:userInfo];
        }
        
    }
    
    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground)
    {
        
        if (notification_mode==CONFIRM_BOOKING) {
            
            NSString* contentAvailable = [NSString stringWithFormat:@"%@", [notificationArray valueForKey:@"content-available"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForBookConfirmation" object:nil userInfo:userInfo];
        }
        else if(notification_mode == NO_CAB_FOUND){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForNoCabFound" object:nil userInfo:userInfo];
        }
        else if(notification_mode == DRIVER_IS_ARRIVED || notification_mode == START_TRIP){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForDriverArrivalAndStartTrip" object:nil userInfo:userInfo];
        }
        else if(notification_mode == CANCEL_TRIP_BY_DRIVER){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForCancelTrip" object:nil userInfo:userInfo];
        }
        else if(notification_mode == TRIP_COMPLETE){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationForTripComplete" object:nil userInfo:userInfo];
        }
        
    }
    completionHandler(UIBackgroundFetchResultNoData);
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // My OK button
    if (alertView.tag==200) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            [player stop];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotificationData" object:nil userInfo:nil];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
