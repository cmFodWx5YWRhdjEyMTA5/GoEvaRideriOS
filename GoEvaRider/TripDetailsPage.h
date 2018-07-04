//
//  TripDetailsPage.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/15/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BookingDetailMaster.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import <ASIHTTPRequest.h>

@interface TripDetailsPage : UIViewController{
    AppDelegate *appDel;
    IBOutlet UIView *innerView;
    IBOutlet UIView *_mapViewContainer;
    IBOutlet UILabel *lblRatingHint,*lblRating;
    IBOutlet UILabel *lblBookingDateTime,*lblCarTypeBookingNo, *lblDriverName,*lblCarName;
    IBOutlet UILabel *txtRideFare,*lblFare,*lblDistance,*lblDuration;
    IBOutlet UILabel *lblStartTime, *lblEndTime, *lblPickupLocation,*lblDropLocation;
    IBOutlet UILabel *lblRideFare, *lblTaxes, *lblTotalNetFare;
    IBOutlet UIButton *btnBack;
    IBOutlet UIImageView *imgDriverImage, *imgCancel, *imgCar;
    IBOutlet UIView *viewDriverProfile, *viewCarProfile, *viewFare, *viewLocation, *viewPaymentDetails;
    IBOutlet UIView *viewDriverImage, *viewRatingStar;
    BookingDetailMaster *bookingObj;
}
@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) IBOutlet UIScrollView *backGroundScroll;
@property (nonatomic) NSString *bookingID;
@property (nonatomic,strong) GMSMutablePath *path2;
@property (nonatomic,strong)NSMutableArray *arrayPolylineGreen;
@property (nonatomic,strong) GMSPolyline *polylineBlue;
@property (nonatomic,strong) GMSPolyline *polylineGreen;

- (IBAction)backToPrevious:(UIButton *)sender;
@end
