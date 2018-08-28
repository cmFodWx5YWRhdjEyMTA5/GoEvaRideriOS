//
//  AfterBookingRestartApp.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 8/20/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import "AfterBookingRestartApp.h"
#import "CompleteRide.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "CarMaster.h"
#import "MyUtils.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "Dashboard.h"
#import "AsyncImageView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "CancelTrip.h"
#import "DashboardCaller.h"
#import "UIView+Toast.h"
#import "Constant.h"
#import <Stripe/Stripe.h>
#import "CardMaster.h"
#import <AFNetworking/AFNetworking.h>
#import "GlobalVariable.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface AfterBookingRestartApp ()

@end

@implementation AfterBookingRestartApp{
    GMSMapView *_mapView;
    GMSMarker *driverMarker;
    GMSMarker *pickerMarker;
    UIView *_londonView;
    NSTimer *timer;
    int j;
    AVAudioPlayer *player;
    NSArray *cardBrand;
    NSTimer *timerForArrival, *timerForStartTrip;
}

@synthesize notificationDriverDetailsDict;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    bookedDriver.layer.cornerRadius = bookedDriver.frame.size.width / 2;
    bookedDriver.layer.borderWidth = 2.5f;
    bookedDriver.layer.borderColor = [UIColor whiteColor].CGColor;
    bookedDriver.clipsToBounds = YES;
    
    bookedCarNumber.layer.cornerRadius = bookedCarNumber.frame.size.width / 2;
    bookedCarNumber.layer.borderWidth = 2.5f;
    bookedCarNumber.layer.borderColor = [UIColor whiteColor].CGColor;
    bookedCarNumber.clipsToBounds = YES;
    
    bookedCarType.layer.cornerRadius = bookedCarType.frame.size.width / 2;
    bookedCarType.layer.borderWidth = 2.5f;
    bookedCarType.layer.borderColor = [UIColor whiteColor].CGColor;
    bookedCarType.clipsToBounds = YES;
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(viewCard.frame.size.width / 2, viewCard.frame.size.height / 2);
    [self.view addSubview:activityIndicator];
    cardBrand = [NSArray arrayWithObjects:@"Visa", @"MasterCard",@"JCB", @"Diners Club", @"Discover",@"American Express", nil];
    [imgCard setHidden:YES];
    [lblCardNameWithLast4 setHidden:YES];
    
    
    _arrayPolylineGreen = [[NSMutableArray alloc] init];
    _path2 = [[GMSMutablePath alloc]init];
    
    // For Driver Arrive and Start Trip
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForDriverArrivalAndStartTrip:) name:@"pushNotificationForDriverArrivalAndStartTrip" object:nil];
    
    // For Cancel Trip By Driver
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForCancelTrip:) name:@"pushNotificationForCancelTrip" object:nil];
    
    // For Fare Summary after Complete Trip
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForTripComplete:) name:@"pushNotificationForTripComplete" object:nil];
    
    /* Transaparent Background view */
    backgroundView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.5;
    
    btnRefreshDriver.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnRefreshDriver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRefreshDriver setTitle:@"Refresh" forState:UIControlStateNormal];
    btnRefreshDriver.layer.cornerRadius=5;
    btnRefreshDriver.clipsToBounds=YES;
    btnRefreshDriver.userInteractionEnabled=YES;
    
    btnAddTips.layer.cornerRadius=5;
    btnAddTips.clipsToBounds=YES;
    btnAddTips.userInteractionEnabled=YES;
    
    btnAddTips.hidden = YES;
    lblTips.hidden = YES;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.50
                                                            longitude:-98.35
                                                                 zoom:4];
    _mapView = [GMSMapView mapWithFrame:_mapViewContainer.bounds camera:camera];
    _mapView.settings.compassButton = YES;
    //_mapView.settings.myLocationButton = YES;
    _mapView.padding = UIEdgeInsetsMake(80, 0, 20, 0);
    _mapView.delegate=self;
    [_mapViewContainer addSubview:_mapView];
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        _mapView.myLocationEnabled = YES;
    });
    [self setData];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    if ([[notificationDriverDetailsDict valueForKey:@"booking_status"] isEqualToString:@"0"]) {
        [self commonMethodForRefreshDriverLocationForArrival];
        // Timer for getting update location and arrival time of Driver
        timerForArrival = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                           target:self selector:@selector(refreshDriverArrivalTimer:) userInfo:nil repeats:YES];
    }
    else if ([[notificationDriverDetailsDict valueForKey:@"booking_status"] isEqualToString:@"2"]) {
        [self commonMethodForRefreshEstimatedTime];
        // Timer for getting update location and arrival time of Driver
        timerForStartTrip = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                             target:self selector:@selector(refreshDriverStartTripTimer:) userInfo:nil repeats:YES];
    }
}


