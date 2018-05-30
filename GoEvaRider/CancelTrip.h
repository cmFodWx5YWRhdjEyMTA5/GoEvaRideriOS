//
//  CancelTrip.h
//  GoEva
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface CancelTrip : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    AppDelegate *appDel;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnSubmit;
    UIView *backgroundView;
    UIView *loadingView;
    NSMutableArray *cancelReasonArray;
    NSString *reasonID;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *userCurrentLat, *userCurrentLong, *bookingID;
@property (strong, nonatomic) IBOutlet UITableView *tableCancelTrip;
- (IBAction)submitCancelTripFeedback:(UIButton *)sender;
- (IBAction)backToPage:(UIButton *)sender;

@end
