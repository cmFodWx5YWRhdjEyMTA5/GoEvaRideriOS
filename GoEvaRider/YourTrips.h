//
//  YourTrips.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface YourTrips : UIViewController{
    AppDelegate *appDel;
    UIView *loadingView;
    NSMutableArray *tripArray;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UITableView *tableViewTrip;
@end
