//
//  MyProfileUpdate.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "MyProfileUpdate.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "MyUtils.h"
#import "GlobalVariable.h"
#import "UIView+Toast.h"

@interface MyProfileUpdate ()

@end

@implementation MyProfileUpdate

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewForm.layer.cornerRadius = 5;
    otpView.layer.cornerRadius = 5;
    [txtContent setText:self.content];
    [txtContent becomeFirstResponder];
    if (_profileMode==1) {
        [lblTitle setText:@"Full Name"];
        [txtContent setPlaceholder:@"Enter Full Name"];
    }
    else if (_profileMode==2){
        [lblTitle setText:@"Mobile No"];
        [txtContent setPlaceholder:@"10 - digit Mobile No."];
        [txtContent setKeyboardType:UIKeyboardTypeNumberPad];
    }
    else if (_profileMode==3){
        [lblTitle setText:@"Email"];
        [txtContent setPlaceholder:@"name@example.com"];
        [txtContent setKeyboardType:UIKeyboardTypeEmailAddress];
    }
}

- (IBAction)saveForm:(UIButton *)sender{
    [txtContent resignFirstResponder];
    if([RestCallManager hasConnectivity]){
        if ([self validationForm]) {
            [self.view setUserInteractionEnabled:NO];
            loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Saving..."];
            [self.view addSubview:loadingView];
            [btnSave setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
            btnSave.userInteractionEnabled=NO;
            [NSThread detachNewThreadSelector:@selector(requestToServerSubmitData) toTarget:self withObject:nil];
        }
        
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(BOOL)validationForm{
    
    if ([txtContent.text isEqualToString:@""] || [[txtContent.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow makeToast:@"Please provide Data." duration:2 position:0];
        return NO;
    }
    else if(_profileMode==2) {
        if (![MyUtils validateMobileNumber:txtContent.text]){
            UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
            [currentWindow makeToast:@"Please enter a valid 10 digit mobile number." duration:2 position:0];
            return NO;
        }
        
    }
    else if(_profileMode==3){
        if (![MyUtils validateEmailWithString:txtContent.text]){
            UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
            [currentWindow makeToast:@"Please enter a valid email address" duration:2 position:0];
            return NO;
        }
    }
    
    return YES;
}

-(void)requestToServerSubmitData{
    
    BOOL bSuccess;
    RiderMaster *userObj = [self riderRegistration];
    NSString *jsonString = [userObj JSONRepresentation];
    bSuccess =  [[RestCallManager sharedInstance] submitprofileData:jsonString];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(handlingResponseUpdate) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(RiderMaster *) riderRegistration{
    
    RiderMaster *user_master =[[RiderMaster alloc] init];
    user_master.id =@"";
    user_master.rider_id=[MyUtils getUserDefault:@"riderID"];
    user_master.user_type=[GlobalVariable getUserType];
    if (_profileMode==1)
    user_master.rider_name=txtContent.text;
    else if (_profileMode==2)
    user_master.rider_mobile=txtContent.text;
    else if(_profileMode==3)
    user_master.rider_email=txtContent.text;
    user_master.profile_pic=@"";
    user_master.signup_date =@"";
    user_master.password=@"";
    user_master.login_through_otp =@"";
    user_master.device_id =@"";
    user_master.status=[NSString stringWithFormat:@"%ld",(long)_profileMode];
    user_master.ratting =@"";
    user_master.device_type = @"";
    user_master.device_token = @"";
    
    return user_master;
    
}

// Delegate Method of TextField
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

-(void)handlingResponseUpdate{
    [self.view setUserInteractionEnabled:YES];
    [delegate sendDataTobackToDocumentPage2:txtContent.text documentMode:_profileMode];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)noCarFound{
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSave.userInteractionEnabled=YES;
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [self.view makeToast:@"Update failed, please try again. " duration:2 position:0];
}

- (IBAction)backToProfile:(id)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
