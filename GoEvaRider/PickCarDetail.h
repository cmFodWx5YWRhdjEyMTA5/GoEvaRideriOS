//
//  PickCarDetail.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 10/12/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import <ASIHTTPRequest.h>
#import "LocationData.h"

@protocol senddataProtocol <NSObject>

-(void)sendDataToPickCarPageOnBackPressed:(NSString *)mode;

@end

@interface PickCarDetail : UIViewController{
    AppDelegate *appDel;
    IBOutlet UIButton *btnConfirmBooking;
    IBOutlet UIView *viewChooseCar;
    IBOutlet UILabel *lblCar;
    IBOutlet UILabel *lblPickupLocation, *lblDropLocation, *lblPricePerMile, *lblAwayTime;
    IBOutlet UIImageView *imgCar;
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
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,assign)id delegate;
@property (nonatomic,strong) GMSMutablePath *path2;
@property (nonatomic,strong)NSMutableArray *arrayPolylineGreen;
@property (nonatomic,strong) GMSPolyline *polylineBlue;
@property (nonatomic,strong) GMSPolyline *polylineGreen;
@property (nonatomic) NSInteger modeAddCard;

- (IBAction)confirmBooking:(UIButton *)sender;
- (IBAction)backToPickCarPage:(UIButton *)sender;


@end
