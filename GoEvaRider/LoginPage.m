//
//  LoginPage.m
//  GoEvaRider
//


#import "LoginPage.h"
#import "RegistrationPage.h"
#import "Dashboard.h"
#import "ForgotPassword.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "DataStore.h"
#import "RestCallManager.h"
#import "MyUtils.h"
#import "GlobalVariable.h"
#import "ForgotPassword.h"
#import "DashboardCaller.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface LoginPage ()

@end

@implementation LoginPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewRoundedInnerSignIn.layer.cornerRadius=15;
    viewRoundedInnerSignIn.clipsToBounds=YES;
    
    btnLoginUsingOtp.backgroundColor = [UIColor lightGrayColor];
    [btnLoginUsingOtp setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
    btnLoginUsingOtp.layer.cornerRadius=5;
    btnLoginUsingOtp.clipsToBounds=YES;
    btnLoginUsingOtp.userInteractionEnabled=NO;
    
    btnLoginUsingPassword.backgroundColor = [UIColor lightGrayColor];
    [btnLoginUsingPassword setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
    btnLoginUsingPassword.layer.cornerRadius=5;
    btnLoginUsingPassword.clipsToBounds=YES;
    btnLoginUsingPassword.userInteractionEnabled=NO;
    
    screenMode=0;
    
    /* Transaparent Background view */
    backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.5;
    /* End Transparent backgorund view*/
    
    [txtMobileNoOrEmailID addTarget:self
                    action:@selector(textFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
    [txtPassword addTarget:self
                    action:@selector(textFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
    
    //Dismiss keyboard when touch any place of view except control and keyboard
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

- (IBAction)registrationPage:(id)sender {
    RegistrationPage *registerController;
    if(appDel.iSiPhone5){
        registerController = [[RegistrationPage alloc] initWithNibName:@"RegistrationPage" bundle:nil];
    }else{
        registerController = [[RegistrationPage alloc] initWithNibName:@"RegistrationPageLow" bundle:nil];
    }
    registerController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:registerController animated:YES completion:nil];
}


// Delegate Method of TextField
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidChange :(UITextField *)textField{
    //NSLog( @"text changed: %@", theTextField.text);
    if (textField.tag == 1) {
        if ([textField.text length]==0) {
            
            btnLoginUsingOtp.backgroundColor = [UIColor lightGrayColor];
            [btnLoginUsingOtp setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
            btnLoginUsingOtp.layer.cornerRadius=5;
            btnLoginUsingOtp.clipsToBounds=YES;
            btnLoginUsingOtp.userInteractionEnabled=NO;
            
            btnLoginUsingPassword.backgroundColor = [UIColor lightGrayColor];
            [btnLoginUsingPassword setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
            btnLoginUsingPassword.layer.cornerRadius=5;
            btnLoginUsingPassword.clipsToBounds=YES;
            btnLoginUsingPassword.userInteractionEnabled=NO;
            
            }
        else{
            
            btnLoginUsingOtp.backgroundColor = UIColorFromRGB(0xC0392B);
            [btnLoginUsingOtp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnLoginUsingOtp.layer.cornerRadius=5;
            btnLoginUsingOtp.clipsToBounds=YES;
            btnLoginUsingOtp.userInteractionEnabled=YES;
            
            btnLoginUsingPassword.backgroundColor = UIColorFromRGB(0xC0392B);
            [btnLoginUsingPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnLoginUsingPassword.layer.cornerRadius=5;
            btnLoginUsingPassword.clipsToBounds=YES;
            btnLoginUsingPassword.userInteractionEnabled=YES;
            
        }
    }
    
    if (textField.tag == 2) {
        if ([txtPassword.text length]!=0) {
            [btnLoginSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmit.png"] forState:UIControlStateNormal];
            [btnLoginSubmit setUserInteractionEnabled:YES];
        }
        else{
            [btnLoginSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
            [btnLoginSubmit setUserInteractionEnabled:NO];
        }
    }
    
}


- (IBAction)requestOTP:(UIButton *)sender {
    
    if([RestCallManager hasConnectivity]){
        
        if (![MyUtils validateMobileNumber:txtMobileNoOrEmailID.text] && ![MyUtils validateEmailWithString:txtMobileNoOrEmailID.text]){
            [self validationAlert:@"Please enter a valid Email ID or Mobile number. "];
            return;
        }
        loginThroughOTP=@"1";
        [txtMobileNoOrEmailID resignFirstResponder];
        sender.backgroundColor = [UIColor lightGrayColor];
        [sender setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
        sender.userInteractionEnabled=NO;
        [self.view setUserInteractionEnabled:NO];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Checking..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForOTP) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
    
    //[self homepageSelector];
}

-(void)requestToServerForOTP{
    
    NSString *bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] requestLoginOTP:txtMobileNoOrEmailID.text loginThroughOTP:loginThroughOTP];
    
    if([bSuccess isEqualToString:@"0"])
    {
        [self performSelectorOnMainThread:@selector(showContactDialog) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(wrongData) withObject:nil waitUntilDone:YES];
    }
}

-(void)showContactDialog{
    [self.view setUserInteractionEnabled:YES];
    
    if (screenMode==0) {
        [loadingView removeFromSuperview];
        [btnLoginSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
        [btnLoginSubmit setUserInteractionEnabled:NO];
        
        if ([loginThroughOTP isEqualToString:@"0"]) {
            btnLoginUsingPassword.backgroundColor = UIColorFromRGB(0xC0392B);
            [btnLoginUsingPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnLoginUsingPassword.layer.cornerRadius=5;
            btnLoginUsingPassword.clipsToBounds=YES;
            btnLoginUsingPassword.userInteractionEnabled=YES;
            
            lblTitleViewOtpVerification.text = @"Password";
            lblBodyMessageViewOtpVerification.hidden=YES;
            txtPassword.text = @"";
            txtPassword.secureTextEntry=YES;
            txtPassword.placeholder = @"Enter Password";
            lblNotRecieveYet.hidden = YES;
            [btnResendOTP setTitle:@"Forgot Password?" forState:UIControlStateNormal];
        }
        else{
            btnLoginUsingOtp.backgroundColor = UIColorFromRGB(0xC0392B);
            [btnLoginUsingOtp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnLoginUsingOtp.layer.cornerRadius=5;
            btnLoginUsingOtp.clipsToBounds=YES;
            btnLoginUsingOtp.userInteractionEnabled=YES;
            
            lblTitleViewOtpVerification.text = @"Verify and login";
            lblBodyMessageViewOtpVerification.hidden=NO;
            txtPassword.text = @"";
            txtPassword.secureTextEntry=NO;
            txtPassword.keyboardType = UIKeyboardTypeNumberPad;
            lblNotRecieveYet.hidden = NO;
            txtPassword.placeholder = @"ENTER 6-DIGIT OTP";
            [btnResendOTP setTitle:@"Resend OTP" forState:UIControlStateNormal];
            
        }
        viewOtpVerification.frame = CGRectMake(0, 568, 320, 315);
        viewSignIn.frame = CGRectMake(20, 40, 280, 315);
        [UIView animateWithDuration:0.5
                              delay:0.5
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             viewOtpVerification.frame = CGRectMake(0, 40, 320, 360);
                             viewSignIn.frame = CGRectMake(20, -365, 280, 315);
                             btnRegister.hidden=YES;
                             
                         }
                         completion:^(BOOL finished){
                         }];
        [innerView addSubview:viewOtpVerification];
        viewRoundedInnerOTP.layer.cornerRadius = 10;
        viewRoundedInnerOTP.clipsToBounds=YES;
        
    }
    else if(screenMode == 1){
        [btnLoginSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
        [btnLoginSubmit setUserInteractionEnabled:NO];
        [loadingView removeFromSuperview];
        txtPassword.text=@"";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Send!!!" message:@"OTP sent successfully. Please check your registered mobile number or Email ID. " preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated: YES completion: nil];
        
        
    }
    
}

-(void)wrongData{
    if ([loginThroughOTP isEqualToString:@"0"]) {
        btnLoginUsingPassword.backgroundColor = UIColorFromRGB(0xC0392B);
        [btnLoginUsingPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnLoginUsingPassword.layer.cornerRadius=5;
        btnLoginUsingPassword.clipsToBounds=YES;
        btnLoginUsingPassword.userInteractionEnabled=YES;
    }
    else{
        btnLoginUsingOtp.backgroundColor = UIColorFromRGB(0xC0392B);
        [btnLoginUsingOtp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnLoginUsingOtp.layer.cornerRadius=5;
        btnLoginUsingOtp.clipsToBounds=YES;
        btnLoginUsingOtp.userInteractionEnabled=YES;
    }
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [self validationAlert:[GlobalVariable getGlobalMessage]];
}

- (IBAction)requestPassword:(UIButton *)sender {
    
    if([RestCallManager hasConnectivity]){
        
        if (![MyUtils validateMobileNumber:txtMobileNoOrEmailID.text] && ![MyUtils validateEmailWithString:txtMobileNoOrEmailID.text]){
            [self validationAlert:@"Please enter a valid Email ID or Mobile number. "];
            return;
        }
        loginThroughOTP=@"0";
        [txtMobileNoOrEmailID resignFirstResponder];
        sender.backgroundColor = [UIColor lightGrayColor];
        [sender setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
        sender.userInteractionEnabled=NO;
        [self.view setUserInteractionEnabled:NO];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Checking..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForOTP) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
    
}

- (IBAction)checkLogin:(UIButton *)sender{
    
    if([RestCallManager hasConnectivity]){
        
        [txtPassword resignFirstResponder];
        [btnLoginSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
        [btnLoginSubmit setUserInteractionEnabled:NO];
        [self.view setUserInteractionEnabled:NO];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Checking..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForLogin) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}





-(void)requestToServerForLogin{
    
    BOOL bSuccess;
    RiderMaster *userObj = [self riderRegistration];
    NSString *jsonString = [userObj JSONRepresentation];
    bSuccess =  [[RestCallManager sharedInstance] login:jsonString];
    
    if(bSuccess)
    {
        riderArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getRider]];
        
        if([riderArray count]>0){
            
            [self performSelectorOnMainThread:@selector(handlingResponseForLogin) withObject:nil waitUntilDone:YES];
        }
        else{
            [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
        }
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(RiderMaster *) riderRegistration{
    NSString *currentDeviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    RiderMaster *user_master =[[RiderMaster alloc] init];
    user_master.id =@"";
    user_master.rider_id=@"";
    user_master.rider_name=@"";
    user_master.rider_mobile=txtMobileNoOrEmailID.text;
    user_master.rider_email=@"";
    user_master.signup_date =@"";
    user_master.password=txtPassword.text;
    user_master.login_through_otp =loginThroughOTP;
    user_master.device_id =currentDeviceId;
    user_master.status=@"";
    user_master.ratting =@"";
    user_master.device_type = @"2"; // 1 -> Android, 2 -> iPhone
    user_master.device_token = [GlobalVariable getDeviceTokenPushNotification];
    return user_master;
}



- (IBAction)resendOTP:(UIButton *)sender{ // Use for resend OTP or Forgot Password
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        
        if ([loginThroughOTP isEqualToString:@"0"]) {
            
            
            
            if([RestCallManager hasConnectivity]){
                
                [self.view setUserInteractionEnabled:NO];
                loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Checking..."];
                [self.view addSubview:loadingView];
                [NSThread detachNewThreadSelector:@selector(requestToServerForgetPasswordOTP) toTarget:self withObject:nil];
            }
            else{
                UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [loginAlert show];
            }
        }
        else{
            screenMode=1;
            loginThroughOTP=@"1";
            loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Sending..."];
            [self.view addSubview:loadingView];
            [NSThread detachNewThreadSelector:@selector(requestToServerForOTP) toTarget:self withObject:nil];
        }
        
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)handlingResponseForLogin{
    [self.view setUserInteractionEnabled:YES];
    riderArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getRider]];
    
    [MyUtils setUserDefault:@"riderMobileNo" value:[[riderArray objectAtIndex:0] rider_mobile]];
    [MyUtils setUserDefault:@"riderEmail" value:[[riderArray objectAtIndex:0] rider_email]];
    [MyUtils setUserDefault:@"riderID" value:[[riderArray objectAtIndex:0] rider_id]];
    [MyUtils setUserDefault:@"profileImage" value:[[riderArray objectAtIndex:0] profile_pic]];
    if ([[riderArray objectAtIndex:0] rider_name] != (id)[NSNull null]) {
        [MyUtils setUserDefault:@"riderName" value:[[riderArray objectAtIndex:0] rider_name]];
    }
    [MyUtils setUserDefault:@"riderRating" value:[[riderArray objectAtIndex:0] ratting]];
    [DashboardCaller homepageSelector:self];
}

-(void)noCarFound{

    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [btnLoginSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmit.png"] forState:UIControlStateNormal];
    [btnLoginSubmit setUserInteractionEnabled:YES];
    [self validationAlert:[GlobalVariable getGlobalMessage]];
}




-(void)requestToServerForgetPasswordOTP{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] forgotPasswordStep1:txtMobileNoOrEmailID.text];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(handleForgotPassword) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(errorInForgotOTP) withObject:nil waitUntilDone:YES];
    }
}

-(void)handleForgotPassword{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
    ForgotPassword *forgotController;
    if(appDel.iSiPhone5){
        forgotController = [[ForgotPassword alloc] initWithNibName:@"ForgotPassword" bundle:nil];
    }else{
        forgotController = [[ForgotPassword alloc] initWithNibName:@"ForgotPasswordLow" bundle:nil];
    }
    forgotController.emailIDOrMobile = txtMobileNoOrEmailID.text;
    forgotController.resetPassMode = 0;// 0 = come from login page, 1 = come from profile page
    forgotController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:forgotController animated:YES completion:nil];
}

-(void)errorInForgotOTP{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:@"There was an error with your request. Please try again. " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated: YES completion: nil];
    
}
-(void)validationAlert:(NSString *)message{
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:backgroundView];
    alertViewWarning.center = CGPointMake(currentWindow.frame.size.width / 2, currentWindow.frame.size.height / 2);
    alertBodyMessage.text=message;
    [currentWindow addSubview:alertViewWarning];
}

- (IBAction)dismissAlertView:(UIButton *)sender{
    [alertViewWarning removeFromSuperview];
    [backgroundView removeFromSuperview];
    btnLoginUsingPassword.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnLoginUsingPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnLoginUsingPassword.layer.cornerRadius=5;
    btnLoginUsingPassword.clipsToBounds=YES;
    btnLoginUsingPassword.userInteractionEnabled=YES;
    
}

- (IBAction)closeOtpPasswordView:(UIButton *)sender{
    
    viewOtpVerification.frame = CGRectMake(0, 40, 320, 315);
    viewSignIn.frame = CGRectMake(20, -365, 280, 315);
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         viewOtpVerification.frame = CGRectMake(0, 568, 320, 315);
                         viewSignIn.frame = CGRectMake(20, 40, 280, 315);
                     }
                     completion:^(BOOL finished){
                         [viewOtpVerification removeFromSuperview];
                         btnRegister.hidden=NO;
                        
                         
                     }];
    screenMode=0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