-(void) setData{
    _bookingID = [notificationDriverDetailsDict valueForKey:@"booking_id"];
    lblDriverName.text = [notificationDriverDetailsDict valueForKey:@"driver_name"];
    lblPlateNo.text = [notificationDriverDetailsDict valueForKey:@"car_plate_no"];
    lblCarName.text = [notificationDriverDetailsDict valueForKey:@"car_name"];
    
    lblRating.text = ([[notificationDriverDetailsDict valueForKey:@"driver_ratting"] isEqualToString:@""] || [notificationDriverDetailsDict valueForKey:@"driver_ratting"] == nil)?@"0.0":[NSString stringWithFormat:@"%0.1f", [[notificationDriverDetailsDict valueForKey:@"driver_ratting"] floatValue]];
    
    imgProfile.contentMode = UIViewContentModeScaleAspectFill;
    imgProfile.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgProfile];
    imgProfile.image = [UIImage imageNamed:@"no_image.png"];
    imgProfile.imageURL = [NSURL URLWithString:[notificationDriverDetailsDict valueForKey:@"driver_profile_pic"]];
    
    imgPlateNo.contentMode = UIViewContentModeScaleAspectFill;
    imgPlateNo.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgPlateNo];
    imgPlateNo.image = [UIImage imageNamed:@"no_image.png"];
    imgPlateNo.imageURL = [NSURL URLWithString:[notificationDriverDetailsDict valueForKey:@"car_plate_no_pic"]];
    
    imgCar.contentMode = UIViewContentModeScaleAspectFill;
    imgCar.clipsToBounds = YES;
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgCar];
    imgCar.image = [UIImage imageNamed:@"no_image.png"];
    imgCar.imageURL = [NSURL URLWithString:[notificationDriverDetailsDict valueForKey:@"car_pic"]];
    
    
    
    pickupLocation = [MyUtils loadCustomObjectWithKey:@"pickupLocation"];
    dropLocation = [MyUtils loadCustomObjectWithKey:@"dropLocation"];
    
    if([[notificationDriverDetailsDict valueForKey:@"booking_status"] isEqualToString:@"0"]){//Fresh booking
        [viewOnTheWay setHidden:YES];
        NSDate *dateToFire = [[NSDate date] dateByAddingTimeInterval:[[notificationDriverDetailsDict valueForKey:@"total_duration_in_min"] integerValue]*60];
        //To get date in  `hour:minute` format.
        NSDateFormatter *dateFormatterHHMM=[NSDateFormatter new];
        [dateFormatterHHMM setDateFormat:@"hh:mm a"];
        NSString *timeString=[dateFormatterHHMM stringFromDate:dateToFire];
        [lblArrivalTime setText:[NSString stringWithFormat:@"Expected Time of Arrival %@", timeString]];
        lblAwayTime.text = [NSString stringWithFormat:@"%@ min away",[notificationDriverDetailsDict valueForKey:@"total_duration_in_min"]];
        [lblPickupAddress setText:[NSString stringWithFormat:@"%@",pickupLocation.locationAddress]];
        
        driverMarker = [[GMSMarker alloc] init];
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        driverMarker.iconView = _londonView;
        driverMarker.position = CLLocationCoordinate2DMake([[notificationDriverDetailsDict valueForKey:@"driver_current_lat"] floatValue],[[notificationDriverDetailsDict valueForKey:@"driver_current_long"] floatValue]);
        driverMarker.map = _mapView;
        [_mapView setSelectedMarker:driverMarker];
        
        
        pickerMarker = [[GMSMarker alloc] init];
        pickerMarker.title = @"My Pickup Location";
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        pickerMarker.iconView = _londonView;
        pickerMarker.position = CLLocationCoordinate2DMake([pickupLocation.latitude floatValue],[pickupLocation.longitude floatValue]);
        pickerMarker.map = _mapView;
        
        [self createPolyLine:[[notificationDriverDetailsDict valueForKey:@"driver_current_lat"] floatValue] pickupLong:[[notificationDriverDetailsDict valueForKey:@"driver_current_long"] floatValue] dropLat:[pickupLocation.latitude floatValue] dropLong:[pickupLocation.longitude floatValue] timeInterval:0.03];
    }
    else if([[notificationDriverDetailsDict valueForKey:@"booking_status"] isEqualToString:@"3"]){//Driver Arrived
        
        [viewOnTheWay setHidden:NO];
        [lblDriverRunningStatus setText:@"DRIVER ARRIVED"];
        
        [timerForArrival invalidate];
        timerForArrival = nil;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setFromValue:[NSNumber numberWithFloat:1.0]];
        [animation setToValue:[NSNumber numberWithFloat:0.0]];
        [animation setDuration:0.5f];
        [animation setTimingFunction:[CAMediaTimingFunction
                                      functionWithName:kCAMediaTimingFunctionLinear]];
        [animation setAutoreverses:YES];
        [animation setRepeatCount:20000];
        [[lblDriverRunningStatus layer] addAnimation:animation forKey:@"opacity"];
        
        [lblArrivalTime setText:@"Driver Arrived. Stay at pick up location."];
        
        lblAwayTime.text = [NSString stringWithFormat:@"%@ min away",[notificationDriverDetailsDict valueForKey:@"total_duration_in_min"]];
        [lblPickupAddress setText:[NSString stringWithFormat:@"%@",pickupLocation.locationAddress]];
        
        driverMarker = [[GMSMarker alloc] init];
        pickerMarker.title = @"Driver is here";
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        driverMarker.iconView = _londonView;
        driverMarker.position = CLLocationCoordinate2DMake([[notificationDriverDetailsDict valueForKey:@"driver_current_lat"] floatValue],[[notificationDriverDetailsDict valueForKey:@"driver_current_long"] floatValue]);
        driverMarker.map = _mapView;
        [_mapView setSelectedMarker:driverMarker];
        
        
        pickerMarker = [[GMSMarker alloc] init];
        pickerMarker.title = @"My Pickup Location";
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        pickerMarker.iconView = _londonView;
        pickerMarker.position = CLLocationCoordinate2DMake([pickupLocation.latitude floatValue],[pickupLocation.longitude floatValue]);
        pickerMarker.map = _mapView;
        
        [self createPolyLine:[[notificationDriverDetailsDict valueForKey:@"driver_current_lat"] floatValue] pickupLong:[[notificationDriverDetailsDict valueForKey:@"driver_current_long"] floatValue] dropLat:[pickupLocation.latitude floatValue] dropLong:[pickupLocation.longitude floatValue] timeInterval:0.03];
    }
    else if([[notificationDriverDetailsDict valueForKey:@"booking_status"] isEqualToString:@"2"]){
        [viewOnTheWay setHidden:NO];
        [lblDriverRunningStatus setText:@"ON THE WAY"];
        
        btnAddTips.hidden = NO;
        lblTips.hidden = NO;
        if([[notificationDriverDetailsDict valueForKey:@"tips_amount"] doubleValue]>0){
            [btnAddTips setTitle:@"Remove Tip" forState:UIControlStateNormal];
            [btnAddTips setTag:2];
            [lblTips setText:[NSString stringWithFormat:@"You have added $%@ for tip",[notificationDriverDetailsDict valueForKey:@"tips_amount"]]];
        }
        else{
            [btnAddTips setTitle:@"Add Tip" forState:UIControlStateNormal];
            [btnAddTips setTag:1];
            lblTips.text = @"Do you want to add Tips?";
        }
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setFromValue:[NSNumber numberWithFloat:1.0]];
        [animation setToValue:[NSNumber numberWithFloat:0.0]];
        [animation setDuration:0.5f];
        [animation setTimingFunction:[CAMediaTimingFunction
                                      functionWithName:kCAMediaTimingFunctionLinear]];
        [animation setAutoreverses:YES];
        [animation setRepeatCount:20000];
        [[lblDriverRunningStatus layer] addAnimation:animation forKey:@"opacity"];
        
        [lblPickupAddress setText:dropLocation.locationAddress];
        
        [btnContactDriver setHidden:YES];
        [btnCancelBook setHidden:YES];
        
        NSDate *dateToFire = [[NSDate date] dateByAddingTimeInterval:[[notificationDriverDetailsDict valueForKey:@"total_duration_in_min"] integerValue]*60];
        //To get date in  `hour:minute` format.
        NSDateFormatter *dateFormatterHHMM=[NSDateFormatter new];
        [dateFormatterHHMM setDateFormat:@"hh:mm a"];
        NSString *timeString=[dateFormatterHHMM stringFromDate:dateToFire];
        [lblArrivalTime setText:[NSString stringWithFormat:@"Expected Time of Arrival %@", timeString]];
        [_mapView clear];
        
        
        lblAwayTime.text = [NSString stringWithFormat:@"%@ min away",[notificationDriverDetailsDict valueForKey:@"total_duration_in_min"]];
        driverMarker = [[GMSMarker alloc] init];
        pickerMarker.title = @"My Location";
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        driverMarker.iconView = _londonView;
        driverMarker.position = CLLocationCoordinate2DMake([pickupLocation.latitude floatValue],[pickupLocation.longitude floatValue]);
        driverMarker.map = _mapView;
        [_mapView setSelectedMarker:driverMarker];
        
        pickerMarker = [[GMSMarker alloc] init];
        pickerMarker.title = @"Drop Location";
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        pickerMarker.iconView = _londonView;
        pickerMarker.position = CLLocationCoordinate2DMake([dropLocation.latitude floatValue],[dropLocation.longitude floatValue]);
        pickerMarker.map = _mapView;
        
        [self createPolyLine:[pickupLocation.latitude floatValue] pickupLong:[pickupLocation.longitude floatValue] dropLat:[dropLocation.latitude floatValue] dropLong:[dropLocation.longitude floatValue] timeInterval:0.03];
        
        
    }
    /*
     //code for my location on map
     
     */
    
    //Get Card Details
    [self setCardData];
    
}


