//
//  SideMenuViewController.m
//  GeoCouponAlert
//
//  Created by Kalyan Mohan Paul on 9/19/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "SidebarRow.h"
#import "Dashboard.h"
#import "Payment.h"
#import "YourTrips.h"
#import "OffersController.h"
#import "MyProfiles.h"
#import "HelpScreen.h"
#import "LegalScreen.h"
#import <SafariServices/SafariServices.h>
#import "AsyncImageView.h"
#import "MyUtils.h"


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface SideMenuViewController ()

@end

@implementation SideMenuViewController{
    
    
    NSArray *withLoginText;
    NSArray *withLoginIcon;
   
}


- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    // Do any additional setup after loading the view from its nib.
}




- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    withLoginText = [NSArray arrayWithObjects:@"BOOK YOUR RIDE", @"PAYMENTS",@"YOUR TRIPS/ RIDES", @"MY PROFILE",@"HELP", @"LEGAL", nil];
        
    withLoginIcon = [NSArray arrayWithObjects:@"ic_home", @"ic_new_card",@"ic_suggest", @"ic_alerts", @"ic_password",@"ic_zip", @"ic_terms",nil];
    headerView.frame = CGRectMake(0, 0, 280, headerView.frame.size.height);
    couponTableView.tableHeaderView = headerView;
    [couponTableView reloadData];
    //NSLog(@"%f %f",couponTableView.contentSize.height,CGRectGetHeight(couponTableView.frame));
    couponTableView.scrollEnabled = (couponTableView.contentSize.height >= CGRectGetHeight(couponTableView.frame));
    couponTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    riderName.text = ([[MyUtils getUserDefault:@"riderName"] isEqualToString:@""] || [MyUtils getUserDefault:@"riderName"] == nil)?@"NO NAME":[MyUtils getUserDefault:@"riderName"];
    
    rider_rating.text = ([[MyUtils getUserDefault:@"riderRating"] isEqualToString:@""] || [MyUtils getUserDefault:@"riderRating"] == nil)?@"0.0":[NSString stringWithFormat:@"%0.1f", [[MyUtils getUserDefault:@"riderRating"] floatValue]];
    
    //For rounding Profile Image
    viewImg.layer.cornerRadius = viewImg.frame.size.width / 2;
    viewImg.clipsToBounds = YES;
    
    //NSLog(@"%@",[MyUtils getUserDefault:@"profileImage"]);
    profileImageView.contentMode = UIViewContentModeScaleAspectFill;
    profileImageView.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:profileImageView];
    profileImageView.image = [UIImage imageNamed:@"profile"];
    if ([MyUtils getUserDefault:@"profileImage"] == (id)[NSNull null]) {
    }
    else{
        profileImageView.imageURL = [NSURL URLWithString:[MyUtils getUserDefault:@"profileImage"]];
    }
    
    
