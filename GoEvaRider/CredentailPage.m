//
//  CredentailPage.m
//  GoEvaRider
//

#import "CredentailPage.h"
#import "LoginPage.h"
#import "RegistrationPage.h"
#import "MyUtils.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "Dashboard.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface CredentailPage ()

@end

@implementation CredentailPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [_locationManager requestWhenInUseAuthorization];
        
    } else {
        //Will update location immediately
    }
    
    //Calling this methods builds the intro and adds it to the screen. See below.
    
//    if ([MyUtils getUserDefault:@"riderMobileNo"]!=nil || [MyUtils getUserDefault:@"riderEmail"]!=nil) {
//        //[self homepageSelector];
//        [self performSelector:@selector(homepageSelector) withObject:self afterDelay:3.0 ];
//    }
//    else{
        //[self buildIntro];
    //}
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //NSLog(@"Location access Permit");
    }
    else if (status == kCLAuthorizationStatusDenied) {
        //NSLog(@"Location access denied");
    }
}


#pragma mark - Build MYBlurIntroductionView

-(void)buildIntro{
    //Create Stock Panel with header
    
    MYIntroductionPanel *panel1 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Lorem ipsum dolor sit amet" description:@"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat" image:[UIImage imageNamed:@"HeaderImage.png"]];
    
    //Create Stock Panel With Image
    MYIntroductionPanel *panel2 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Duis aute irure dolor in reprehenderit " description:@"in voluptate velit esse cillum dolore eu fugiat nulla pariatur. sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum!" image:[UIImage imageNamed:@"ForkImage.png"]];
    
    //Create Panel From Nib
    MYIntroductionPanel *panel3 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Ut enim ad minima veniam" description:@"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur!" image:[UIImage imageNamed:@"ForkImage.png"]];
    
    //Create Panel From Nib
    MYIntroductionPanel *panel4 = [[MYIntroductionPanel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) title:@"Lorem ipsum dolor sit amet" description:@"sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.!" image:[UIImage imageNamed:@"ForkImage.png"]];
    
    //Add panels to an array
    NSArray *panels = @[panel1, panel2, panel3, panel4];
    
    //Create the introduction view and set its delegate
    MYBlurIntroductionView *introductionView = [[MYBlurIntroductionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    introductionView.delegate = self;
    introductionView.BackgroundImageView.image = [UIImage imageNamed:@"background_img.png"];
    [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    //introductionView.LanguageDirection = MYLanguageDirectionRightToLeft;
    
    //Build the introduction with desired panels
    [introductionView buildIntroductionWithPanels:panels];
    
    //Add the introduction to your view
    [self.view addSubview:introductionView];
}

#pragma mark - MYIntroduction Delegate

-(void)introduction:(MYBlurIntroductionView *)introductionView didChangeToPanel:(MYIntroductionPanel *)panel withIndex:(NSInteger)panelIndex{
    //NSLog(@"Introduction did change to panel %ld", (long)panelIndex);
    
    //You can edit introduction view properties right from the delegate method!
    //If it is the first panel, change the color to green!
    if (panelIndex == 0) {
        [introductionView setBackgroundColor:[UIColor colorWithRed:90.0f/255.0f green:175.0f/255.0f blue:113.0f/255.0f alpha:0.65]];
    }
    //If it is the second panel, change the color to blue!
    else if (panelIndex == 1){
        [introductionView setBackgroundColor:[UIColor colorWithRed:50.0f/255.0f green:79.0f/255.0f blue:133.0f/255.0f alpha:0.65]];
    }
    //If it is the second panel, change the color to blue!
    else if (panelIndex == 2){
        [introductionView setBackgroundColor:[UIColor colorWithRed:70.0f/255.0f green:200.0f/255.0f blue:133.0f/255.0f alpha:0.65]];
    }
    //If it is the second panel, change the color to blue!
    else if (panelIndex == 3){
        [introductionView setBackgroundColor:[UIColor colorWithRed:150.0f/255.0f green:35.0f/255.0f blue:133.0f/255.0f alpha:0.65]];
    }
}

-(void)introduction:(MYBlurIntroductionView *)introductionView didFinishWithType:(MYFinishType)finishType {
    //NSLog(@"Introduction did finish");
}


- (IBAction)openSignInScreen:(UIButton *)sender {
    [MyUtils setUserDefault:@"loginMode" value:@"1"];
     LoginPage *loginController;
    if(appDel.iSiPhone5){
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPage" bundle:nil];
    }else{
        loginController = [[LoginPage alloc] initWithNibName:@"LoginPageLow" bundle:nil];
    }
     loginController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:loginController animated:YES completion:nil];
}

- (IBAction)openSignUpScreen:(id)sender {
    [MyUtils setUserDefault:@"loginMode" value:@"1"];
    RegistrationPage *registerController;
    if(appDel.iSiPhone5){
        registerController = [[RegistrationPage alloc] initWithNibName:@"RegistrationPage" bundle:nil];
    }else{
        registerController = [[RegistrationPage alloc] initWithNibName:@"RegistrationPageLow" bundle:nil];
    }
    registerController.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:registerController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
