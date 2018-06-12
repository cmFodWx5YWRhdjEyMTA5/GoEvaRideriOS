//
//  MyProfiles.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "MyProfiles.h"
#import "MFSideMenu.h"
#import "MyUtils.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "RiderMaster.h"
#import "GlobalVariable.h"
#import "ProfilePictureUpload.h"
#import "MyProfileUpdate.h"
#import "ChangePassword.h"
#import "AsyncImageView.h"
#import "UIView+Toast.h"
#import "LoginPage.h"
#import "ForgotPassword.h"


@interface MyProfiles ()

@end

@implementation MyProfiles

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [viewImgProfile setUserInteractionEnabled:YES];
    [viewFullName setUserInteractionEnabled:YES];
    [viewMobile setUserInteractionEnabled:YES];
    [viewEmail setUserInteractionEnabled:YES];
    [viewChangePassword setUserInteractionEnabled:YES];
    
    viewImgProfile.layer.cornerRadius = viewImgProfile.frame.size.width / 2;
    viewImgProfile.clipsToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(changeProfileImage)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(changeFullName)];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(changeMobile)];
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(changeEmail)];
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(changePassword)];
    [viewImgProfile addGestureRecognizer:tap];
    [viewFullName addGestureRecognizer:tap2];
    [viewMobile addGestureRecognizer:tap3];
    [viewEmail addGestureRecognizer:tap4];
    [viewChangePassword addGestureRecognizer:tap5];
    
    btnLogout.layer.cornerRadius=5;
    
    CGSize scrollViewSize = CGSizeMake(innerView.frame.size.width,innerView.frame.size.height);
    [self.backGroundScroll setContentSize:scrollViewSize];
    
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        [innerView setHidden:YES];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        loadingView = [MyUtils customLoader:self.window];
        [currentWindow addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerGetProfile) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = @"My Profile and Settings";
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.shadowOffset = CGSizeMake(0, 1);
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
    
    MyUtils *utils= [[MyUtils alloc] init];
    [utils setupMenuBarButtonItems:self tilteLable:@"My Profile and Settings"];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
}


-(void)requestToServerGetProfile{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getRiderDetails:[MyUtils getUserDefault:@"riderID"] userType:[GlobalVariable getUserType]];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responsefetchProfile) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responsefetchProfile{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    [innerView setHidden:NO];
    profileArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getRider]];
    
    lblRating.text = ([[[profileArray objectAtIndex:0] ratting] isEqualToString:@""] || [[profileArray objectAtIndex:0] ratting] == (id)[NSNull null])?@"0.0":[NSString stringWithFormat:@"%0.1f", [[[profileArray objectAtIndex:0] ratting] floatValue]];
    
    if ([[profileArray objectAtIndex:0] rider_name] == (id)[NSNull null])
        lblFullName.text =@"No Name";
    else
        lblFullName.text = [[profileArray objectAtIndex:0] rider_name];
    lblMobileNo.text = [[profileArray objectAtIndex:0] rider_mobile];
    if ([[profileArray objectAtIndex:0] rider_email]== (id)[NSNull null])
        lblEmailID.text = @"";
    else
        lblEmailID.text = [[profileArray objectAtIndex:0] rider_email];
    
    imgProfile.contentMode = UIViewContentModeScaleAspectFill;
    imgProfile.clipsToBounds = YES;
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgProfile];
    [AsyncImageLoader sharedLoader].cache = nil;
    //set placeholder image or cell won't update when image is loaded
    imgProfile.image = [UIImage imageNamed:@"profile"];
    //load the image
    imgProfile.imageURL = [NSURL URLWithString:[[profileArray objectAtIndex:0] profile_pic]];
    
}

-(void)responseFailed{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
}

-(void)changeProfileImage{
    
    ProfilePictureUpload *imageController;
    if (appDel.iSiPhone5) {
        imageController = [[ProfilePictureUpload alloc] initWithNibName:@"ProfilePictureUpload" bundle:nil];
    }
    else{
        imageController = [[ProfilePictureUpload alloc] initWithNibName:@"ProfilePictureUploadLow" bundle:nil];
    }
    imageController.delegate=self;
    imageController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:imageController animated:YES completion:nil];
}

