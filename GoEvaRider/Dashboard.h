//
//  Dashboard.h
//  GoEvaRider
//
//  Created by Kalyan Paul on 13/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import "LocationData.h"

@interface Dashboard : UIViewController<GMSMapViewDelegate>{
    AppDelegate *appDel;
    IBOutlet UIView *viewFrom, *viewTo;
    IBOutlet UIView *outerViewFrom, *outerViewTo;
    IBOutlet UIImageView *markerFrom, *markerTo,*img_editFrom, *img_editTo;
    UIBezierPath *shadowPath, *shadowPath2;
    IBOutlet UIButton *btnPickCar, *btnRideNow;
    IBOutlet UIView *viewChooseCar;
    IBOutlet UIView *viewChooseCarPro;
    IBOutlet UIView *viewChooseCarGRP;
    IBOutlet UITextField *txtPickupLocation;
    IBOutlet UITextField *txtDropLocation;
    IBOutlet UIView *_mapViewContainer;
    IBOutlet UIView *inputViewContainer;
    IBOutlet UIImageView *loaderImg1,*loaderImg2,*loaderImg3;
    IBOutlet UILabel *lblTime1, *lblTime2, *lblTime3;
    IBOutlet UIView *lblViewChooseCar, *lblViewChooseCarPro, *lblViewChooseCarGRP;
    IBOutlet UILabel *lblCar, *lblCarPro, *lblCarGRP;
    NSString *userCurrentLat, *userCurrentLong;
    NSString *selectedCarType;
    NSMutableArray *carAvailablityArray;
    LocationData *pickupLocation, *dropLocation;
    NSString *textFieldFromMode, *textFieldToMode;
    NSInteger returnPickupAddressMode, returnDropAddressMode;
    NSString *modeForViewControllerDismiss;
    UIView *loadingView;
    IBOutlet UIView *viewBadge1, *viewBadge2, *viewBadge3;
    IBOutlet UILabel *lblBadge1, *lblBadge2, *lblBadge3;
    
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *pageTitle;
@property (nonatomic) NSArray *fromAddressArray;
@property (nonatomic) NSString *fromAddress;
@property (nonatomic) NSString *toAddress;
- (IBAction)rideNowBtn:(UIButton *)sender;


@end
