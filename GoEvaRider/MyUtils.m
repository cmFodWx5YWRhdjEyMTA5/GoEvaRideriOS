//
//  MyUtils.m
//  EditFX
//
//  Created by Kalyan Mohan Paul on 10/14/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import "MyUtils.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@implementation MyUtils

MyUtils *instanceOfAnotherClass;
static UIViewController *mvc;
static NSString *titleLable;

-(id)init
{
    self = [super init];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return self;
}

+(UIView *) customLoader:(UIWindow *)mainWindow{
    
    UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake(100, 400, 80, 80)];
    loadingView.center = CGPointMake(mainWindow.frame.size.width / 2, mainWindow.frame.size.height / 2);
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:1.0];
    loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, 35);
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView addSubview:activityView];
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    lblLoading.text = @"Loading...";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [loadingView addSubview:lblLoading];
    
    return  loadingView;
}

+(UIView *) customLoaderWithText:(UIWindow *)mainWindow loadingText:(NSString *)loadingText{
    UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake(100, 400, 80, 80)];
    loadingView.center = CGPointMake(mainWindow.frame.size.width / 2, mainWindow.frame.size.height / 2);
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:1.0];
    loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, 35);
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView addSubview:activityView];
    
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
    if (loadingText.length==0) {
        lblLoading.text = @"Loading...";
    }
    else{
        lblLoading.text = loadingText;
    }
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [loadingView addSubview:lblLoading];
    
    return  loadingView;
}

+(UIView *) customLoaderFullWindowWithText:(UIWindow *)mainWindow loadingText:(NSString *)loadingText{
    UIView *loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainWindow.frame.size.width, mainWindow.frame.size.height)];
    loadingView.center = CGPointMake(mainWindow.frame.size.width / 2, mainWindow.frame.size.height / 2);
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.9];
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, loadingView.frame.size.height / 2.0-35);
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView addSubview:activityView];
    UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    lblLoading.center = CGPointMake(loadingView.frame.size.width / 2.0, loadingView.frame.size.height / 2.0);
    if (loadingText.length==0) {
        lblLoading.text = @"Loading...";
    }
    else{
        lblLoading.text = loadingText;
    }
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    [loadingView addSubview:lblLoading];
    
    return  loadingView;
}

// Set NSUserDefaults
+ (void) setUserDefault:(NSString *)key value:(NSString *)value{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:value forKey:key];
    [userDefaults synchronize];
}
// get NSUserDefaults
+ (NSString *) getUserDefault:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:key];
}
// Destroy all NSUserDefaults
+(void) removeAllNSUserDefaults{
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}
// remove a particular key
+(void) removeParticularObjectFromNSUserDefault:(NSString *)key{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

// Set Custom Object into NSUserDefault
+ (void)saveCustomObject:(LocationData *)object key:(NSString *)key {
    NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:object];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedObject forKey:key];
    [defaults synchronize];
    
}

// Get Custom Object into NSUserDefault
+ (LocationData *)loadCustomObjectWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *encodedObject = [defaults objectForKey:key];
    LocationData *object = [NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
    return object;
}


+(NSMutableArray *)sortArrayAlphabetically:(NSMutableArray *)contentArray key:(NSString *)key{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES selector:@selector(caseInsensitiveCompare:)];
    newArray=[NSMutableArray arrayWithArray:[contentArray sortedArrayUsingDescriptors:@[sort]]];
    return newArray;
}

- (void)setupMenuBarButtonItems:(UIViewController *)controller tilteLable:(NSString *)title{
    
    instanceOfAnotherClass=[MyUtils new];
    mvc=controller;
    userDefaults = [NSUserDefaults standardUserDefaults];
    titleLable = title;
    
    controller.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem1:controller];
    if(controller.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[controller.navigationController.viewControllers objectAtIndex:0] isEqual:controller]) {
        controller.navigationItem.leftBarButtonItem = [self backBarButtonItem:controller];
    }
    if(controller.navigationController.viewControllers.count>1) {
        controller.navigationItem.leftBarButtonItems = @[[self backBarButtonItem:controller],[self leftMenuBarButtonItem2:controller]];
    }
    else {
        controller.navigationItem.leftBarButtonItems = @[[self leftMenuBarButtonItem:controller],[self leftMenuBarButtonItem2:controller]];
    }
}


