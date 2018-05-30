//
//  RateUsDriver.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 1/9/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import "RateUsDriver.h"
#import "Dashboard.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "DataStore.h"
#import "RestCallManager.h"
#import "MyUtils.h"
#import <HCSStarRatingView/HCSStarRatingView.h>
#import "AsyncImageView.h"
#import "PaymentCardList.h"
#import "PayNow.h"
#import "DashboardCaller.h"

@interface RateUsDriver ()

@end

@implementation RateUsDriver

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewDriverImage.layer.cornerRadius = viewDriverImage.frame.size.width / 2;
    viewDriverImage.layer.borderWidth = 2.5f;
    viewDriverImage.layer.borderColor = [UIColor whiteColor].CGColor;
    viewDriverImage.clipsToBounds = YES;
    
    if ([_screenMode isEqualToString:@"0"]) {
        btnBack.hidden =YES;
        btnBack.userInteractionEnabled =NO;
        lblTitle.text = @"RATE US";
        btnClose.hidden =NO;
        btnClose.userInteractionEnabled =YES;
    }
    else{
        btnBack.hidden =NO;
        btnBack.userInteractionEnabled=YES;
        lblTitle.text = @"RATE US";
        btnClose.hidden =YES;
        btnClose.userInteractionEnabled =NO;
    }
    btnClose.layer.cornerRadius=10;
    imgDriverImage.contentMode = UIViewContentModeScaleAspectFill;
    imgDriverImage.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgDriverImage];
    imgDriverImage.image = [UIImage imageNamed:@"profile"];
    imgDriverImage.imageURL = [NSURL URLWithString:self.driverImage];
    
    lblDriverName.text = self.driverName;
    
    viewComments.layer.cornerRadius = 2;
    viewComments.layer.borderWidth = 1.0f;
    viewComments.layer.borderColor = [UIColor grayColor].CGColor;
    viewComments.clipsToBounds = YES;
    
    
    
    lbl = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0,comments.frame.size.width - 10.0, 34.0)];
    [lbl setText:@"Comments (optional)"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor lightGrayColor]];
    comments.delegate = self;
    [comments addSubview:lbl];
    
//    imgDriverImage.contentMode = UIViewContentModeScaleAspectFill;
//    imgDriverImage.clipsToBounds = YES;
//    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgDriverImage];
//    imgDriverImage.image = [UIImage imageNamed:@"profile"];
//    imgDriverImage.imageURL = [NSURL URLWithString:_driverImage];
//    lblDriverName.text = _driverName;
    btnRateUs.backgroundColor = [UIColor blackColor];
    btnRateUs.titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
    btnRateUs.layer.cornerRadius=10;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:TRUE];
    
}

#pragma mark - UITextView Delegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    //NSLog(@"jasim");
    [self animateTextView:textView up:YES];
}

- (void)textViewDidEndEditing:(UITextView *) textView
{
    [self animateTextView:textView up:NO];
    if (![textView hasText]) {
        lbl.hidden = NO;
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if(![textView hasText]) {
        lbl.hidden = NO;
    }
    else{
        lbl.hidden = YES;
    }  
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)animateTextView:(UITextView*)textView up:(BOOL)up
{
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextView" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}



- (IBAction)didChangeValue:(HCSStarRatingView *)sender {
    //NSLog(@"Changed rating to %.1f", sender.value);
    _ratting=[NSString stringWithFormat:@"%.1f",sender.value];
    if (sender.value==0) {
        btnRateUs.backgroundColor = [UIColor lightGrayColor];
        btnRateUs.titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
        [btnRateUs setUserInteractionEnabled:NO];
    }
    else{
        btnRateUs.backgroundColor = [UIColor blackColor];
        btnRateUs.titleLabel.textColor = [UIColor whiteColor];
        [btnRateUs setUserInteractionEnabled:YES];
    }
}


- (IBAction)rateUsDriver:(UIButton *)sender{
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        loadingView = [MyUtils customLoaderFullWindowWithText:self.window loadingText:@"SUBMITTING FEEDBACK..."];
        [currentWindow addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForRateUs) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerForRateUs{
    
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] rateUsDriver:_bookingID userType:@"1" ratingValue:_ratting comments:comments.text];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responseRateUs) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void)responseRateUs{
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    if ([_screenMode isEqualToString:@"0"]) {
        //[DashboardCaller homepageSelector:self];
        [self.presentingViewController.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.3];
//        [UIView commitAnimations];
//        [self dismissViewControllerAnimated:YES completion:nil];
        
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

-(void)responseFailed{
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"There was an issue connecting to the server. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [loginAlert show];
}


- (IBAction)backToPreviousPage:(UIButton *)sender{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goToHomePage:(UIButton *)sender {
    [self.view setUserInteractionEnabled:YES];
    //[DashboardCaller homepageSelector:self];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
