//
//  LoginPage.h
//  GoEvaRider
//


#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginPage : UIViewController<UIGestureRecognizerDelegate>{
    AppDelegate *appDel;
    IBOutlet UIButton *btnLoginUsingOtp, *btnLoginUsingPassword,*btnRegister, *btnForgotPassword;
    IBOutlet UIButton *btnCloseOtpPasswordView,*btnLoginSubmit;
    IBOutlet UIView *viewSignIn,*viewRoundedInnerSignIn;
    IBOutlet UIView *viewOtpVerification, *viewRoundedInnerOTP;
    IBOutlet UILabel *lblTitleViewOtpVerification, *lblBodyMessageViewOtpVerification, *lblNotRecieveYet;
    IBOutlet UIButton *btnResendOTP;
    IBOutlet UIView *innerView;
    UIView *loadingView;
    IBOutlet UITextField *txtMobileNoOrEmailID, *txtPassword;
    UITextField *currTextField;
    UIView *backgroundView;
    NSMutableArray *riderArray;
    NSInteger screenMode;
    NSString *loginThroughOTP;
    IBOutlet UIView *alertViewWarning, *alertViewInnerWarning;
    IBOutlet UILabel *alertTitle, *alertBodyMessage;
    IBOutlet UIButton *alertBtn;
}

@property (strong, nonatomic) UIWindow *window;
- (IBAction)registrationPage:(UIButton *)sender;
- (IBAction)requestOTP:(UIButton *)sender;
- (IBAction)requestPassword:(UIButton *)sender;
- (IBAction)checkLogin:(UIButton *)sender;
- (IBAction)closeOtpPasswordView:(UIButton *)sender;
- (IBAction)resendOTP:(UIButton *)sender;// Use for resend OTP or Forgot Password



@end
