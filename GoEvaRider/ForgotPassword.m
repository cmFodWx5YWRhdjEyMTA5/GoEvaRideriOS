//
//  ForgotPassword.m
//  GoEvaRider
//
//  Created by Kalyan Paul on 19/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "ForgotPassword.h"
#import "DataStore.h"
#import "RestCallManager.h"
#import "MyUtils.h"
#import "GlobalVariable.h"
#import "LoginPage.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface ForgotPassword ()

@end

@implementation ForgotPassword

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewRoundedInnerOTP.layer.cornerRadius=15;
    viewRoundedInnerOTP.clipsToBounds=YES;
    
    btnVerifyOTP.backgroundColor = [UIColor lightGrayColor];
    [btnVerifyOTP setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
    btnVerifyOTP.layer.cornerRadius=5;
    btnVerifyOTP.clipsToBounds=YES;
    btnVerifyOTP.userInteractionEnabled=NO;
    
    /* Transaparent Background view */
    backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.5;
    /* End Transparent backgorund view*/
    
    [txtOTP addTarget:self
                    action:@selector(textFieldDidChange:)
                   forControlEvents:UIControlEventEditingChanged];
    [txtNewPassword addTarget:self
                    action:@selector(textFieldDidChange:)
          forControlEvents:UIControlEventEditingChanged];
    [txtConfirmPassword addTarget:self
                       action:@selector(textFieldDidChange:)
             forControlEvents:UIControlEventEditingChanged];
    
    //Dismiss keyboard when touch any place of view except control and keyboard
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    _resendOtpMode = 0;
}

-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
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
            
            btnVerifyOTP.backgroundColor = [UIColor lightGrayColor];
            [btnVerifyOTP setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
            btnVerifyOTP.layer.cornerRadius=5;
            btnVerifyOTP.clipsToBounds=YES;
            btnVerifyOTP.userInteractionEnabled=NO;
            
        }
        else{
            
            btnVerifyOTP.backgroundColor = UIColorFromRGB(0xC0392B);
            [btnVerifyOTP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btnVerifyOTP.layer.cornerRadius=5;
            btnVerifyOTP.clipsToBounds=YES;
            btnVerifyOTP.userInteractionEnabled=YES;
            
        }
    }
    
    if (textField.tag == 2 || textField.tag == 3) {
        if ([txtNewPassword.text length]!=0 && [txtConfirmPassword.text length]!=0) {
            [btnResetSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmit.png"] forState:UIControlStateNormal];
            [btnResetSubmit setUserInteractionEnabled:YES];
        }
        else{
            [btnResetSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
            [btnResetSubmit setUserInteractionEnabled:NO];
        }
    }
    
}

#pragma mark - TextField Delegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    // Add the toolbar above the keyboard here
    currTextField = textField;
    [self animateTextField:textField up:YES];
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [self animateTextField:textField up:NO];
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


-(void)requestToServerResendOTP{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] forgotPasswordStep1:self.emailIDOrMobile];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(showContactDialog) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(wrongData) withObject:nil waitUntilDone:YES];
    }
}

-(void)showContactDialog{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
//    [btnVerifyOTP setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
//    [btnVerifyOTP setUserInteractionEnabled:NO];
    [loadingView removeFromSuperview];
    txtOTP.text=@"";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Send!!!" message:@"OTP send successfully. Please check your registered mobile number or Email id." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.3];
//        [UIView commitAnimations];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated: YES completion: nil];
}

- (IBAction)verifyOTP:(UIButton *)sender{
    
    if([RestCallManager hasConnectivity]){
        
        [txtOTP resignFirstResponder];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Verifying..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForVerifyOTP) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerForVerifyOTP{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] forgotPasswordStep2:self.emailIDOrMobile otpValue:txtOTP.text];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(showContactDialog2) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(wrongData) withObject:nil waitUntilDone:YES];
    }
}


