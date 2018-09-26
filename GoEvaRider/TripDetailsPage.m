//
//  TripDetailsPage.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/15/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "TripDetailsPage.h"
#import "MFSideMenu.h"
#import "MyUtils.h"
#import "DataStore.h"
#import "AsyncImageView.h"
#import "RateUsDriver.h"

@interface TripDetailsPage ()

@end

@implementation TripDetailsPage{
    GMSMapView *_mapView;
    GMSMarker *pickupMarker;
    GMSMarker *dropMarker;
    UIView *_londonView;
    NSTimer *timer;
    int j;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewDriverImage.layer.cornerRadius = viewDriverImage.frame.size.width / 2;
    viewDriverImage.clipsToBounds = YES;
    
    bookingObj = [[DataStore sharedInstance] getBookingByID:_bookingID];
    
    lblBookingDateTime.text = [bookingObj booking_datetime];
    lblCarTypeBookingNo.text = [NSString stringWithFormat:@"%@. CEN %@",[bookingObj car_category_name], [bookingObj booking_id]];
    imgDriverImage.contentMode = UIViewContentModeScaleAspectFill;
    imgDriverImage.clipsToBounds = YES;
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgDriverImage];
    //set placeholder image or cell won't update when image is loaded
    imgDriverImage.image = [UIImage imageNamed:@"profile"];
    //load the image
    imgDriverImage.imageURL = [NSURL URLWithString:[bookingObj driver_image]];
    lblDriverName.text = [bookingObj driver_name];
    
    lblRatingHint.hidden = YES;
    viewRatingStar.hidden = YES;
    lblRating.hidden =YES;
    
    if ([[bookingObj booking_status] isEqualToString:@"1"]) {
        float ratingValue = 0.0;
        if ([bookingObj rider_rating] == (id)[NSNull null] || [[bookingObj rider_rating] isEqualToString:@""] || [[bookingObj rider_rating] isEqualToString:@"0"])
        {
            lblRatingHint.hidden = YES;
            viewRatingStar.hidden = YES;
            lblRating.hidden =YES;
            UIButton *btnRateUs = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnRateUs addTarget:self action:@selector(rateUsNow:) forControlEvents:UIControlEventTouchUpInside];
            [btnRateUs setTitle:@"Rate Driver" forState:UIControlStateNormal];
            btnRateUs.titleLabel.font = [UIFont systemFontOfSize:12];
            btnRateUs.frame = CGRectMake(63.0, 25.0, 100.0, 20.0);
            btnRateUs.layer.backgroundColor = [[UIColor redColor] CGColor];
            btnRateUs.layer.cornerRadius = 5;
            [viewDriverProfile addSubview:btnRateUs];
        }
        else{
            viewRatingStar.hidden = NO;
            lblRating.hidden =NO;
            lblRatingHint.hidden = NO;
            ratingValue = [[bookingObj rider_rating] floatValue];
            for (int k=0; k<5; k++) {
                UIImageView *star_img;
                if (k==0){
                    star_img = [[UIImageView alloc]initWithFrame:CGRectMake(6, 0, 20, 20)];
                }
                
                else{
                    star_img = [[UIImageView alloc]initWithFrame:CGRectMake(6*(2*k+1)+2*k, 0, 20, 20)];
                }
                
                if (ratingValue >= k+1) {
                    [star_img setImage:[UIImage imageNamed:@"ic_yellow_star"]];
                } else if (ratingValue > k) {
                    [star_img setImage:[UIImage imageNamed:@"ic_yellow_half_star"]];
                } else {
                    [star_img setImage:[UIImage imageNamed:@"ic_gray_star"]];
                }
                
                [viewRatingStar addSubview:star_img];
            }
            
            lblRating.layer.cornerRadius = 5;
            lblRating.clipsToBounds=YES;
            lblRating.text = [NSString stringWithFormat:@"%@/5",[bookingObj rider_rating]];
            
        }
    }
    
    lblCarName.text = [NSString stringWithFormat:@"%@ - %@",[bookingObj car_category_name], [bookingObj car_name]];
    if ([[bookingObj booking_status] isEqualToString:@"1"] && [[bookingObj payment_type] isEqualToString:@"1"]) {
        viewPaymentDetails.hidden = NO;
        innerView.frame = CGRectMake(0, 0, innerView.frame.size.width, _mapViewContainer.frame.size.height + viewDriverProfile.frame.size.height+viewCarProfile.frame.size.height+viewFare.frame.size.height+viewLocation.frame.size.height+viewPaymentDetails.frame.size.height+35);
        CGSize scrollViewSize = CGSizeMake(innerView.bounds.size.width,innerView.bounds.size.height);
        [self.backGroundScroll setContentSize:scrollViewSize];
        
        lblFare.text = [NSString stringWithFormat:@"$ %@",[bookingObj total_fare]];
        lblDistance.text = [NSString stringWithFormat:@"%@ mi",[bookingObj total_distance]];
        lblDuration.text = [NSString stringWithFormat:@"%@ min",[bookingObj total_time]];
        imgCancel.hidden=YES;
        lblStartTime.text = [bookingObj ride_start_time];
        lblEndTime.text = [bookingObj ride_completion_time];
        lblRideFare.text = [NSString stringWithFormat:@"$ %@",[bookingObj total_base_fare]];
        lblTips.text = [NSString stringWithFormat:@"$ %@",[bookingObj tips_amount]];
        lblTotalNetFare.text = [NSString stringWithFormat:@"$ %@",[bookingObj total_fare]];
    }
    else{
        if ([bookingObj payment_type] == (id)[NSNull null]) {
            viewPaymentDetails.hidden = YES;
            innerView.frame = CGRectMake(0, 0, innerView.frame.size.width, _mapViewContainer.frame.size.height + viewDriverProfile.frame.size.height+viewCarProfile.frame.size.height+viewFare.frame.size.height+viewLocation.frame.size.height+35);
            CGSize scrollViewSize = CGSizeMake(innerView.bounds.size.width,innerView.bounds.size.height);
            [self.backGroundScroll setContentSize:scrollViewSize];
            lblFare.text = @"---";
            lblDistance.text = @"---";
            lblDuration.text = @"---";
            imgCancel.hidden=NO;
        }
        else if([[bookingObj payment_type] isEqualToString:@"2"]){
            lblRatingHint.hidden = NO;
            if([[bookingObj booking_status] isEqualToString:@"-100"]){
                lblRatingHint.text = @"Cancelled by You";
            }
            else{
                lblRatingHint.text = @"Cancelled by Driver";
            }
            viewPaymentDetails.hidden = NO;
            innerView.frame = CGRectMake(0, 0, innerView.frame.size.width, _mapViewContainer.frame.size.height + viewDriverProfile.frame.size.height+viewCarProfile.frame.size.height+viewFare.frame.size.height+viewLocation.frame.size.height+viewPaymentDetails.frame.size.height+35);
            CGSize scrollViewSize = CGSizeMake(innerView.bounds.size.width,innerView.bounds.size.height);
            [self.backGroundScroll setContentSize:scrollViewSize];
            txtRideFare.text = @"Cancellation Charges";
            lblRideFare.text = [NSString stringWithFormat:@"$ %@",[bookingObj total_base_fare]];
            lblTips.text = [NSString stringWithFormat:@"$ %@",[bookingObj tips_amount]];
            lblTotalNetFare.text = [NSString stringWithFormat:@"$ %@",[bookingObj total_fare]];
            lblFare.text = @"---";
            lblDistance.text = @"---";
            lblDuration.text = @"---";
            imgCancel.hidden=NO;
        }
        
        
    }
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
    rateUs.screenMode = @"1";
    rateUs.isRestartApp = NO;
    rateUs.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:rateUs animated:YES completion:nil];
}

- (IBAction)backToPrevious:(UIButton *)sender{
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