-(void)createPolyLine:(float)pickupLat pickupLong:(float)pickupLong dropLat:(float)dropLat dropLong:(float)dropLong timeInterval:(float)timeInterval{
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           pickupLat,
                           pickupLong,
                           dropLat,
                           dropLong,
                           @"AIzaSyAoXqu16phq9wtepWIuO1RpJierSCX88yg"];
    NSURL *directionsURL = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:directionsURL];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        
        @try {
            NSString *response = [request responseString];
            //NSLog(@"%@",response);
            NSDictionary *json =[NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingMutableContainers error:&error];
            GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
            GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
            
            singleLine.strokeWidth = 3;
            singleLine.strokeColor = [UIColor blackColor];
            singleLine.map = _mapView;
            
            GMSCoordinateBounds* bounds =  [[GMSCoordinateBounds alloc] init];
            
            for (int i=0; i<path.count; i++) {
                //NSLog(@"%f, %f",[path coordinateAtIndex:i].latitude,[path coordinateAtIndex:i].longitude);
                bounds = [bounds includingCoordinate:[path coordinateAtIndex:i]];
            }
            [_mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
            
            // animate green path with timer
            /*timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval repeats:true block:^(NSTimer * _Nonnull timer) {
             [self animate:path];
             }];*/
            
        }
        @catch (NSException * e) {
            //NSLog(@"Exception: %@", e);
            /* UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"There is no any routes available. Please choose another drop location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [loginAlert show];*/
        }
    }
    else {
        //NSLog(@"%@",[request error]);
    }
}

-(void)animate:(GMSPath *)path {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (j < path.count) {
            [_path2 addCoordinate:[path coordinateAtIndex:j]];
            _polylineGreen = [GMSPolyline polylineWithPath:_path2];
            _polylineGreen.strokeColor = [UIColor redColor];
            _polylineGreen.strokeWidth = 3;
            _polylineGreen.map = _mapView;
            [_arrayPolylineGreen addObject:_polylineGreen];
            j++;
        }
        else {
            j = 0;
            _path2 = [[GMSMutablePath alloc] init];
            
            for (GMSPolyline *line in _arrayPolylineGreen) {
                line.map = nil;
            }
            
        }
    });
}



//- (void)dealloc {
//    [_mapView removeObserver:self
//                  forKeyPath:@"myLocation"
//                     context:NULL];
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    //NSLog(@"Jasim %f, %f",location.coordinate.latitude,location.coordinate.longitude);
    _userCurrentLat = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    _userCurrentLong = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
}

