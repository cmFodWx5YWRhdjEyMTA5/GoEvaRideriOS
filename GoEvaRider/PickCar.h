//
//  PickCar.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 10/10/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import "LocationData.h"


@interface PickCar : UIViewController<GMSMapViewDelegate>{
    AppDelegate *appDel;
    IBOutlet UIView *viewFrom, *viewTo;
    IBOutlet UIView *outerViewFrom, *outerViewTo;
    IBOutlet UIImageView *markerFrom, *markerTo,*img_editFrom, *img_editTo;
    UIBezierPath *shadowPath, *shadowPath2;
    IBOutlet UIView *viewChooseCar;
    IBOutlet UIView *viewChooseCarPro;
    IBOutlet UIView *viewChooseCarGRP;
    IBOutlet UITextField *txtPickupLocation;
    IBOutlet UITextField *txtDropLocation;
    IBOutlet UIView *_mapViewContainer;
    IBOutlet UIView *inputViewContainer;
    IBOutlet UIView *lblViewChooseCar, *lblViewChooseCarPro, *lblViewChooseCarGRP;
    IBOutlet UILabel *lblCar, *lblCarPro, *lblCarGRP;
    NSString *userCurrentLat, *userCurrentLong;
    NSString *selectedCarType, *carAvaialblityID;
    NSMutableArray *carAvailablityArray;
    LocationData *pickupLocation, *dropLocation;
    NSString *textFieldFromMode, *textFieldToMode;
    NSInteger returnPickupAddressMode, returnDropAddressMode;
    NSString *modeForViewControllerDismiss;

}
@property (nonatomic) NSString *pageTitle;
@property (nonatomic) NSArray *fromAddressArray;
@property (nonatomic) NSString *fromAddress;
@property (nonatomic) NSString *toAddress;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, retain) NSMutableArray *googleMapsDriverPins;
- (IBAction)rideNowBtn:(UIButton *)sender;
- (IBAction)backToHomePage:(id)sender;

@end
