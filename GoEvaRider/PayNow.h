//
//  PayNow.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PayNow : UIViewController{
    
    AppDelegate *appDel;
    IBOutlet UILabel *lblPrice, *lblCardNameWithLast4, *lblDontHaveCard, *lblPaymentDesc;
    IBOutlet UIButton *btnPayNow, *btnBack, *btnAddOrChangeCard;
    IBOutlet UIImageView *imgCard;
    IBOutlet UIView *viewCardList, *loadingView;
    UIActivityIndicatorView *activityIndicator;
    IBOutlet UITableView *tableViewCard;
    NSMutableArray *cardArray;
}

@property (nonatomic) double amount;
@property (nonatomic) NSString *bookingID,  *driverImage, *driverName;
@property (nonatomic) NSInteger modeAddCard;
@property (strong, nonatomic) UIWindow *window;
- (IBAction)backToPage:(UIButton *)sender;
- (IBAction)payNow:(id)sender;
- (IBAction)AddOrChangeCard:(id)sender;

@end
