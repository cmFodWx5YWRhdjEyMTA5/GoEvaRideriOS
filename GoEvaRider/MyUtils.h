//
//  MyUtils.h
//  EditFX
//
//  Created by Kalyan Mohan Paul on 10/14/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "LocationData.h"
#import "PickCar.h"
@interface MyUtils : NSObject{
    
    NSUserDefaults *userDefaults;
    AppDelegate *appDel;
    NSMutableArray *userDetails;
    
}

-(id)init;
+(UIView *) customLoader:(UIWindow *)mainWindow;
+(UIView *) customLoaderWithText:(UIWindow *)mainWindow loadingText:(NSString *)loadingText;
+(UIView *) customLoaderFullWindowWithText:(UIWindow *)mainWindow loadingText:(NSString *)loadingText;
+ (void) setUserDefault:(NSString *)key value:(NSString *)value; // set NSUserDefault value
+ (NSString *) getUserDefault:(NSString *)key;                   // get NSUserDefault Value
+(void) removeAllNSUserDefaults;                                 // remove all NSUserDefault
+(void) removeParticularObjectFromNSUserDefault:(NSString *)key; // remove particular Object from NSUserDefault
+ (void)saveCustomObject:(LocationData *)object key:(NSString *)key; // Set Custom Object to NSUserDefault
+ (LocationData *)loadCustomObjectWithKey:(NSString *)key;           // Get Custom Object from NSUserDefault

-(void)setupMenuBarButtonItems:(UIViewController *)controller tilteLable:(NSString *) title;
+(NSMutableArray *)sortArrayAlphabetically:(NSMutableArray *)contentArray key:(NSString *)key;
+ (NSString *)encodeToBase64String:(UIImage *)image; // Encode Image to Base64
+ (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size;
+ (BOOL)validateEmailWithString:(NSString*)email;
+ (BOOL)validateMobileNumber:(NSString*)number;
+(NSNumber *)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2;

@end