-(void)changeFullName{
    MyProfileUpdate *profileController;
    if (appDel.iSiPhone5) {
        profileController = [[MyProfileUpdate alloc] initWithNibName:@"MyProfileUpdate" bundle:nil];
    }
    else{
        profileController = [[MyProfileUpdate alloc] initWithNibName:@"MyProfileUpdateLow" bundle:nil];
    }
    profileController.profileMode = 1; // 1-> Full Name, 2-> Mobile, 3-> Email
    profileController.content = lblFullName.text;
    profileController.delegate = self;
    profileController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:profileController animated:YES completion:nil];
}

-(void)changeMobile{
    MyProfileUpdate *profileController;
    if (appDel.iSiPhone5) {
        profileController = [[MyProfileUpdate alloc] initWithNibName:@"MyProfileUpdate" bundle:nil];
    }
    else{
        profileController = [[MyProfileUpdate alloc] initWithNibName:@"MyProfileUpdateLow" bundle:nil];
    }
    profileController.profileMode = 2; // 1-> Full Name, 2-> Mobile, 3-> Email
    profileController.content = lblMobileNo.text;
    profileController.delegate = self;
    profileController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:profileController animated:YES completion:nil];
}

-(void)changeEmail{
    MyProfileUpdate *profileController;
    if (appDel.iSiPhone5) {
        profileController = [[MyProfileUpdate alloc] initWithNibName:@"MyProfileUpdate" bundle:nil];
    }
    else{
        profileController = [[MyProfileUpdate alloc] initWithNibName:@"MyProfileUpdateLow" bundle:nil];
    }
    profileController.profileMode = 3; // 1-> Full Name, 2-> Mobile, 3-> Email
    profileController.content = lblEmailID.text;
    profileController.delegate = self;
    profileController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:profileController animated:YES completion:nil];
}

-(void)changePassword{
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

-(void)requestToServerForgetPasswordOTP{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] forgotPasswordStep1:[[profileArray objectAtIndex:0] rider_mobile]];
    
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
    if (appDel.iSiPhone5) {
        forgotController = [[ForgotPassword alloc] initWithNibName:@"ForgotPassword" bundle:nil];
    }
    else{
        forgotController = [[ForgotPassword alloc] initWithNibName:@"ForgotPasswordLow" bundle:nil];
    }
    forgotController.emailIDOrMobile = [[profileArray objectAtIndex:0] rider_mobile];
    forgotController.resetPassMode = 1;// Come from profile page
    forgotController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:forgotController animated:YES completion:nil];
}

-(void)errorInForgotOTP{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:@"Some problem during request. Please try again" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated: YES completion: nil];
    
}


-(void)sendDataTobackToDocumentPage:(UIImage *)profileImage;
{
    [AsyncImageLoader sharedLoader].cache = nil;
    [self.view makeToast:@"Profile succesfully updated." duration:2 position:0];
    imgProfile.image = profileImage;
}

-(void)sendDataTobackToDocumentPage2:(NSString *)fieldData documentMode:(NSInteger)documentMode;
{
    [self.view makeToast:@"Profile succesfully updated." duration:2 position:0];
    
    if (documentMode==1){
        [lblFullName setText:fieldData];
        [MyUtils setUserDefault:@"riderName" value:fieldData];
    }
    else if(documentMode==2){
        [lblMobileNo setText:fieldData];
        [MyUtils setUserDefault:@"riderMobileNo" value:fieldData];
    }
    else if(documentMode==3)
        [lblEmailID setText:fieldData];
        [MyUtils setUserDefault:@"riderEmail" value:fieldData];
}

- (IBAction)logout:(UIButton *)sender{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Want to Logout?" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"Logout" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Logout..."];
        [self.view addSubview:loadingView];
        [self performSelector:@selector(loginSelector) withObject:self afterDelay:3.0];
        
    }];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        
        }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated: YES completion: nil];
    
}

-(void) loginSelector{
    [loadingView removeFromSuperview];
    [MyUtils removeParticularObjectFromNSUserDefault:@"riderMobileNo"];
    [MyUtils removeParticularObjectFromNSUserDefault:@"riderEmail"];
    [MyUtils removeParticularObjectFromNSUserDefault:@"riderID"];
    [MyUtils removeParticularObjectFromNSUserDefault:@"riderName"];
    [MyUtils removeParticularObjectFromNSUserDefault:@"profileImage"];
    [MyUtils removeParticularObjectFromNSUserDefault:@"riderRating"];
    
    LoginPage *loginController;
    if (appDel.iSiPhone5) {
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPage" bundle:nil];
    }
    else{
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPageLow" bundle:nil];
    }
    loginController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