- (void) pushNotificationForDriverArrivalAndStartTrip:(NSNotification *)notification{
    
    NSDictionary *dict = [notification userInfo];
    NSDictionary *notificationDict= [dict valueForKey:@"aps"];
    NSInteger notification_mode = [[NSString stringWithFormat:@"%@", [notificationDict valueForKey:@"notification_mode"]] integerValue];
    [self.view setUserInteractionEnabled:YES];
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:backgroundView];
    viewNotification.frame = CGRectMake(0, -117, 320, 117);
    [UIView animateWithDuration:0.3
                          delay:0.2
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         viewNotification.frame = CGRectMake(0, 20, 320, 117);
                     }
                     completion:^(BOOL finished){
                         
                         [self performSelector:@selector(dismissNotificationView) withObject:self afterDelay:3.0 ];
                         
                     }];
    [currentWindow addSubview:viewNotification];
    viewInnerNotification.layer.cornerRadius = 10;
    viewInnerNotification.clipsToBounds = YES;
    viewImgDriverNotification.layer.cornerRadius = viewImgDriverNotification.frame.size.width / 2;
    viewImgDriverNotification.layer.borderWidth = 2.0f;
    viewImgDriverNotification.layer.borderColor = [UIColor whiteColor].CGColor;
    viewImgDriverNotification.clipsToBounds = YES;
    AsyncImageView *asyncImageView;
    asyncImageView = [[AsyncImageView alloc]initWithFrame:CGRectMake(0,0,55, 55)];
    NSURL *url=[NSURL URLWithString:[notificationDriverDetailsDict valueForKey:@"driver_profile_pic"]];
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:asyncImageView];
    asyncImageView.contentMode = UIViewContentModeScaleAspectFill;
    asyncImageView.clipsToBounds = YES;
    asyncImageView.tag = 99;
    asyncImageView.imageURL = url;
    [imgProfileNotification addSubview:asyncImageView];
    [imgProfileNotification setImage:[UIImage imageNamed:@"no_image.png"]];
    [lblDriverNameNotification setText:[notificationDriverDetailsDict valueForKey:@"driver_name"]];
    [lblCarNameAndNumberNotification setText:[NSString stringWithFormat:@"%@ - %@",[notificationDriverDetailsDict valueForKey:@"car_name"],[notificationDriverDetailsDict valueForKey:@"car_plate_no"]]];
    lblRatingANotification.text = ([[notificationDriverDetailsDict valueForKey:@"driver_ratting"] isEqualToString:@""] || [notificationDriverDetailsDict valueForKey:@"driver_ratting"] == nil)?@"0.0":[NSString stringWithFormat:@"%0.1f", [[notificationDriverDetailsDict valueForKey:@"driver_ratting"] floatValue]];
    
    if (notification_mode == 3) {
        
        [timerForArrival invalidate];
        timerForArrival = nil;
        
        [lblStatusNotification setText:[notificationDict valueForKey:@"alert"]];
        [viewOnTheWay setHidden:NO];
        [lblDriverRunningStatus setText:@"DRIVER ARRIVED"];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setFromValue:[NSNumber numberWithFloat:1.0]];
        [animation setToValue:[NSNumber numberWithFloat:0.0]];
        [animation setDuration:0.5f];
        [animation setTimingFunction:[CAMediaTimingFunction
                                      functionWithName:kCAMediaTimingFunctionLinear]];
        [animation setAutoreverses:YES];
        [animation setRepeatCount:20000];
        [[lblDriverRunningStatus layer] addAnimation:animation forKey:@"opacity"];
        
        [lblArrivalTime setText:@"Driver Arrived. Stay at pick up location."];
        
    }
    else if(notification_mode == 4){
        
        timerForStartTrip = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                             target:self selector:@selector(refreshDriverStartTripTimer:) userInfo:nil repeats:YES];
        
        [lblStatusNotification setText:[notificationDict valueForKey:@"alert"]];
        [viewOnTheWay setHidden:NO];
        [lblDriverRunningStatus setText:@"ON THE WAY"];
        
        btnAddTips.hidden = NO;
        lblTips.hidden = NO;
        lblTips.text = @"Do you want to add Tips?";
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        [animation setFromValue:[NSNumber numberWithFloat:1.0]];
        [animation setToValue:[NSNumber numberWithFloat:0.0]];
        [animation setDuration:0.5f];
        [animation setTimingFunction:[CAMediaTimingFunction
                                      functionWithName:kCAMediaTimingFunctionLinear]];
        [animation setAutoreverses:YES];
        [animation setRepeatCount:20000];
        [[lblDriverRunningStatus layer] addAnimation:animation forKey:@"opacity"];
        
        [lblPickupAddress setText:dropLocation.locationAddress];
        
        [btnContactDriver setHidden:YES];
        [btnCancelBook setHidden:YES];
        
        NSDate *dateToFire = [[NSDate date] dateByAddingTimeInterval:[[notificationDict valueForKey:@"total_duration_in_min"] integerValue]*60];
        //To get date in  `hour:minute` format.
        NSDateFormatter *dateFormatterHHMM=[NSDateFormatter new];
        [dateFormatterHHMM setDateFormat:@"hh:mm a"];
        NSString *timeString=[dateFormatterHHMM stringFromDate:dateToFire];
        [lblArrivalTime setText:[NSString stringWithFormat:@"Expected Time of Arrival %@", timeString]];
        [_mapView clear];
        
        
        lblAwayTime.text = [NSString stringWithFormat:@"%@ min away",[notificationDict valueForKey:@"total_duration_in_min"]];
        
        driverMarker = [[GMSMarker alloc] init];
        driverMarker.title = @"My current location";
        //driverMarker.snippet = [NSString stringWithFormat:@"%@ MINS AWAY",[notificationDict valueForKey:@"total_duration_in_min"]];

        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        driverMarker.iconView = _londonView;
        driverMarker.position = CLLocationCoordinate2DMake([_userCurrentLat floatValue],[_userCurrentLong floatValue]);
        //    pickupMarker.appearAnimation = kGMSMarkerAnimationPop;
        //    pickupMarker.flat = YES;
        //    pickupMarker.groundAnchor = CGPointMake(0.5, 0.5);
        driverMarker.map = _mapView;
        [_mapView setSelectedMarker:driverMarker];
        
        
        pickerMarker = [[GMSMarker alloc] init];
        pickerMarker.title = @"Drop Location";
        pickerMarker.snippet = dropLocation.locationAddress;
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        pickerMarker.iconView = _londonView;
        pickerMarker.position = CLLocationCoordinate2DMake([dropLocation.latitude floatValue],[dropLocation.longitude floatValue]);
        //    dropMarker.appearAnimation = kGMSMarkerAnimationPop;
        //    dropMarker.flat = YES;
        //    dropMarker.groundAnchor = CGPointMake(0.5, 0.5);
        pickerMarker.map = _mapView;
        
        
        [self createPolyLine:[_userCurrentLat floatValue] pickupLong:[_userCurrentLong floatValue] dropLat:[dropLocation.latitude floatValue] dropLong:[dropLocation.longitude floatValue] timeInterval:0.003];
    }
}

