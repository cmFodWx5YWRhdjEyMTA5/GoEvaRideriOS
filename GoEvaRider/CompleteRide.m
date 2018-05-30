//
//  CompleteRide.m
//  GoEvaRider
//
//  Created by Kalyan Paul on 19/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//
#import "CompleteRide.h"
#import "MFSideMenu.h"
#import "MyUtils.h"
#import "DataStore.h"
#import "AsyncImageView.h"
#import "RateUsDriver.h"

@interface CompleteRide ()

@end

@implementation CompleteRide{
    GMSMapView *_mapView;
    GMSMarker *pickupMarker;
    GMSMarker *dropMarker;
    UIView *_londonView;
    NSTimer *timer;
    int j;
}
@synthesize bookingObj;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewDriverImage.layer.cornerRadius = viewDriverImage.frame.size.width / 2;
    viewDriverImage.clipsToBounds = YES;
    
    //bookingObj = [[DataStore sharedInstance] getBookingByID:_bookingID];
    
    lblBookingDateTime.text = [bookingObj booking_datetime];
    lblCarTypeBookingNo.text = [NSString stringWithFormat:@"%@. CEN %@",[bookingObj car_category_name], [bookingObj booking_id]];
    btnClose.layer.cornerRadius=10;
    imgDriverImage.contentMode = UIViewContentModeScaleAspectFill;
    imgDriverImage.clipsToBounds = YES;
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgDriverImage];
    //set placeholder image or cell won't update when image is loaded
    imgDriverImage.image = [UIImage imageNamed:@"profile"];
    //load the image
    imgDriverImage.imageURL = [NSURL URLWithString:[bookingObj driver_image]];
    lblDriverName.text = [bookingObj driver_name];
    
    
    UIButton *btnRateUs = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRateUs addTarget:self action:@selector(rateUsNow:) forControlEvents:UIControlEventTouchUpInside];
    [btnRateUs setTitle:@"Rate us driver " forState:UIControlStateNormal];
    btnRateUs.titleLabel.font = [UIFont systemFontOfSize:14];
    btnRateUs.frame = CGRectMake(63.0, 25.0, 150.0, 30.0);
    btnRateUs.layer.backgroundColor = [[UIColor redColor] CGColor];
    btnRateUs.layer.cornerRadius = 10;
    [viewDriverProfile addSubview:btnRateUs];
    
    
    lblCarName.text = [NSString stringWithFormat:@"%@ - %@",[bookingObj car_category_name], [bookingObj car_name]];
        viewPaymentDetails.hidden = NO;
        innerView.frame = CGRectMake(0, 0, innerView.frame.size.width, _mapViewContainer.frame.size.height + viewDriverProfile.frame.size.height+viewCarProfile.frame.size.height+viewFare.frame.size.height+viewLocation.frame.size.height+viewPaymentDetails.frame.size.height+35);
        CGSize scrollViewSize = CGSizeMake(innerView.bounds.size.width,innerView.bounds.size.height);
        [self.backGroundScroll setContentSize:scrollViewSize];
        
        lblFare.text = [NSString stringWithFormat:@"$ %@",[bookingObj total_fare]];
        lblDistance.text = [NSString stringWithFormat:@"%@ Km",[bookingObj total_distance]];
        lblDuration.text = [NSString stringWithFormat:@"%@ min",[bookingObj total_time]];
        lblStartTime.text = [bookingObj ride_start_time];
        lblEndTime.text = [bookingObj ride_completion_time];
        viewPaymentDetails.hidden = NO;
        lblRideFare.text = [bookingObj total_base_fare];
        lblTotalNetFare.text = [bookingObj total_fare];
    
    lblPickupLocation.text = ([bookingObj pickup_location]==(id)[NSNull null])?@"":[bookingObj pickup_location];
    lblDropLocation.text = ([bookingObj drop_location]==(id)[NSNull null])?@"":[bookingObj drop_location];
    [self setMap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

-(void)setMap{
    _arrayPolylineGreen = [[NSMutableArray alloc] init];
    _path2 = [[GMSMutablePath alloc]init];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:22.619160
                                                            longitude:88.398099
                                                                 zoom:12];
    _mapView = [GMSMapView mapWithFrame:_mapViewContainer.bounds camera:camera];
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = NO;
    _mapView.userInteractionEnabled=NO;
    [_mapViewContainer addSubview:_mapView];
    
    pickupMarker = [[GMSMarker alloc] init];
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    //    CGRect newFrame = _londonView.frame;
    //    newFrame.size = CGSizeMake(15.0, 30.0);
    [_londonView setFrame:CGRectMake(0, 0, 15, 30)];
    pickupMarker.iconView = _londonView;
    pickupMarker.position = CLLocationCoordinate2DMake([[bookingObj pickup_lat] floatValue],[[bookingObj pickup_long] floatValue]);
    pickupMarker.map = _mapView;
    
    dropMarker = [[GMSMarker alloc] init];
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    [_londonView setFrame:CGRectMake(0, 0, 15, 30)];
    dropMarker.iconView = _londonView;
    dropMarker.position = CLLocationCoordinate2DMake([[bookingObj drop_lat] floatValue],[[bookingObj drop_long] floatValue]);
    dropMarker.map = _mapView;
    [self createPolyLine];
}


-(void)createPolyLine{
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           [[bookingObj pickup_lat] floatValue],
                           [[bookingObj pickup_long] floatValue],
                           [[bookingObj drop_lat] floatValue],
                           [[bookingObj drop_long] floatValue],
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
            
        }
        @catch (NSException * e) {
            //NSLog(@"Exception: %@", e);
            /*UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"There is no any routes available. Please choose another drop location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [loginAlert show];*/
        }
    }
    else {
        //NSLog(@"%@",[request error]);
    }
    
}


-(void)rateUsNow:(UIButton *)sender{
    RateUsDriver *rateUs;
    if (appDel.iSiPhone5) {
        rateUs = [[RateUsDriver alloc] initWithNibName:@"RateUsDriver" bundle:nil];
    }
    else{
        rateUs = [[RateUsDriver alloc] initWithNibName:@"RateUsDriverLow" bundle:nil];
    }
    rateUs.bookingID = [bookingObj booking_id];
    rateUs.driverImage = [bookingObj driver_image];
    rateUs.driverName = [bookingObj driver_name];
    rateUs.screenMode = @"0";
    rateUs.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:rateUs animated:YES completion:nil];
}

- (IBAction)goToHomePage:(UIButton *)sender {
    [self.view setUserInteractionEnabled:YES];
    //[DashboardCaller homepageSelector:self];
    [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
