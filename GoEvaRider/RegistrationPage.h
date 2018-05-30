//
//  RegistrationPage.h
//  GoEvaRider
//


#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RegistrationPage : UIViewController<UIGestureRecognizerDelegate> {
    AppDelegate *appDel;
    UIView *loadingView;
    IBOutlet UIButton *BtnRegSubmit;
    IBOutlet UIView *innerView, *viewRegistration, *viewRoundedRegistration;
    IBOutlet UIView *viewOtpVerification, *viewRoundedOTP;
    IBOutlet UITextField *txtOtpMobileNo,*txtMobileNo, *txtEmailID, *txtPassword, *txtConfirmPassword, *txtOtpNumber;
    UITextField *currTextField;
    IBOutlet UIToolbar *keyboardToolbar;
    IBOutlet UIBarButtonItem *prevBarButton;
    IBOutlet UIBarButtonItem *nextBarButton;
    IBOutlet UIButton *BtnLogin, *btnAlreadyRegistered;
    IBOutlet UIButton *BtnGetOTP, *btnCloseOtpView;
    IBOutlet UIButton *btnVerifyAndRegister;
    NSMutableArray *riderArray;
    NSInteger screenMode;
    IBOutlet UIView *alertViewWarning, *alertViewInnerWarning;
    IBOutlet UILabel *alertTitle, *alertBodyMessage;
    IBOutlet UIButton *alertBtn;
    UIView *backgroundView;
    
}
@property (retain, nonatomic) IBOutlet UIScrollView *backGroundScroll;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *is_resend;

- (IBAction)registerByOTP:(UIButton *)sender;
- (IBAction)registerByNormal:(UIButton *)sender;
- (IBAction)GetOTP:(UIButton *)sender;
- (IBAction)resendOTP:(UIButton *)sender;
- (IBAction)closeOtpView:(UIButton *)sender;
- (IBAction)dismissAlertView:(UIButton *)sender;



@end