-(void)showContactDialog2{
    [self.view setUserInteractionEnabled:YES];
    if (_resendOtpMode==0) {
        [loadingView removeFromSuperview];
        [btnResetSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
        [btnResetSubmit setUserInteractionEnabled:NO];
        
        viewNewPassword.frame = CGRectMake(0, 568, 320, 315);
        viewOtpVerification.frame = CGRectMake(20, 80, 280, 315);
        [UIView animateWithDuration:0.5
                              delay:0.5
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             viewNewPassword.frame = CGRectMake(0, 80, 320, 360);
                             viewOtpVerification.frame = CGRectMake(20, -365, 280, 315);
                             
                         }
                         completion:^(BOOL finished){
                         }];
        [innerView addSubview:viewNewPassword];
        viewRoundedInnerNewPassword.layer.cornerRadius = 10;
        viewRoundedInnerNewPassword.clipsToBounds=YES;
    }
    else if(_resendOtpMode==1){
        [btnVerifyOTP setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
        [btnVerifyOTP setUserInteractionEnabled:NO];
        [loadingView removeFromSuperview];
        txtOTP.text=@"";
    }
    
}


- (IBAction)setNewPassword:(UIButton *)sender{
    if(![txtNewPassword.text isEqualToString: txtConfirmPassword.text]){
         [self validationAlert:@"Your password does not match. Please try again."];
    }
    else{
        if([RestCallManager hasConnectivity]){
            
            [txtNewPassword resignFirstResponder];
            [txtConfirmPassword resignFirstResponder];
            [btnResetSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmitDisable.png"] forState:UIControlStateNormal];
            [btnResetSubmit setUserInteractionEnabled:NO];
            [self.view setUserInteractionEnabled:NO];
            loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Updating..."];
            [self.view addSubview:loadingView];
            [NSThread detachNewThreadSelector:@selector(requestToServerSetNewPassword) toTarget:self withObject:nil];
        }
        else{
            UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [loginAlert show];
        }
    }
}

-(void)requestToServerSetNewPassword{
    
    BOOL bSuccess;
    
    bSuccess =  [[RestCallManager sharedInstance] forgotPasswordStep3:self.emailIDOrMobile newPassword:txtNewPassword.text];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(handlingResponseNewPassword) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(void)handlingResponseNewPassword{
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Done!!!" message:@"Password set successfully" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (_resetPassMode==0) {
            LoginPage *loginController;
            if (appDel.iSiPhone5) {
                loginController = [[LoginPage alloc] initWithNibName:@"LoginPage" bundle:nil];
            }
            else{
                loginController = [[LoginPage alloc] initWithNibName:@"LoginPageLow" bundle:nil];
            }
            [self presentViewController:loginController animated:YES completion:nil];
        }
        else{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView commitAnimations];
        [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated: YES completion: nil];
    
}

- (IBAction)resendOTP:(UIButton *)sender{
    if([RestCallManager hasConnectivity]){
        _resendOtpMode = 1;
        [self.view setUserInteractionEnabled:NO];
            loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Sending..."];
            [self.view addSubview:loadingView];
            [NSThread detachNewThreadSelector:@selector(requestToServerResendOTP) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}



-(void)noCarFound{
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [btnResetSubmit setBackgroundImage:[UIImage imageNamed:@"imgSubmit.png"] forState:UIControlStateNormal];
    [btnResetSubmit setUserInteractionEnabled:YES];
    [self validationAlert:[GlobalVariable getGlobalMessage]];
}

-(void)wrongData{
    
    btnVerifyOTP.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnVerifyOTP setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnVerifyOTP.layer.cornerRadius=5;
    btnVerifyOTP.clipsToBounds=YES;
    btnVerifyOTP.userInteractionEnabled=YES;
   
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

- (IBAction)closeAlert:(UIButton *)sender{
    
    [self.view setUserInteractionEnabled:YES];
    [alertViewWarning removeFromSuperview];
    [backgroundView removeFromSuperview];
}

- (IBAction)backToPage:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
