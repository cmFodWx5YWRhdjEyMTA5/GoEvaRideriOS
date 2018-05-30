//
//  RegistrationPage.m
//  GoEvaRider
//


#import "RegistrationPage.h"
#import "LoginPage.h"
#import "AddCard.h"
#import "DataStore.h"
#import "RestCallManager.h"
#import "MyUtils.h"
#import "GlobalVariable.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface RegistrationPage ()

@end

@implementation RegistrationPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    viewRoundedRegistration.layer.cornerRadius=15;
    viewRoundedRegistration.clipsToBounds=YES;
    alertViewInnerWarning.layer.cornerRadius=3;
    alertViewInnerWarning.clipsToBounds=YES;
    BtnGetOTP.backgroundColor = [UIColor lightGrayColor];
    [BtnGetOTP setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
    BtnGetOTP.userInteractionEnabled=NO;
    screenMode=0;
    
    /* Transaparent Background view */
    backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.5;
    
    /* End Transparent backgorund view*/
    
    [txtOtpMobileNo addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    [txtEmailID addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [txtMobileNo addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    [txtPassword addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    [txtConfirmPassword addTarget:self
                    action:@selector(textFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
    
    [txtOtpNumber addTarget:self
                    action:@selector(textFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
    
    //Dismiss keyboard when touch any place of view except control and keyboard
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    
    CGSize scrollViewSize = CGSizeMake(320,568);
    [self.backGroundScroll setContentSize:scrollViewSize];
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerByOTP:(id)sender {
    
    if([RestCallManager hasConnectivity]){
        
        [self.view setUserInteractionEnabled:NO];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Registering..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerRegisterWithOTP) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

- (IBAction)registerByNormal:(id)sender {
    
    if([RestCallManager hasConnectivity]){
        
        if(self.validationForm){
            [txtMobileNo resignFirstResponder];
            [txtEmailID resignFirstResponder];
            [txtPassword resignFirstResponder];
            [self.view setUserInteractionEnabled:NO];
            loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Registering..."];
            [self.view addSubview:loadingView];
            [NSThread detachNewThreadSelector:@selector(requestToServerRegisterWithNormal) toTarget:self withObject:nil];
        }
        
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(BOOL)validationForm{
    
    if (![MyUtils validateEmailWithString:txtEmailID.text]){
        [self validationAlert:@"Please enter a valid email address"];
        return NO;
    }
    else if (![MyUtils validateMobileNumber:txtMobileNo.text]){
        
        [self validationAlert:@"Please enter a valid Mobile number."];
        return NO;
    }
    else if ([txtPassword.text isEqualToString:@""] || [[txtPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self validationAlert:@"Please enter password."];
        return NO;
    }
    else if ([txtPassword.text length]<6){
        [self validationAlert:@"Password should not be less than 6 character"];
        return NO;
    }
    else if ([txtConfirmPassword.text isEqualToString:@""] || [[txtConfirmPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [self validationAlert:@"Please confirm password."];
        return NO;
    }
    else if(![txtPassword.text isEqualToString: txtConfirmPassword.text]){
        [self validationAlert:@"Confirm password does not match."];
        return NO;
        
    }
    
    return YES;
}

- (IBAction)GetOTP:(UIButton *)sender {
    
    if([RestCallManager hasConnectivity]){
        
        if (![MyUtils validateMobileNumber:txtOtpMobileNo.text]){
            
            [self validationAlert:@"Please enter a valid Mobile number."];
            return;
        }
        _is_resend=@"0";
        [txtOtpMobileNo resignFirstResponder];
        sender.backgroundColor = [UIColor lightGrayColor];
        [sender setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
        sender.userInteractionEnabled=NO;
        [self.view setUserInteractionEnabled:NO];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Checking..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServer) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}
- (IBAction)resendOTP:(UIButton *)sender{
    if([RestCallManager hasConnectivity]){
        _is_resend=@"1";
        [self.view setUserInteractionEnabled:NO];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Sending..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServer) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServer{
    
    NSString *bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] requestRegistrationOTP:txtOtpMobileNo.text  is_resend:_is_resend];
    
    if([bSuccess isEqualToString:@"0"])
    {
        [self performSelectorOnMainThread:@selector(showContactDialog) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(void)requestToServerRegisterWithOTP{
    
    BOOL bSuccess;
    NSString *currentDeviceId = [[[UIDevice currentDevice] identifierForVendor]UUIDString];
    bSuccess =  [[RestCallManager sharedInstance] registrationByOTP:txtOtpMobileNo.text sendOtp:txtOtpNumber.text deviceID:currentDeviceId deviceType:@"2" deviceToken:[GlobalVariable getDeviceTokenPushNotification]];
    
    if(bSuccess)
    {
        riderArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getRider]];
        
        if([riderArray count]>0){
            
            [self performSelectorOnMainThread:@selector(handlingResponseForRegistration) withObject:nil waitUntilDone:YES];
        }
        else{
            [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
        }
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(void)requestToServerRegisterWithNormal{
    
    BOOL bSuccess;
    RiderMaster *userObj = [self riderRegistration];
    NSString *jsonString = [userObj JSONRepresentation];
    bSuccess =  [[RestCallManager sharedInstance] registrationByNormal:jsonString];
    
    if(bSuccess)
    {
        riderArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getRider]];
        
        if([riderArray count]>0){
            
            [self performSelectorOnMainThread:@selector(handlingResponseForRegistration) withObject:nil waitUntilDone:YES];
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
    user_master.rider_mobile=txtMobileNo.text;
    user_master.rider_email=txtEmailID.text;
    user_master.signup_date =@"";
    user_master.password=txtPassword.text;
    user_master.login_through_otp =@"";
    user_master.device_id =currentDeviceId;
    user_master.status=@"";
    user_master.ratting =@"";
    user_master.device_type = @"2"; // 1 -> Android, 2 -> iPhone
    user_master.device_token = [GlobalVariable getDeviceTokenPushNotification];
    
    return user_master;
}

-(void)showContactDialog{
    [self.view setUserInteractionEnabled:YES];
    
    
    if (screenMode==0) {
        [loadingView removeFromSuperview];
        BtnGetOTP.backgroundColor = UIColorFromRGB(0xC0392B);
        [BtnGetOTP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        BtnGetOTP.userInteractionEnabled=YES;
        viewOtpVerification.frame = CGRectMake(0, 568, 320, 360);
        viewRegistration.frame = CGRectMake(20, 40, 280, 475);
        [UIView animateWithDuration:0.5
                              delay:0.5
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             viewOtpVerification.frame = CGRectMake(0, 40, 320, 360);
                             viewRegistration.frame = CGRectMake(20, -525, 280, 475);
                             btnAlreadyRegistered.hidden=YES;
                         }
                         completion:^(BOOL finished){
                         }];
        [innerView addSubview:viewOtpVerification];
        viewRoundedOTP.layer.cornerRadius = 10;
        viewRoundedOTP.clipsToBounds=YES;
        screenMode=1;
    }
    else{
        [btnVerifyAndRegister setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
        [btnVerifyAndRegister setUserInteractionEnabled:NO];
        [loadingView removeFromSuperview];
        txtOtpNumber.text=@"";
        screenMode=0;
    }
    
}


-(void)handlingResponseForRegistration{
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    riderArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getRider]];
    [MyUtils setUserDefault:@"riderMobileNo" value:[[riderArray objectAtIndex:0] rider_mobile]];
    [MyUtils setUserDefault:@"riderEmail" value:[[riderArray objectAtIndex:0] rider_email]];
    [MyUtils setUserDefault:@"riderID" value:[[riderArray objectAtIndex:0] rider_id]];
    
    AddCard *registerController;
    if (appDel.iSiPhone5) {
        registerController = [[AddCard alloc] initWithNibName:@"AddCard" bundle:nil];
    }
    else{
        registerController = [[AddCard alloc] initWithNibName:@"AddCardLow" bundle:nil];
    }
    registerController.AddCardMode = 0;
    registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:registerController animated:YES completion:nil];
}

-(void)noCarFound{
    BtnGetOTP.backgroundColor = UIColorFromRGB(0xC0392B);
    [BtnGetOTP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    BtnGetOTP.userInteractionEnabled=YES;
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [self validationAlert:[GlobalVariable getGlobalMessage]];
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
}

#pragma mark - TextField Delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    // Add the toolbar above the keyboard here
    currTextField = textField;
    [self animateTextField:textField up:YES];
    if (currTextField.tag == 2 || currTextField.tag == 3 || currTextField.tag == 4) {
        txtOtpMobileNo.text=@"";
        BtnGetOTP.backgroundColor = [UIColor lightGrayColor];
        [BtnGetOTP setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
        BtnGetOTP.userInteractionEnabled=NO;
    }
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [self animateTextField:textField up:NO];
    if (textField.tag == 1) {
        
    }
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    innerView.frame = CGRectOffset(innerView.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)textFieldDidChange :(UITextField *)textField{
    //NSLog( @"text changed: %@", theTextField.text);
    if (textField.tag == 1) {
        if ([textField.text length]==0) {
            BtnGetOTP.backgroundColor = [UIColor lightGrayColor];
            [BtnGetOTP setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
            BtnGetOTP.userInteractionEnabled=NO;
        }
        else{
            BtnGetOTP.backgroundColor = UIColorFromRGB(0xC0392B);
            [BtnGetOTP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            BtnGetOTP.userInteractionEnabled=YES;
        }
    }
    
    if ([txtEmailID.text length]!=0 && [txtMobileNo.text length]!=0 && [txtPassword.text length]!=0) {
        [BtnRegSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmit.png"] forState:UIControlStateNormal];
        [BtnRegSubmit setUserInteractionEnabled:YES];
    }
    else{
        [BtnRegSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
        [BtnRegSubmit setUserInteractionEnabled:NO];
    }
    
    if (textField.tag == 5) {
        if ([txtOtpNumber.text length]!=0) {
            [btnVerifyAndRegister setBackgroundImage:[UIImage imageNamed:@"imgSubmit.png"] forState:UIControlStateNormal];
            [btnVerifyAndRegister setUserInteractionEnabled:YES];
        }
        else{
            [btnVerifyAndRegister setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
            [btnVerifyAndRegister setUserInteractionEnabled:NO];
        }
    }
    
}
- (IBAction)closeOtpView:(UIButton *)sender{
    
    viewOtpVerification.frame = CGRectMake(0, 40, 320, 360);
    viewRegistration.frame = CGRectMake(20, -525, 280, 475);
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         
                         viewOtpVerification.frame = CGRectMake(0, 568, 320, 360);
                         viewRegistration.frame = CGRectMake(20, 40, 280, 475);
                         
                         
                     }
                     completion:^(BOOL finished){
                         [viewOtpVerification removeFromSuperview];
                         btnAlreadyRegistered.hidden=NO;
                         screenMode=0;
                     }];
    
}
// Delegate Method of TextField
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)LoginPage:(UIButton *)sender {
    LoginPage *loginController;
    if(appDel.iSiPhone5){
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPage" bundle:nil];
    }else{
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPageLow" bundle:nil];
    }
    loginController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:loginController animated:YES completion:nil];
}


@end
