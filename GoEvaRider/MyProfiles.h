//
//  Settings.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface MyProfiles : UIViewController{
    AppDelegate *appDel;
    UIView *loadingView;
    NSMutableArray *profileArray;
    IBOutlet UIView *innerView;
    IBOutlet UIView *viewImgProfile;
    IBOutlet UIImageView *imgProfile;
    IBOutlet UIView *viewFullName, *viewEmail, *viewMobile, *viewChangePassword;
    IBOutlet UILabel *lblFullName, *lblMobileNo, *lblEmailID, *lblRating;
    IBOutlet UITextField *txtPassword;
    IBOutlet UIButton *btnLogout;
}
@property (retain, nonatomic) IBOutlet UIScrollView *backGroundScroll;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *profileType;
- (IBAction)logout:(UIButton *)sender;
@end
