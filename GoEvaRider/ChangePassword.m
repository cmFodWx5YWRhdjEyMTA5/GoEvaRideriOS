//
//  ChangePassword.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "ChangePassword.h"
#import "RestCallManager.h"
#import "MyUtils.h"
#import "UIView+Toast.h"
#import "GlobalVariable.h"

@interface ChangePassword ()

@end

@implementation ChangePassword

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}


- (IBAction)updatePassowrd:(UIButton *)sender{
    [self.view endEditing:YES];
    if([RestCallManager hasConnectivity]){
        if ([self validationForm]) {
            [self.view setUserInteractionEnabled:NO];
            loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Saving..."];
            [self.view addSubview:loadingView];
            btnSave.userInteractionEnabled=NO;
            [NSThread detachNewThreadSelector:@selector(requestToServerSubmitData) toTarget:self withObject:nil];
        }
        
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)validationForm{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    if ([self.userOldPassword.text isEqualToString:@""] || [[self.userOldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [currentWindow makeToast:@"Please provide old Password." duration:2 position:0];
        return NO;
    }
    else if ([self.userNewPassword.text isEqualToString:@""] || [[self.userNewPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [currentWindow makeToast:@"Please provide new Password." duration:2 position:0];
        return NO;
    }
    else if ([self.userNewPassword.text length]<6) {
        [currentWindow makeToast:@"Password should be atleast 6 characters." duration:2 position:0];
        return NO;
    }
    else if ([self.userRetypeNewPassword.text isEqualToString:@""] || [[self.userRetypeNewPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
        [currentWindow makeToast:@"Please confirm new password." duration:2 position:0];
        return NO;
    }
    else if(![self.userNewPassword.text isEqualToString: self.userRetypeNewPassword.text]){
        [currentWindow makeToast:@"Passwords do not match, please re-enter passwords correctly." duration:2 position:0];
        return NO;
    }
    return YES;
}

-(void)requestToServerSubmitData{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] changePassword:[MyUtils getUserDefault:@"riderID"] userType:[GlobalVariable getUserType] oldPassword:_userOldPassword.text newPassword:_userNewPassword.text];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(handlingResponseUpdate) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(void)handlingResponseUpdate{
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    btnSave.userInteractionEnabled=YES;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[GlobalVariable getGlobalMessage] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView commitAnimations];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated: YES completion: nil];
}

-(void)noCarFound{
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSave.userInteractionEnabled=YES;
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [self.view makeToast:[GlobalVariable getGlobalMessage] duration:2 position:0];
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