- (void) pushNotificationForCancelTrip:(NSNotification *)notification{
    [self.view setUserInteractionEnabled:YES];
    /* Start*/
    /* Invalidate All Timer after cancel trip */
    [timerForArrival invalidate];
    timerForArrival = nil;
    [timerForStartTrip invalidate];
    timerForStartTrip = nil;
    /*End*/
    NSDictionary *dict = [notification userInfo];
    NSDictionary *notificationDict= [dict valueForKey:@"aps"];
    NSInteger notification_mode = [[NSString stringWithFormat:@"%@", [notificationDict valueForKey:@"notification_mode"]] integerValue];
    
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Driver cancelled the Trip"
                                                                 message:@""
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    [MyUtils removeParticularObjectFromNSUserDefault:@"pickupLocation"];
                                    [MyUtils removeParticularObjectFromNSUserDefault:@"dropLocation"];
                                    [MyUtils removeParticularObjectFromNSUserDefault:@"bookingID"];
                                    //[DashboardCaller homepageSelector:self];
                                    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                    
                                }];
    
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void) pushNotificationForTripComplete:(NSNotification *)notification{
    
    /* Start*/
    /* Invalidate All Timer after trip complete */
    [timerForArrival invalidate];
    timerForArrival = nil;
    [timerForStartTrip invalidate];
    timerForStartTrip = nil;
    /*End*/
    [self.view setUserInteractionEnabled:YES];
    
    [MyUtils removeParticularObjectFromNSUserDefault:@"bookingID"];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Trip Completed!!!" message:@"Trip successfully completed. Press OK button to view fare summary." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        NSDictionary *dict = [notification userInfo];
        NSDictionary *notificationDict= [dict valueForKey:@"aps"];
        BookingDetailMaster *bookingObj = [[BookingDetailMaster alloc] initWithJsonData:notificationDict];
        
        [self.view setUserInteractionEnabled:YES];
        [loadingView setHidden:YES];
        CompleteRide *registerController;
        if (appDel.iSiPhone5) {
            registerController = [[CompleteRide alloc] initWithNibName:@"CompleteRide" bundle:nil];
        }
        else{
            registerController = [[CompleteRide alloc] initWithNibName:@"CompleteRideLow" bundle:nil];
        }
        registerController.bookingObj = bookingObj;
        registerController.isRestartApp = YES;
        registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:registerController animated:YES completion:nil];
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}


-(void)dismissNotificationView{
    viewNotification.frame = CGRectMake(0, 20, 320, 117);
    
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         viewNotification.frame = CGRectMake(0, -117, 320, 117);
                     }
                     completion:^(BOOL finished){
                         [viewNotification removeFromSuperview];
                         [backgroundView removeFromSuperview];
                         
                     }];
}

- (IBAction)contactDriver:(UIButton *)sender{
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:backgroundView];
    //    viewContact.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    //    [currentWindow addSubview:viewContact];
    
    
    viewContact.frame = CGRectMake(20, 568, 280, 143);
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         viewContact.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
                     }
                     completion:^(BOOL finished){
                     }];
    [currentWindow addSubview:viewContact];
    
    [viewLblName setText:[notificationDriverDetailsDict valueForKey:@"driver_name"]];
    [viewLblMobile setText:[notificationDriverDetailsDict valueForKey:@"driver_contact_no"]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(messageDriver)];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(callDriver)];
    [btnCall setUserInteractionEnabled:YES];
    [btnMessage setUserInteractionEnabled:YES];
    [btnMessage addGestureRecognizer:tap];
    [btnCall addGestureRecognizer:tap2];
}

- (void)callDriver{
    [viewContact removeFromSuperview];
    [backgroundView removeFromSuperview];
    NSString *mobileNo = [notificationDriverDetailsDict valueForKey:@"driver_contact_no"];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",mobileNo]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

- (void)messageDriver{
    [viewContact removeFromSuperview];
    [backgroundView removeFromSuperview];
    NSString *mobileNo = [notificationDriverDetailsDict valueForKey:@"driver_contact_no"];
    NSURL *messageUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"sms:%@",mobileNo]];
    if ([[UIApplication sharedApplication] canOpenURL:messageUrl]) {
        [[UIApplication sharedApplication] openURL:messageUrl];
    } else
    {
        UIAlertView *messalert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"Message facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [messalert show];
    }
}