//    AsyncImageView *asyncImageView;
//    asyncImageView = [[AsyncImageView alloc]initWithFrame:CGRectMake(0,0,60, 60)];
//    
//        NSURL *url=[NSURL URLWithString:@"https://s-media-cache-ak0.pinimg.com/736x/b3/2b/98/b32b988b42beab452b9f90686683737f--cool-mens-haircuts-mens-haircut-styles.jpg"];
//        //cancel loading previous image for cell
//        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:asyncImageView];
//        asyncImageView.contentMode = UIViewContentModeScaleAspectFill;
//        asyncImageView.clipsToBounds = YES;
//        asyncImageView.tag = 99;
//        asyncImageView.imageURL = url;
//        [profileImageView addSubview:asyncImageView];
//        [profileImageView setImage:[UIImage imageNamed:@"no_image.png"]];
   
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return withLoginText.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *simpleTableIdentifier = @"SidebarRow";
    SidebarRow *cell = (SidebarRow *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib;
        nib = [[NSBundle mainBundle] loadNibNamed:@"SidebarRow" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        //cell.menuName.font=[UIFont fontWithName:@"HelveticaNeue-Roman" size:14];
        cell.menuName.text = [withLoginText objectAtIndex:indexPath.row];
        //cell.menuImage.image = [UIImage imageNamed:[withLoginIcon objectAtIndex:indexPath.row]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
     return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Dashboard *dashboardController;
    Payment *paymentController;
    YourTrips *tripController;
    OffersController *offerController;
    MyProfiles *settingController;
    HelpScreen *helpController;
    LegalScreen *legalController;
    UINavigationController *navigationController;
    
            
            if (indexPath.row==0) {
                if (appDel.iSiPhone5) {
                    dashboardController = [[Dashboard alloc] initWithNibName:@"Dashboard" bundle:nil];
                }
                else{
                    dashboardController = [[Dashboard alloc] initWithNibName:@"DashboardLow" bundle:nil];
                }
                navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:dashboardController];
                NSArray *viewControlles =navigationController.viewControllers;
                
                for (id controller in viewControlles)
                {
                    // iterate through the array and check for your controller
                    if ([controller isKindOfClass:[dashboardController class]])
                    {
                        //do your stuff here
                    }
                    else{
                        navigationController.viewControllers = controllers;
                    }
                }
            }
            
//            else if (indexPath.row==1){
//               activationController = [[ActivationCodeScreen alloc] initWithNibName:@"ActivationCodeScreen" bundle:nil];
//                }
//                activationController.modalTransitionStyle=UIModalPresentationFormSheet;
//                [self presentViewController:activationController animated:YES completion:nil];
//                
//                
//            }
    
            else if (indexPath.row==1){
                if (appDel.iSiPhone5) {
                    paymentController = [[Payment alloc] initWithNibName:@"Payment" bundle:nil];
                }
                else{
                    paymentController = [[Payment alloc] initWithNibName:@"PaymentLow" bundle:nil];
                }
                paymentController.setDefaultCardMode=0;
                [self presentViewController:paymentController animated:YES completion:nil];
            }
    
            else if (indexPath.row==2){
                if (appDel.iSiPhone5) {
                    tripController = [[YourTrips alloc] initWithNibName:@"YourTrips" bundle:nil];
                }
                else{
                    tripController = [[YourTrips alloc] initWithNibName:@"YourTripsLow" bundle:nil];
                }
                navigationController = self.menuContainerViewController.centerViewController;
                [navigationController pushViewController:tripController animated:YES];
            }
            /* else if (indexPath.row==3){
                offerController = [[OffersController alloc] initWithNibName:@"OffersController" bundle:nil];
                navigationController = self.menuContainerViewController.centerViewController;
                [navigationController pushViewController:offerController animated:YES];
             }*/
    
            else if (indexPath.row==3){
                if (appDel.iSiPhone5) {
                    settingController = [[MyProfiles alloc] initWithNibName:@"MyProfiles" bundle:nil];
                }
                else{
                    settingController = [[MyProfiles alloc] initWithNibName:@"MyProfilesLow" bundle:nil];
                }
                
                 navigationController = self.menuContainerViewController.centerViewController;
                 [navigationController pushViewController:settingController animated:YES];
             }
            else if (indexPath.row==4){
                if (appDel.iSiPhone5) {
                    helpController = [[HelpScreen alloc] initWithNibName:@"HelpScreen" bundle:nil];
                }
                else{
                    helpController = [[HelpScreen alloc] initWithNibName:@"HelpScreenLow" bundle:nil];
                }
                navigationController = self.menuContainerViewController.centerViewController;
                [navigationController pushViewController:helpController animated:YES];
            }
            else if (indexPath.row==5){
                if (appDel.iSiPhone5) {
                    legalController = [[LegalScreen alloc] initWithNibName:@"LegalScreen" bundle:nil];
                }
                else{
                    legalController = [[LegalScreen alloc] initWithNibName:@"LegalScreenLow" bundle:nil];
                }
                legalController.pageModeForHelpAndLegalMenu = 1;
                legalController.helpMenuID=@"";
                navigationController = self.menuContainerViewController.centerViewController;
                [navigationController pushViewController:legalController animated:YES];
            }
    
            /* else if (indexPath.row==6) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.geocouponalerts.com/app-terms-and-conditions"]];
            }*/
    
            // else if (indexPath.row==7) {
              //  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.geocouponalerts.com/app-privacy-policy"]];
        
        /* SFSafariViewController *websiteToOpen = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://www.geocouponalerts.com/app-privacy-policy"] entersReaderIfAvailable:YES];
        //websiteToOpen.delegate = self;
        [self presentViewController:websiteToOpen animated:YES completion:nil];*/
        
            //}
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

-(IBAction)openGoEvaDriver:(id)sender{
//    NSString *iTunesLink = @"itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8";
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
