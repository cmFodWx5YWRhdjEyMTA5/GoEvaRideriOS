//
//  CompleteRide.h
//  GoEvaRider
//


#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "BookingDetailMaster.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import <ASIHTTPRequest.h>
#import "DashboardCaller.h"

@interface CompleteRide : UIViewController{
    AppDelegate *appDel;
    IBOutlet UIButton *btnClose;
    IBOutlet UIView *innerView;
    IBOutlet UIView *_mapViewContainer;
    IBOutlet UILabel *lblBookingDateTime,*lblCarTypeBookingNo, *lblDriverName,*lblCarName;
    IBOutlet UILabel *lblFare,*lblDistance,*lblDuration;
    IBOutlet UILabel *lblStartTime, *lblEndTime, *lblPickupLocation,*lblDropLocation;
    IBOutlet UILabel *lblRideFare, *lblTaxes, *lblTotalNetFare;
    IBOutlet UIImageView *imgDriverImage, *imgCar;
    IBOutlet UIView *viewDriverProfile, *viewCarProfile, *viewFare, *viewLocation, *viewPaymentDetails;
    IBOutlet UIView *viewDriverImage;
}
@property (strong, nonatomic) UIWindow *window;
@property (retain, nonatomic) IBOutlet UIScrollView *backGroundScroll;
@property (nonatomic) NSString *bookingID;
@property (nonatomic) BOOL isRestartApp;
@property (nonatomic) BookingDetailMaster *bookingObj;
@property (nonatomic,strong) GMSMutablePath *path2;
@property (nonatomic,strong)NSMutableArray *arrayPolylineGreen;
@property (nonatomic,strong) GMSPolyline *polylineBlue;
@property (nonatomic,strong) GMSPolyline *polylineGreen;
- (IBAction)goToHomePage:(UIButton *)sender;

@end
