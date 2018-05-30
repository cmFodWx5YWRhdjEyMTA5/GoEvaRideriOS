//
//  SideMenuViewController.h
//  GeoCouponAlert
//
//  Created by Kalyan Mohan Paul on 9/19/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"


@interface SideMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    AppDelegate *appDel;
    IBOutlet UITableView *couponTableView;
    IBOutlet UIView *headerView, *viewImg;
    IBOutlet UILabel *riderName, *rider_rating;
    IBOutlet UIImageView *profileImageView;
    IBOutlet UIButton *btnLinkForGoEvaDriverApp;
    
}
@property (strong, nonatomic) UIWindow *window;

@end