- (IBAction)closeContactPopup:(UIButton *)sender{
    
    viewContact.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         viewContact.frame = CGRectMake(20, 568, 280, 143);
                     }
                     completion:^(BOOL finished){
                         [viewContact removeFromSuperview];
                         [backgroundView removeFromSuperview];
                     }];
    
    
    
}
- (void)cancelBooking:(UIButton *)sender{
    NSDate *myDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"rideTimer"];
    NSDate *currentDate = [[NSDate alloc] init];
    if (myDate!=nil) {
        NSLog(@"%f",fabs([currentDate timeIntervalSinceDate:myDate]));
        int minimum_duration = [[MyUtils getUserDefault:@"min_duration_for_cancellation_charge"] intValue];//
        if (fabs([currentDate timeIntervalSinceDate:myDate]) > 60*minimum_duration)
            self.isCancellationCharge=YES;
        else
            self.isCancellationCharge=NO;
    }
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        loadingView = [MyUtils customLoaderFullWindowWithText:self.window loadingText:@"REQUESTING..."];
        [currentWindow addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForFetchReason) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerForFetchReason{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] fetchCancelReason:@"1"];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responsefetchCancelReason) withObject:nil waitUntilDone:YES];
    }
    else{
        [self performSelectorOnMainThread:@selector(responseFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responsefetchCancelReason{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    /* Start*/
    /* Invalidate All Timer after new cancel view controller called  */
    [timerForArrival invalidate];
    timerForArrival = nil;
    [timerForStartTrip invalidate];
    timerForStartTrip = nil;
    /*End*/
    CancelTrip *cancelTripController;
    if (appDel.iSiPhone5) {
        cancelTripController = [[CancelTrip alloc] initWithNibName:@"CancelTrip" bundle:nil];
    }
    else{
        cancelTripController = [[CancelTrip alloc] initWithNibName:@"CancelTripLow" bundle:nil];
    }
    cancelTripController.bookingID = _bookingID;
    cancelTripController.userCurrentLat = _userCurrentLat;
    cancelTripController.userCurrentLong = _userCurrentLong;
    cancelTripController.isCancellationCharge=self.isCancellationCharge;
    cancelTripController.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    [self presentViewController:cancelTripController animated:YES completion:nil];
}


-(void)responseFailed{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
}

- (void)refreshDriverStartTripTimer:(NSTimer *)myTimer{
    [self commonMethodForRefreshEstimatedTime];
}

- (void)refreshDriverArrivalTimer:(NSTimer *)myTimer{
    [self commonMethodForRefreshDriverLocationForArrival];
}

- (IBAction)refreshDriverLocation:(UIButton *)sender{
    if ([[notificationDriverDetailsDict valueForKey:@"booking_status"] isEqualToString:@"0"]) {
        [self commonMethodForRefreshDriverLocationForArrival];
    }
    else if([[notificationDriverDetailsDict valueForKey:@"booking_status"] isEqualToString:@"2"]){
        [self commonMethodForRefreshEstimatedTime];
    }
}

-(void)commonMethodForRefreshDriverLocationForArrival{
    if([RestCallManager hasConnectivity]){
        btnRefreshDriver.backgroundColor = [UIColor lightGrayColor];
        [btnRefreshDriver setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
        [btnRefreshDriver setTitle:@"Refreshing..." forState:UIControlStateNormal];
        btnRefreshDriver.layer.cornerRadius=5;
        btnRefreshDriver.clipsToBounds=YES;
        btnRefreshDriver.userInteractionEnabled=NO;
        [self.view setUserInteractionEnabled:NO];
        [NSThread detachNewThreadSelector:@selector(requestToServerForFetchDriverLocation) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerForFetchDriverLocation{
    NSString *bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getDriverLocationForArriving:[notificationDriverDetailsDict valueForKey:@"driver_id"] bookingID:_bookingID];
    if([bSuccess isEqualToString:@"0"])
    {
        [self performSelectorOnMainThread:@selector(responseGetDriverLocation) withObject:nil waitUntilDone:YES];
    }
    else if([bSuccess isEqualToString:@"3"]){ // In case where Driver already Arrived but not recieve APNS
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view setUserInteractionEnabled:YES];
            /* Invalidate All Timer after cancel trip */
            [timerForArrival invalidate];
            timerForArrival = nil;
            /*End*/
            btnRefreshDriver.backgroundColor = UIColorFromRGB(0xC0392B);
            [btnRefreshDriver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnRefreshDriver setTitle:@"Refresh" forState:UIControlStateNormal];
            btnRefreshDriver.layer.cornerRadius=5;
            btnRefreshDriver.clipsToBounds=YES;
            btnRefreshDriver.userInteractionEnabled=YES;
            
            [viewOnTheWay setHidden:NO];
            [lblDriverRunningStatus setText:@"DRIVER ARRIVED"];
            
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            [animation setFromValue:[NSNumber numberWithFloat:1.0]];
            [animation setToValue:[NSNumber numberWithFloat:0.0]];
            [animation setDuration:0.5f];
            [animation setTimingFunction:[CAMediaTimingFunction
                                          functionWithName:kCAMediaTimingFunctionLinear]];
            [animation setAutoreverses:YES];
            [animation setRepeatCount:20000];
            [[lblDriverRunningStatus layer] addAnimation:animation forKey:@"opacity"];
            
            [lblArrivalTime setText:@"Driver Arrived. Stay at pick up location."];
            
            
            UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"GoEva has arrived at your pickup location. Please ready to pickup the GoEva."
                                                                          message:@""
                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else if([bSuccess isEqualToString:@"-200"]){ // In case where booking already cancelled by Driver but not recieve APNS
        dispatch_async(dispatch_get_main_queue(), ^{
            /* Start*/
            /* Invalidate All Timer after cancel trip */
            [timerForArrival invalidate];
            timerForArrival = nil;
            [timerForStartTrip invalidate];
            timerForStartTrip = nil;
            /*End*/
            [self.view setUserInteractionEnabled:YES];
            UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Ride has been cancelled"
                                                                          message:@""
                                                                   preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action)
                                        {
                                            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                                        }];
            
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
    else{
        [self performSelectorOnMainThread:@selector(responseLocationFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responseGetDriverLocation{
    [self.view setUserInteractionEnabled:YES];
    btnRefreshDriver.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnRefreshDriver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRefreshDriver setTitle:@"Refresh" forState:UIControlStateNormal];
    btnRefreshDriver.layer.cornerRadius=5;
    btnRefreshDriver.clipsToBounds=YES;
    btnRefreshDriver.userInteractionEnabled=YES;
    
    driverLiveArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getDriverLiveLocation]];
    if (driverLiveArray.count>0 && [[driverLiveArray objectAtIndex:0] current_lat]!= (id)[NSNull null]) {
        
        int minAway = [[[driverLiveArray objectAtIndex:0] remaining_time] intValue];
        if(minAway<=1)
            lblAwayTime.text = [NSString stringWithFormat:@"%d min away",minAway];
        else
            lblAwayTime.text = [NSString stringWithFormat:@"%d mins away",minAway];
        driverMarker.map=nil;
        driverMarker = [[GMSMarker alloc] init];
        /*if(minAway<=1)
            driverMarker.snippet = [NSString stringWithFormat:@"%d MIN AWAY", minAway];
        else
            driverMarker.snippet = [NSString stringWithFormat:@"%d MINS AWAY", minAway];*/
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        driverMarker.iconView = _londonView;
        driverMarker.position = CLLocationCoordinate2DMake([[[driverLiveArray objectAtIndex:0] current_lat] floatValue],[[[driverLiveArray objectAtIndex:0] current_long] floatValue]);
        driverMarker.map = _mapView;
        [_mapView setSelectedMarker:driverMarker];
    }
    else{
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow makeToast:@"Unknown Location. Please try again after sometime."];
    }
}

-(void)responseLocationFailed{
    [self.view setUserInteractionEnabled:YES];
    btnRefreshDriver.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnRefreshDriver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRefreshDriver setTitle:@"Refresh" forState:UIControlStateNormal];
    btnRefreshDriver.layer.cornerRadius=5;
    btnRefreshDriver.clipsToBounds=YES;
    btnRefreshDriver.userInteractionEnabled=YES;
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:@""
                                                                  message:@"Failed to find your location. Please try again."
                                                           preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action)
                                {
                                    //[self homepageSelector];
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}


-(void)commonMethodForRefreshEstimatedTime{
    if([RestCallManager hasConnectivity]){
        btnRefreshDriver.backgroundColor = [UIColor lightGrayColor];
        [btnRefreshDriver setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
        [btnRefreshDriver setTitle:@"Refreshing..." forState:UIControlStateNormal];
        btnRefreshDriver.layer.cornerRadius=5;
        btnRefreshDriver.clipsToBounds=YES;
        btnRefreshDriver.userInteractionEnabled=NO;
        [self.view setUserInteractionEnabled:NO];
        [NSThread detachNewThreadSelector:@selector(requestToServerForGetEstimatedTime) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerForGetEstimatedTime{
    NSString *bSuccess;
    bSuccess = [[RestCallManager sharedInstance] getEstimatedTimeOfRideAfterStartTrip:[notificationDriverDetailsDict valueForKey:@"driver_id"] userType:[GlobalVariable getUserType] bookingID:_bookingID driverCurrentlat:_userCurrentLat driverCurrentLong:_userCurrentLong];
    if([bSuccess isEqualToString:@"0"])
    {
        [self performSelectorOnMainThread:@selector(responseGetEstimatedTime) withObject:nil waitUntilDone:YES];
    }
    else if([bSuccess isEqualToString:@"1"]){ // In case where booking already completed by Driver but not recieve APNS
        dispatch_async(dispatch_get_main_queue(), ^{
            /* Start*/
            /* Invalidate All Timer after trip complete */
            [timerForArrival invalidate];
            timerForArrival=nil;
            [timerForStartTrip invalidate];
            timerForStartTrip = nil;
            /*End*/
            [self.view setUserInteractionEnabled:YES];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Trip Completed!!!" message:@"Trip successfully completed. Press OK button to view fare summary." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                /*NSDictionary *dict = [notification userInfo];
                 NSDictionary *notificationDict= [dict valueForKey:@"aps"];
                 BookingDetailMaster *bookingObj = [[BookingDetailMaster alloc] initWithJsonData:notificationDict];
                 
                 [self.view setUserInteractionEnabled:YES];
                 [loadingView setHidden:YES];
                 CompleteRide *registerController;
                 if (appDel.iSiPhone5) {
                 registerController = [[CompleteRide alloc] initWithNibName:@"CompleteRide" bundle:nil];
                 }
                 else{
                 registerController = [[CompleteRide alloc] initWithNibName:@"CompleteRideLow" bundle:nil];
                 }
                 registerController.bookingObj = bookingObj;
                 registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
                 [self presentViewController:registerController animated:YES completion:nil];*/
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
    else{
        [self performSelectorOnMainThread:@selector(responseLocationFailed) withObject:nil waitUntilDone:YES];
    }
}

-(void) responseGetEstimatedTime{
    [self.view setUserInteractionEnabled:YES];
    btnRefreshDriver.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnRefreshDriver setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnRefreshDriver setTitle:@"Refresh" forState:UIControlStateNormal];
    btnRefreshDriver.layer.cornerRadius=5;
    btnRefreshDriver.clipsToBounds=YES;
    btnRefreshDriver.userInteractionEnabled=YES;
    
    driverLiveArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getDriverLiveLocation]];
    if (driverLiveArray.count>0 && [[driverLiveArray objectAtIndex:0] remaining_time]!= (id)[NSNull null]) {
        int minAway = [[[driverLiveArray objectAtIndex:0] remaining_time] intValue];
        lblAwayTime.text = [NSString stringWithFormat:@"%d min away",minAway];
    }
    else{
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow makeToast:@"Unknown Location. Please try again after sometime."];
    }
}

-(void)setCardData{
    [self.view setUserInteractionEnabled:YES];
    [activityIndicator stopAnimating];
    [imgCard setHidden:NO];
    [lblCardNameWithLast4 setHidden:NO];
    cardArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllCard]];
    CardMaster * cardObj = [cardArray objectAtIndex:0];
    NSInteger item = [cardBrand indexOfObject:[cardObj valueForKey:@"brand"]];
    switch (item) {
        case 0:
            imgCard.image = [UIImage imageNamed:@"card_visa"];
            break;
        case 1:
            imgCard.image = [UIImage imageNamed:@"card_mastercard"];
            break;
        case 2:
            imgCard.image = [UIImage imageNamed:@"card_jcb"];
            break;
        case 3:
            imgCard.image = [UIImage imageNamed:@"card_diners"];
            break;
        case 4:
            imgCard.image = [UIImage imageNamed:@"card_discover"];
            break;
        case 5:
            imgCard.image = [UIImage imageNamed:@"card_amex"];
            break;
        default:
            imgCard.image = [UIImage imageNamed:@"card_unknown"];
            break;
    }
    
    UIColor *color = [UIColor blueColor];
    NSString *card = @"Card";
    NSString *endingIn = @"Ending In";
    
    NSString *lblCardDetails = [NSString stringWithFormat:@"%@ %@ XXXX%@",card,endingIn,[cardObj valueForKey:@"last4"]];
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc]initWithString:lblCardDetails attributes:nil];
    NSString *endingShortStr = endingIn;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:color};
    [mutAttrStr setAttributes:attributes range:NSMakeRange([card length]+1, endingShortStr.length)];
    lblCardNameWithLast4.attributedText = mutAttrStr;
}


- (IBAction)addTipPopup:(UIButton *)sender{
    if (btnAddTips.tag==1) {
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow addSubview:backgroundView];
        viewAddTips.frame = CGRectMake(0, 568, 320, 214);
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             viewAddTips.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
                         }
                         completion:^(BOOL finished){
                         }];
        [currentWindow addSubview:viewAddTips];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(proceedToAddTips)];
        [btnProceedAddTips setTitle:@"Add Tip" forState:UIControlStateNormal];
        [btnProceedAddTips setBackgroundColor:[UIColor blackColor]];
        btnProceedAddTips.layer.cornerRadius=5;
        btnProceedAddTips.clipsToBounds=YES;
        [btnProceedAddTips setUserInteractionEnabled:YES];
        [btnProceedAddTips addGestureRecognizer:tap];
        
        txtAddTips.text = @"";
    }
    else if(btnAddTips.tag==2){
        [self proceedToRemoveTips];
    }
    
}

