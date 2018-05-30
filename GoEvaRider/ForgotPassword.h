//
//  ForgotPassword.h
//  GoEvaRider
//
//  Created by Kalyan Paul on 19/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ForgotPassword : UIViewController<UIGestureRecognizerDelegate>{
    
    AppDelegate *appDel;
    IBOutlet UIButton *btnVerifyOTP, *btnResendOTP;
    IBOutlet UIButton *btnResetSubmit;
    IBOutlet UIView *viewNewPassword,*viewRoundedInnerNewPassword;
    IBOutlet UIView *viewOtpVerification, *viewRoundedInnerOTP;
    IBOutlet UIView *innerView;
    UIView *loadingView;
    IBOutlet UITextField *txtOTP, *txtNewPassword, *txtConfirmPassword;
    UITextField *currTextField;
    UIView *backgroundView;
    NSMutableArray *riderArray;
    IBOutlet UIView *alertViewWarning, *alertViewInnerWarning;
    IBOutlet UILabel *alertTitle, *alertBodyMessage;
    IBOutlet UIButton *alertBtn;
}
@property (nonatomic) NSString *emailIDOrMobile;
@property (nonatomic) NSInteger resetPassMode;
@property (nonatomic) NSInteger resendOtpMode;
@property (strong, nonatomic) UIWindow *window;
- (IBAction)resendOTP:(UIButton *)sender;
- (IBAction)setNewPassword:(UIButton *)sender;
- (IBAction)verifyOTP:(UIButton *)sender;
- (IBAction)closeAlert:(UIButton *)sender;
- (IBAction)backToPage:(UIButton *)sender;

@end
