//
//  CredentailPage.h
//  GoEvaRider
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MYBlurIntroductionView.h"
#import <CoreLocation/CoreLocation.h>

@interface CredentailPage : UIViewController<CLLocationManagerDelegate,MYIntroductionDelegate>{
    AppDelegate *appDel;
    IBOutlet UIButton *btnSignIn;
    IBOutlet UIButton *btnSignUp;
}

@property (strong, nonatomic) UIWindow *window;
@property CLLocationManager * locationManager;
- (IBAction)openSignInScreen:(UIButton *)sender;
- (IBAction)openSignUpScreen:(id)sender;
@end
