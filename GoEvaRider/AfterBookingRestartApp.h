//
//  AfterBookingRestartApp.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 8/20/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import <ASIHTTPRequest.h>
#import "LocationData.h"


@interface AfterBookingRestartApp : UIViewController<GMSMapViewDelegate> {
    AppDelegate *appDel;
    IBOutlet UIView *bookedDriver;
    IBOutlet UIView *bookedCarNumber;
    IBOutlet UIView *bookedCarType;
    IBOutlet UIImageView *imgRidepath;
    IBOutlet UIImageView *imgProfile, *imgPlateNo, *imgCar;
    IBOutlet UILabel *lblAwayTime;
    IBOutlet UILabel *lblDriverName, *lblPlateNo, *lblCarName, *lblRating;
    IBOutlet UILabel *lblPickupAddress, *lblArrivalTime, *lblPricePerMile;
    NSMutableArray *carArray;
    
    IBOutlet UIButton *btnContactDriver, *btnCancelBook;
    IBOutlet UIView *_mapViewContainer, *viewContact;
    IBOutlet UIView *btnMessage, *btnCall;
    IBOutlet UILabel *viewLblName, *viewLblMobile;
    UIView *backgroundView;
    LocationData *pickupLocation, *dropLocation;
    UIView *loadingView;
    IBOutlet UIView *viewNotification, *viewInnerNotification;
    IBOutlet UIView *viewImgDriverNotification;
    IBOutlet UIView *viewOnTheWay;
    IBOutlet UIImageView *imgProfileNotification;
    IBOutlet UILabel *lblDriverNameNotification, *lblCarNameAndNumberNotification, *lblRatingANotification,
    *lblStatusNotification, *lblDriverRunningStatus;
    NSMutableArray *driverLiveArray;
    IBOutlet UIButton *btnRefreshDriver;
    
    IBOutlet UILabel *lblCardNameWithLast4;
    IBOutlet UIImageView *imgCard;
    UIActivityIndicatorView *activityIndicator;
    IBOutlet UIView *viewCard;
    NSMutableArray *cardArray;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *userCurrentLat, *userCurrentLong, *bookingID;
@property (nonatomic) BOOL isCancellationCharge;
@property (nonatomic) NSDictionary *notificationDriverDetailsDict;
@property (nonatomic,strong) GMSMutablePath *path2;
@property (nonatomic,strong)NSMutableArray *arrayPolylineGreen;
@property (nonatomic,strong) GMSPolyline *polylineBlue;
@property (nonatomic,strong) GMSPolyline *polylineGreen;

- (IBAction)closeContactPopup:(UIButton *)sender;
- (IBAction)cancelBooking:(UIButton *)sender;
- (IBAction)refreshDriverLocation:(UIButton *)sender;
@end

