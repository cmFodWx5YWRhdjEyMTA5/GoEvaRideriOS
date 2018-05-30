//
//  YourTrips.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "YourTrips.h"
#import "MFSideMenu.h"
#import "MyUtils.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "YourTripCell.h"
#import "TripDetailsPage.h"
#import "BookingDetailMaster.h"
#import "AsyncImageView.h"
@interface YourTrips ()

@end

@implementation YourTrips

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _tableViewTrip.separatorStyle=NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MyUtils *utils= [[MyUtils alloc] init];
    [utils setupMenuBarButtonItems:self tilteLable:@"Your Trips"];
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        loadingView = [MyUtils customLoaderWithText:currentWindow loadingText:@"Loading..."];
        [currentWindow addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForFetchTrip) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}


-(void)requestToServerForFetchTrip{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getTripList:[MyUtils getUserDefault:@"riderID"]];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responsefetchTrip) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responsefetchTrip{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    tripArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllBooking]];
    NSSortDescriptor * descriptor = [NSSortDescriptor sortDescriptorWithKey: @"id" ascending: NO
                                                                 comparator:
                                     ^NSComparisonResult(id obj1, id obj2)
                                     {
                                         return [obj1 compare: obj2 options: NSNumericSearch];
                                     }];
    tripArray = [NSMutableArray arrayWithArray:[tripArray sortedArrayUsingDescriptors:[NSArray arrayWithObject: descriptor]]];
    
    [_tableViewTrip reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tripArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"YourTripCell";
    
    YourTripCell *cell = (YourTripCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"YourTripCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    BookingDetailMaster *bookingObj = [tripArray objectAtIndex:indexPath.row];
    if ([[bookingObj car_category_id] isEqualToString:@"1"]) {
        cell.imgCarImage.image = [UIImage imageNamed:@"ic_car"];
    }
    else if ([[bookingObj car_category_id] isEqualToString:@"2"]) {
        cell.imgCarImage.image = [UIImage imageNamed:@"ic_car_pro"];
    }
    else if ([[bookingObj car_category_id] isEqualToString:@"3"]) {
        cell.imgCarImage.image = [UIImage imageNamed:@"ic_car_grp"];
    }
    cell.lblBookingDateTime.text = [bookingObj booking_datetime];
    cell.lblCarTypeBookingNo.text = [NSString stringWithFormat:@"%@. CEN %@",[bookingObj car_category_name], [bookingObj booking_id]];
    if ([[bookingObj booking_status] isEqualToString:@"1"]) {
        cell.lblFare.text = [NSString stringWithFormat:@"$%@",[bookingObj total_fare]];
        cell.imgCancel.hidden=YES;
    }
    else{
        cell.lblFare.text = @"$0.00";
        cell.imgCancel.hidden=NO;
    }
    cell.imgDriverImage.contentMode = UIViewContentModeScaleAspectFill;
    cell.imgDriverImage.clipsToBounds = YES;
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgDriverImage];
    //set placeholder image or cell won't update when image is loaded
    cell.imgDriverImage.image = [UIImage imageNamed:@"profile"];
    //load the image
    cell.imgDriverImage.imageURL = [NSURL URLWithString:[bookingObj driver_image]];
    
    cell.lblPickupLocation.text = ([bookingObj pickup_location] == (id)[NSNull null])?@"":[bookingObj pickup_location];
    cell.lblDropLocation.text = ([bookingObj drop_location] == (id)[NSNull null])?@"":[bookingObj drop_location];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookingDetailMaster *bookingObj = [tripArray objectAtIndex:indexPath.row];
    TripDetailsPage *registerController;
    if (appDel.iSiPhone5) {
        registerController = [[TripDetailsPage alloc] initWithNibName:@"TripDetailsPage" bundle:nil];
    }
    else{
        registerController = [[TripDetailsPage alloc] initWithNibName:@"TripDetailsPageLow" bundle:nil];
    }
    registerController.bookingID = [bookingObj booking_id];
    registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:registerController animated:YES completion:nil];
}


-(void) responseFailed{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Oops!!!"
                                                                  message:@"Some problem with the server. Please try again."
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* noButton = [UIAlertAction actionWithTitle:@"CANCEL"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action)
                               {
                                   //Cancel
                               }];
    
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"RELOAD"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    if([RestCallManager hasConnectivity]){
                                        [self.view setUserInteractionEnabled:NO];
                                        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
                                        loadingView = [MyUtils customLoaderFullWindowWithText:self.window loadingText:@"LOADING..."];
                                        [currentWindow addSubview:loadingView];
                                        [NSThread detachNewThreadSelector:@selector(requestToServerForFetchTrip) toTarget:self withObject:nil];
                                    }
                                    else{
                                        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                        [loginAlert show];
                                    }
                                    
                                }];
    
    [alert addAction:noButton];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
