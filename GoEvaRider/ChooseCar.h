//
//  ChooseCar.h
//  GoEvaRider
//
//  Created by Kalyan Paul on 14/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import <ASIHTTPRequest.h>
#import "LocationData.h"



@interface ChooseCar : UIViewController{
    AppDelegate *appDel;
    IBOutlet UIButton *btnPickCar;
    IBOutlet UIButton *btnConfirmBooking;
    IBOutlet UIView *outerViewChooseCar, *outerViewChooseCarPro, *outerViewChooseCarGRP;
    IBOutlet UIView *viewChooseCar, *viewChooseCarPro, *viewChooseCarGRP;
    IBOutlet UIView *lblViewChooseCar, *lblViewChooseCarPro, *lblViewChooseCarGRP;
    IBOutlet UILabel *lblCar, *lblCarPro, *lblCarGRP;
    IBOutlet UILabel *lblPickupLocation, *lblDropLocation, *lblPricePerMile, *lblAwayTime;
    NSMutableArray *carArray;
    int mode;
    IBOutlet UIView *_mapViewContainer;
    LocationData *pickupLocation, *dropLocation;
    CLLocation *pickupData, *dropData;
    NSMutableArray *carAvailablityArray;
    UIView *loadingView;
    
    IBOutlet UILabel *lblCardName,*lblCardNameWithLast4;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UIView *viewCard;
    NSMutableArray *cardArray;
    IBOutlet UIButton *btnAddOrChangeCard;
}

@property (nonatomic) NSString *selectedCar;
@property (nonatomic) NSString *availabilityID;
@property (nonatomic) NSString *awayTimeFromCustomer;
@property (nonatomic) NSString *estimatedFareCostPerMile;
@property (nonatomic) NSString *carAvailablityModeFor30Sec;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) GMSMutablePath *path2;
@property (nonatomic,strong)NSMutableArray *arrayPolylineGreen;
@property (nonatomic,strong) GMSPolyline *polylineBlue;
@property (nonatomic,strong) GMSPolyline *polylineGreen;
@property (nonatomic) NSInteger modeAddCard;

- (IBAction)confirmBooking:(UIButton *)sender;
- (IBAction)backToHomePage:(UIButton *)sender;

@end