- (IBAction)closeAddTipsPopup:(UIButton *)sender{
    [backgroundView removeFromSuperview];
    viewAddTips.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         viewAddTips.frame = CGRectMake(0, 568, 320, 214);
                     }
                     completion:^(BOOL finished){
                         [viewAddTips removeFromSuperview];
                     }];
    [viewAddTips removeFromSuperview];
}

- (void)proceedToAddTips{
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        [btnProceedAddTips setTitle:@"Processing..." forState:UIControlStateNormal];
        [btnProceedAddTips setBackgroundColor:[UIColor grayColor]];
        [btnProceedAddTips setUserInteractionEnabled:NO];
        [NSThread detachNewThreadSelector:@selector(requestToServerForAddTips) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}


-(void)requestToServerForAddTips{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] addTips:_bookingID amount:txtAddTips.text];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responseAddTips) withObject:nil waitUntilDone:YES];
    }
    else{ // In case where booking already completed by Driver but not recieve APNS
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView removeFromSuperview];
            [backgroundView removeFromSuperview];
            [self.view setUserInteractionEnabled:YES];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:[GlobalVariable getGlobalMessage] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}
-(void)responseAddTips{
    [self.view setUserInteractionEnabled:YES];
    [backgroundView removeFromSuperview];
    [viewAddTips removeFromSuperview];
    [loadingView removeFromSuperview];
    [btnAddTips setUserInteractionEnabled:YES];
    [btnAddTips setTag:2];
    [btnAddTips setTitle:@"Remove Tip" forState:UIControlStateNormal];
    [lblTips setText:[NSString stringWithFormat:@"You have added $%@ for tip",txtAddTips.text]];
}

- (void)proceedToRemoveTips{
    if([RestCallManager hasConnectivity]){
        [self.view setUserInteractionEnabled:NO];
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Removing..."];
        [self.view addSubview:loadingView];
        [NSThread detachNewThreadSelector:@selector(requestToServerForRemoveTips) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}


-(void)requestToServerForRemoveTips{
    BOOL bSuccess;
    bSuccess = [[RestCallManager sharedInstance] removeTips:_bookingID];
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responseRemoveTips) withObject:nil waitUntilDone:YES];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view setUserInteractionEnabled:YES];
            [loadingView removeFromSuperview];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:[GlobalVariable getGlobalMessage] preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
}
-(void)responseRemoveTips{
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    [btnAddTips setTag:1];
    [btnAddTips setUserInteractionEnabled:YES];
    [btnAddTips setTitle:@"Add Tip" forState:UIControlStateNormal];
    [lblTips setText:@"Do you want to add tip?"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
