//
//  CancelTrip.h
//  GoEva
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LegalMaster.h"
@interface CancelTrip : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    AppDelegate *appDel;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSubmit, *btnPolicy, *btnCloseCancellationView;
    IBOutlet UILabel *lblcancellationCharge;
    IBOutlet UIView *viewCancellation;
    IBOutlet UIWebView *cancellationPolicyWebView;
    UIView *backgroundView;
    UIView *loadingView;
    NSMutableArray *cancelReasonArray;
    NSString *reasonID;
    NSMutableArray *legalArray;
    LegalMaster *legalObj;
    UIActivityIndicatorView *mySpinner;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *userCurrentLat, *userCurrentLong, *bookingID;
@property (nonatomic) BOOL isCancellationCharge;
@property (strong, nonatomic) IBOutlet UITableView *tableCancelTrip;
- (IBAction)submitCancelTripFeedback:(UIButton *)sender;
- (IBAction)backToPage:(UIButton *)sender;
- (IBAction)cancellationPolicy:(UIButton *)sender;
- (IBAction)closeCancellationPolicyView:(UIButton *)sender;

@end
