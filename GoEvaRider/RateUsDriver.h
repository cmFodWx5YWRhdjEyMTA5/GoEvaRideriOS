//
//  RateUsDriver.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 1/9/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookingDetailMaster.h"
#import "AppDelegate.h"
#import "DriverMaster.h"

@protocol senddataProtocol <NSObject>

-(void)sendDataBckToTripList;

@end

@interface RateUsDriver : UIViewController<UITextViewDelegate>{
    
    AppDelegate *appDel;
    IBOutlet UIButton *btnRateUs, *btnBack, *btnClose;
    IBOutlet UILabel *lblDriverName, *lblTitle;
    IBOutlet UIImageView *imgDriverImage;
    NSMutableArray *fareSummaryArray, *driverDetails;
    
    DriverMaster *driverObj;
    UIView *loadingView;
    IBOutlet UIView *viewDriverImage, *viewComments;
    IBOutlet UITextView  *comments;
    UILabel *lbl;
    BookingDetailMaster *bookingObj;
}

@property (nonatomic) NSString *ratting;
@property (nonatomic) NSString *bookingID, *driverImage, *driverName;
@property (nonatomic) NSString *screenMode;// 0 = means from stripe page, 1 = means from trip details page.
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,assign)id delegate;

- (IBAction)rateUsDriver:(UIButton *)sender;
- (IBAction)backToPreviousPage:(UIButton *)sender;
- (IBAction)goToHomePage:(UIButton *)sender;

@end