- (UIBarButtonItem *)leftMenuBarButtonItem:(UIViewController *)controller {
    
    UIImage* menuImage = [UIImage imageNamed:@"ic_drawer"];
    CGRect frameimg = CGRectMake(0, 0, menuImage.size.width*80/100, menuImage.size.height*80/100);
    UIButton *menuButton = [[UIButton alloc] initWithFrame:frameimg];
    [menuButton setBackgroundImage:menuImage forState:UIControlStateNormal];
    [menuButton addTarget:instanceOfAnotherClass action:@selector(leftSideMenuButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    [menuButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *leftButtonItem =[[UIBarButtonItem alloc] initWithCustomView:menuButton];
    return leftButtonItem;
    
}

- (UIBarButtonItem *)leftMenuBarButtonItem2:(UIViewController *)controller {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 30)];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica-Roman" size:17]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setText:titleLable];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    //[titleLabel sizeToFit];
    
    UIBarButtonItem *leftButtonItem =[[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    return leftButtonItem;
    
}

- (UIBarButtonItem *)rightMenuBarButtonItem1:(UIViewController *)controller {
    
    CGRect frameimg = CGRectMake(0, 0, 90, 30);
    UIButton *loginButton = [[UIButton alloc] initWithFrame:frameimg];
    [loginButton setTitle:@"Pick Car" forState:UIControlStateNormal];
    [loginButton setBackgroundColor:UIColorFromRGB(0x923831)];
    loginButton.titleLabel.font = [UIFont systemFontOfSize:15];
    loginButton.layer.cornerRadius=15;
    loginButton.clipsToBounds=YES;
    [loginButton addTarget:instanceOfAnotherClass action:@selector(rightSideMenuButtonPressed1:)
          forControlEvents:UIControlEventTouchUpInside];
    [loginButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *rightButtonitem2 =[[UIBarButtonItem alloc] initWithCustomView:loginButton];
    return rightButtonitem2;
    
}


- (UIBarButtonItem *)backBarButtonItem:(UIViewController *)controller {
    
    UIImage* backImage = [UIImage imageNamed:@"ic_back"];
    CGRect frameimg = CGRectMake(0, 0, backImage.size.width*80/100, backImage.size.height*80/100);
    //CGRect frameimg = CGRectMake(0, 0, backImage.size.width, backImage.size.height);
    UIButton *backButton = [[UIButton alloc] initWithFrame:frameimg];
    [backButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:instanceOfAnotherClass action:@selector(backButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
    [backButton setShowsTouchWhenHighlighted:YES];
    
    UIBarButtonItem *backButtonItem =[[UIBarButtonItem alloc] initWithCustomView:backButton];
    return backButtonItem;
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [mvc.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    [mvc.menuContainerViewController toggleLeftSideMenuCompletion:^{
        [self setupMenuBarButtonItems:mvc tilteLable:titleLable];
    }];
}

- (void)rightSideMenuButtonPressed1:(id)sender {
    PickCar *ptr1;
    if (appDel.iSiPhone5) {
        ptr1 = [[PickCar alloc] initWithNibName:@"PickCar" bundle:nil];
    }
    else{
        ptr1 = [[PickCar alloc] initWithNibName:@"PickCarLow" bundle:nil];
    }
    [mvc presentViewController:ptr1 animated:YES completion:nil];
    
}


+ (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


+ (UIImage *)image:(UIImage*)originalImage scaledToSize:(CGSize)size
{
    //avoid redundant drawing
    if (CGSizeEqualToSize(originalImage.size, size))
    {
        return originalImage;
    }
    
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //draw
    [originalImage drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)validateMobileNumber:(NSString*)number
{
    NSString *numberRegEx = @"[0-9]{10}";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    return[numberTest evaluateWithObject:number];
}


//Helper Functions.
+ (NSNumber*)calculateDistanceInMetersBetweenCoord:(CLLocationCoordinate2D)coord1 coord:(CLLocationCoordinate2D)coord2 {
    NSInteger nRadius = 6371; // Earth's radius in Kilometers
    double latDiff = (coord2.latitude - coord1.latitude) * (M_PI/180);
    double lonDiff = (coord2.longitude - coord1.longitude) * (M_PI/180);
    double lat1InRadians = coord1.latitude * (M_PI/180);
    double lat2InRadians = coord2.latitude * (M_PI/180);
    double nA = pow ( sin(latDiff/2), 2 ) + cos(lat1InRadians) * cos(lat2InRadians) * pow ( sin(lonDiff/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = nRadius * nC;
    // convert to meters
    return @(nD*1000);
    
}

@end
