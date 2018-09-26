//
//  ChooseCar.m
//  GoEvaRider
//
//  Created by Kalyan Paul on 14/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "ChooseCar.h"
#import "AfterBooking.h"
#import "Dashboard.h"
#import "MYTapGestureRecognizer.h"
#import "MyUtils.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "GlobalVariable.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Constant.h"
#import <Stripe/Stripe.h>
#import "CardMaster.h"
#import <AFNetworking/AFNetworking.h>
#import "Payment.h"
#import "AddCard.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface ChooseCar ()

@end

@implementation ChooseCar{
    GMSMapView *_mapView;
    GMSMarker *pickupMarker;
    GMSMarker *dropMarker;
    UIView *_londonView;
    NSTimer *timer;
    NSTimer *timerForCheckBooking;
    int j;
    int checkLoop;
    AVAudioPlayer *player;
    NSArray *cardBrand; 
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    loadingView = [MyUtils customLoaderFullWindowWithText:self.window loadingText:@"REQUESTING..."];
    [self.view addSubview:loadingView];
    [loadingView setHidden:YES];
    
    activityIndicator.center = CGPointMake(viewCard.frame.size.width / 2, viewCard.frame.size.height / 2);
    
    cardBrand = [NSArray arrayWithObjects:@"Visa", @"MasterCard",@"JCB", @"Diners Club", @"Discover",@"American Express", nil];
    [lblCardName setHidden:YES];
    [lblCardNameWithLast4 setHidden:YES];
    [btnAddOrChangeCard setHidden:YES];
    btnAddOrChangeCard.layer.cornerRadius = 7;
    j=0;
    checkLoop=0;
    [outerViewChooseCar setUserInteractionEnabled:YES];
    [outerViewChooseCarPro setUserInteractionEnabled:YES];
    [outerViewChooseCarGRP setUserInteractionEnabled:YES];
    
    btnConfirmBooking.backgroundColor = [UIColor lightGrayColor];
    [btnConfirmBooking setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
    btnConfirmBooking.userInteractionEnabled=NO;
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForBookConfirmation:) name:@"pushNotificationForBookConfirmation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForNoCabFound:) name:@"pushNotificationForNoCabFound" object:nil];*/
    
    
    
    
    
    MYTapGestureRecognizer *tap1 = [[MYTapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(carTypeSelection:)];
    tap1.data=@"1";
    MYTapGestureRecognizer *tap2 = [[MYTapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(carTypeSelection:)];
    tap2.data=@"2";
    MYTapGestureRecognizer *tap3 = [[MYTapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(carTypeSelection:)];
    tap3.data=@"3";
    
    [outerViewChooseCar addGestureRecognizer:tap1];
    [outerViewChooseCarPro addGestureRecognizer:tap2];
    [outerViewChooseCarGRP addGestureRecognizer:tap3];
    
    _arrayPolylineGreen = [[NSMutableArray alloc] init];
    _path2 = [[GMSMutablePath alloc]init];
    
    [self viewSetup:self.selectedCar];
    pickupLocation = [MyUtils loadCustomObjectWithKey:@"pickupLocation"];
    dropLocation = [MyUtils loadCustomObjectWithKey:@"dropLocation"];
    [lblPickupLocation setText:[NSString stringWithFormat:@"%@",pickupLocation.locationAddress]];
    [lblDropLocation setText:[NSString stringWithFormat:@"%@",dropLocation.locationAddress]];
    [lblAwayTime setText:[NSString stringWithFormat:@"%@ Away",self.awayTimeFromCustomer]];
    [lblPricePerMile setText:[NSString stringWithFormat:@"$%@ / Miles",self.estimatedFareCostPerMile]];
     GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:22.619160
                                                            longitude:88.398099
                                                                 zoom:12];
    _mapView = [GMSMapView mapWithFrame:_mapViewContainer.bounds camera:camera];
    //_mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = NO;
    [_mapViewContainer addSubview:_mapView];
    // Ask for My Location data after the map has already been added to the UI.
//    dispatch_async(dispatch_get_main_queue(), ^{
//        _mapView.myLocationEnabled = YES;
//    });
    
    pickupMarker = [[GMSMarker alloc] init];
    pickupMarker.title = @"Pickup Location";
    pickupMarker.snippet = pickupLocation.locationAddress;
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    [_londonView setFrame:CGRectMake(0, 0, 15, 30)];
    pickupMarker.iconView = _londonView;
    pickupMarker.position = CLLocationCoordinate2DMake([pickupLocation.latitude floatValue],[pickupLocation.longitude floatValue]);
//    pickupMarker.appearAnimation = kGMSMarkerAnimationPop;
//    pickupMarker.flat = YES;
//    pickupMarker.groundAnchor = CGPointMake(0.5, 0.5);
    pickupMarker.map = _mapView;
    
    
    dropMarker = [[GMSMarker alloc] init];
    dropMarker.title = @"Drop Location";
    dropMarker.snippet = dropLocation.locationAddress;
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    [_londonView setFrame:CGRectMake(0, 0, 15, 30)];
    dropMarker.iconView = _londonView;
    dropMarker.position = CLLocationCoordinate2DMake([dropLocation.latitude floatValue],[dropLocation.longitude floatValue]);
//    dropMarker.appearAnimation = kGMSMarkerAnimationPop;
//    dropMarker.flat = YES;
//    dropMarker.groundAnchor = CGPointMake(0.5, 0.5);
    dropMarker.map = _mapView;
    
    [self createPolyLine];
    
    //Get Card Details
    [self getDefaultCard];
}

-(void)createPolyLine{
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           [pickupLocation.latitude floatValue],
                           [pickupLocation.longitude floatValue],
                           [dropLocation.latitude floatValue],
                           [dropLocation.longitude floatValue],
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
            //            CGFloat currentZoom = _mapView.camera.zoom;
            //            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[pickupLocation.latitude doubleValue]
            //                                                 longitude:[pickupLocation.latitude doubleValue]
            //                                                      zoom:currentZoom+1];
            //            [_mapView animateToZoom:currentZoom-0.5];
            
            // animate green path with timer
            timer = [NSTimer scheduledTimerWithTimeInterval:0.003 repeats:false block:^(NSTimer * _Nonnull timer) {
                [self animate:path];
            }];
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
    /*pickupData = [[CLLocation alloc] initWithLatitude:[pickupLocation.latitude floatValue] longitude:[pickupLocation.longitude floatValue]];
     dropData = [[CLLocation alloc] initWithLatitude:[dropLocation.latitude floatValue] longitude:[dropLocation.longitude floatValue]];
     [self drawRoute];*/
    
}

/* - (void)drawRoute
{
    [self fetchPolylineWithOrigin:[[CLLocation alloc] initWithLatitude:[pickupLocation.latitude floatValue] longitude:[pickupLocation.longitude floatValue]] destination:[[CLLocation alloc] initWithLatitude:[dropLocation.latitude floatValue] longitude:[dropLocation.longitude floatValue]] completionHandler:^(GMSPolyline *polyline)
     {
         if(polyline)
             polyline.map = _mapView;
     }];
    
}

- (void)fetchPolylineWithOrigin:(CLLocation *)origin destination:(CLLocation *)destination completionHandler:(void (^)(GMSPolyline *))completionHandler
{
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];
    
    
    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:
                                                 ^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         if(completionHandler)
                                                             completionHandler(nil);
                                                         return;
                                                     }
                                                     
                                                     NSArray *routesArray = [json objectForKey:@"routes"];
                                                     
                                                     
                                                     
                                                     // run completionHandler on main thread
                                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                                         if(completionHandler){
                                                             GMSPolyline *polyline = nil;
                                                             if ([routesArray count] > 0)
                                                             {
                                                                 NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                                 NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                                 NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                                 GMSPath *path = [GMSPath pathFromEncodedPath:points];
                                                                 polyline = [GMSPolyline polylineWithPath:path];
                                                             }
                                                             completionHandler(polyline);
                                                         }
                                                     });
                                                 }];
    [fetchDirectionsTask resume];
}*/


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

-(void)carTypeSelection:(UITapGestureRecognizer *)tapRecognizer {
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    [self viewSetup:tap.data];
}

-(void) viewSetup:(NSString *)selectedCar{
    
    CGRect newFrame = CGRectMake( 0, 0, 70, 70);
    CGRect oldFrame = CGRectMake( 0, 0, 50, 50);
    
    carAvailablityArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getAllCarAvailablity]];
    int count=0;
    for (CarAvailablity *carObj in carAvailablityArray) {
        if ([[carObj car_type_id] isEqualToString:selectedCar]) {
            count++;
            self.selectedCar = [carObj car_type_id];
            self.availabilityID = [carObj availability_id];
            self.awayTimeFromCustomer= [carObj estimated_time];
            self.estimatedFareCostPerMile = [carObj distance_wise_rate];
            [lblAwayTime setText:[NSString stringWithFormat:@"%@ Away",self.awayTimeFromCustomer]];
            [lblPricePerMile setText:[NSString stringWithFormat:@"$%@ / Miles",self.estimatedFareCostPerMile]];
            if (_modeAddCard==1) {
                btnConfirmBooking.backgroundColor = [UIColor lightGrayColor];
                [btnConfirmBooking setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
                btnConfirmBooking.userInteractionEnabled=NO;
            }
            else{
                btnConfirmBooking.backgroundColor = UIColorFromRGB(0xC0392B);
                [btnConfirmBooking setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btnConfirmBooking.userInteractionEnabled=YES;
            }
            break;
        }
    }
    if (count==0) {
        [lblAwayTime setText:[NSString stringWithFormat:@"---- Away"]];
        [lblPricePerMile setText:[NSString stringWithFormat:@"--- / Miles"]];
        btnConfirmBooking.backgroundColor = [UIColor lightGrayColor];
        [btnConfirmBooking setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
        btnConfirmBooking.userInteractionEnabled=NO;
    }
        
    if([selectedCar isEqualToString:@"1"]){
        
        // For GoEva Selected Condition
        viewChooseCar.frame = newFrame;
        viewChooseCar.center = CGPointMake(outerViewChooseCar.frame.size.width/2, outerViewChooseCar.frame.size.height/2);
        viewChooseCar.layer.borderWidth = 2.5f;
        viewChooseCar.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCar.textColor = UIColorFromRGB(0xff0000);
        [lblCar setFont:[UIFont systemFontOfSize:13 weight:2]];
        lblViewChooseCar.backgroundColor = UIColorFromRGB(0xffffff);
        lblViewChooseCar.layer.cornerRadius = 8;
        lblViewChooseCar.clipsToBounds = YES;
        
        
        // For GoEvaPro Normal Condition
        viewChooseCarPro.frame = oldFrame;
        viewChooseCarPro.center = CGPointMake(outerViewChooseCarPro.frame.size.width/2, outerViewChooseCarPro.frame.size.height/2);
        viewChooseCarPro.layer.borderWidth = 0.0f;
        viewChooseCarPro.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCarPro.textColor = UIColorFromRGB(0xffffff);
        [lblCarPro setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCarPro.backgroundColor = [UIColor clearColor];
        lblViewChooseCarPro.clipsToBounds = YES;
        
        // For GoEva GRP Normal Condition
        viewChooseCarGRP.frame = oldFrame;
        viewChooseCarGRP.center = CGPointMake(outerViewChooseCarGRP.frame.size.width/2, outerViewChooseCarGRP.frame.size.height/2);
        viewChooseCarGRP.layer.borderWidth = 0.0f;
        viewChooseCarGRP.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCarGRP.textColor = UIColorFromRGB(0xffffff);
        [lblCarGRP setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCarGRP.backgroundColor = [UIColor clearColor];
        lblViewChooseCarGRP.clipsToBounds = YES;
        
        
        
        
    }
    else if([selectedCar isEqualToString:@"2"]){
        
        // For GoEva Pro Selected Condition
        
        viewChooseCarPro.frame = newFrame;
        viewChooseCarPro.center = CGPointMake(outerViewChooseCarPro.frame.size.width/2, outerViewChooseCarPro.frame.size.height/2);
        viewChooseCarPro.layer.borderWidth = 2.5f;
        viewChooseCarPro.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCarPro.textColor = UIColorFromRGB(0xff0000);
        [lblCarPro setFont:[UIFont systemFontOfSize:13 weight:2]];
        lblViewChooseCarPro.backgroundColor = UIColorFromRGB(0xffffff);
        lblViewChooseCarPro.layer.cornerRadius = 8;
        lblViewChooseCarPro.clipsToBounds = YES;
        
        // For GoEva Normal Condition
        viewChooseCar.frame = oldFrame;
        viewChooseCar.center = CGPointMake(outerViewChooseCar.frame.size.width/2, outerViewChooseCar.frame.size.height/2);
        viewChooseCar.layer.borderWidth = 0.0f;
        viewChooseCar.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCar.textColor = UIColorFromRGB(0xffffff);
        [lblCar setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCar.backgroundColor = [UIColor clearColor];
        lblViewChooseCar.clipsToBounds = YES;
        
        // For GoEva GRP Normal Condition
        viewChooseCarGRP.frame = oldFrame;
        viewChooseCarGRP.center = CGPointMake(outerViewChooseCarGRP.frame.size.width/2, outerViewChooseCarGRP.frame.size.height/2);
        viewChooseCarGRP.layer.borderWidth = 0.0f;
        viewChooseCarGRP.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCarGRP.textColor = UIColorFromRGB(0xffffff);
        [lblCarGRP setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCarGRP.backgroundColor = [UIColor clearColor];
        lblViewChooseCarGRP.clipsToBounds = YES;
        
       
        
        
    }
    else if([selectedCar isEqualToString:@"3"]){
        
        // For GoEva GRP Selected Condition
        
        viewChooseCarGRP.frame = newFrame;
        viewChooseCarGRP.center = CGPointMake(outerViewChooseCarGRP.frame.size.width/2, outerViewChooseCarGRP.frame.size.height/2);
        viewChooseCarGRP.layer.borderWidth = 2.5f;
        viewChooseCarGRP.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCarGRP.textColor = UIColorFromRGB(0xff0000);
        [lblCarGRP setFont:[UIFont systemFontOfSize:13 weight:2]];
        lblViewChooseCarGRP.backgroundColor = UIColorFromRGB(0xffffff);
        lblViewChooseCarGRP.layer.cornerRadius = 8;
        lblViewChooseCarGRP.clipsToBounds = YES;
        
        // For GoEva Normal Condition
        viewChooseCar.frame = oldFrame;
        viewChooseCar.center = CGPointMake(outerViewChooseCar.frame.size.width/2, outerViewChooseCar.frame.size.height/2);
        viewChooseCar.layer.borderWidth = 0.0f;
        viewChooseCar.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCar.textColor = UIColorFromRGB(0xffffff);
        [lblCar setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCar.backgroundColor = [UIColor clearColor];
        lblViewChooseCar.clipsToBounds = YES;
        
        // For GoEvaPro Normal Condition
        viewChooseCarPro.frame = oldFrame;
        viewChooseCarPro.center = CGPointMake(outerViewChooseCarPro.frame.size.width/2, outerViewChooseCarPro.frame.size.height/2);
        viewChooseCarPro.layer.borderWidth = 0.0f;
        viewChooseCarPro.layer.borderColor = [UIColor whiteColor].CGColor;
        
        lblCarPro.textColor = UIColorFromRGB(0xffffff);
        [lblCarPro setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCarPro.backgroundColor = [UIColor clearColor];
        lblViewChooseCarPro.clipsToBounds = YES;
    }
    
    viewChooseCar.layer.cornerRadius = viewChooseCar.frame.size.width / 2;
    viewChooseCar.clipsToBounds = YES;
    
    viewChooseCarPro.layer.cornerRadius = viewChooseCarPro.frame.size.width / 2;
    viewChooseCarPro.clipsToBounds = YES;
    
    viewChooseCarGRP.layer.cornerRadius = viewChooseCarGRP.frame.size.width / 2;
    viewChooseCarGRP.clipsToBounds = YES;
    
}

/* - (void) pushNotificationForBookConfirmation:(NSNotification *)notification{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"pushNotificationForBookConfirmation"                                                      object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"pushNotificationForNoCabFound"                                                      object:nil];
    
    _carAvailablityModeFor30Sec=@"1";
    NSDictionary *dict = [notification userInfo];
    NSDictionary *notificationDict= [dict valueForKey:@"aps"];
    [self.view setUserInteractionEnabled:YES];
    [loadingView setHidden:YES];
    
    AfterBooking *registerController ;
    if (appDel.iSiPhone5) {
        registerController = [[AfterBooking alloc] initWithNibName:@"AfterBooking" bundle:nil];
    }
    else{
        registerController = [[AfterBooking alloc] initWithNibName:@"AfterBookingLow" bundle:nil];
    }
    registerController.notificationDriverDetailsDict = notificationDict;
    registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:registerController animated:YES completion:nil];
    
}*/

/* - (void) pushNotificationForNoCabFound:(NSNotification *)notification{
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"pushNotificationForBookConfirmation"                                                      object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"pushNotificationForNoCabFound"                                                      object:nil];
    
    _carAvailablityModeFor30Sec=@"1";
    
    NSDictionary *dict = [notification userInfo];
    NSDictionary *notificationDict= [dict valueForKey:@"aps"];
    [self.view setUserInteractionEnabled:YES];
    [loadingView setHidden:YES];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No cars available at the moment. Please try again in a few minutes." message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView commitAnimations];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
    
}*/

- (IBAction)confirmBooking:(id)sender {
    
    if([RestCallManager hasConnectivity]){
        [timer invalidate];
        timer = nil;
        [loadingView setHidden:NO];
        //_carAvailablityModeFor30Sec=@"0";// For checking Cab Availablity For 30 sec
        [self.view setUserInteractionEnabled:NO];
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        self.navigationController.view.userInteractionEnabled = NO;
        //[self performSelector:@selector(checkCabAvailable) withObject:self afterDelay:30.0 ];
        timerForCheckBooking = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                         target:self selector:@selector(checkingBooingRequest:) userInfo:nil repeats:YES];
        [NSThread detachNewThreadSelector:@selector(requestToServer) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is connected to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

- (void)checkingBooingRequest:(NSTimer *)myTimer{
    checkLoop++;
    if([RestCallManager hasConnectivity]){
        
        [NSThread detachNewThreadSelector:@selector(requestToServerForCheckBookingStatus) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is connected to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

/* -(void)checkCabAvailable{
    if([_carAvailablityModeFor30Sec isEqualToString:@"1"]){
        // For successful recieve notification
    }
    else{
        [self.view setUserInteractionEnabled:YES];
        [loadingView setHidden:YES];
        
        
        //[[NSNotificationCenter defaultCenter] removeObserver:@"pushNotificationForNoCabFound"];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"pushNotificationForBookConfirmation"                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"pushNotificationForNoCabFound"                                                      object:nil];
        
        [NSThread detachNewThreadSelector:@selector(requestToServerForCancelRequest) toTarget:self withObject:nil];
        
    }
}*/

-(void)requestToServer{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] requestBooking:[MyUtils getUserDefault:@"riderID"] availabilityID:self.availabilityID carTypeID:self.selectedCar pickupLocation:pickupLocation.locationAddress dropLocation:dropLocation.locationAddress sourceLat:pickupLocation.latitude sourceLong:pickupLocation.longitude descLat:dropLocation.latitude descLong:dropLocation.longitude pickCar:@"0"];
    if(bSuccess)
    {
            [self performSelectorOnMainThread:@selector(showContactDialog) withObject:nil waitUntilDone:YES];
    }
    else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [timerForCheckBooking invalidate];
                    timerForCheckBooking = nil;
                    [self.view setUserInteractionEnabled:YES];
                    [loadingView setHidden:YES];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry, We are not getting any GoEva rides nearest your location. Please try after some time." message:@"" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                        
                        [UIView beginAnimations:nil context:NULL];
                        [UIView setAnimationDuration:0.3];
                        [UIView commitAnimations];
                        [self dismissViewControllerAnimated:YES completion:nil];
                        
                    }];
                    [alertController addAction:action];
                    [self presentViewController:alertController animated:YES completion:nil];

                });
    }
}

-(void)requestToServerForCheckBookingStatus{
    
    NSMutableDictionary *bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] checkRequestStatus:[GlobalVariable getBookingID]];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(responseDriverFound:) withObject:bSuccess waitUntilDone:YES];
    }
    else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (checkLoop==3) {
                [self.view setUserInteractionEnabled:YES];
                
                [timerForCheckBooking invalidate];
                timerForCheckBooking = nil;
                [NSThread detachNewThreadSelector:@selector(requestToServerForCancelRequest) toTarget:self withObject:nil];
            }
            
            /* UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:[NSString stringWithFormat:@"No Cab available"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
             [loginAlert show];*/
        });
    }
}

-(void)responseDriverFound:(NSMutableDictionary *)notificationDict{
    
        [timerForCheckBooking invalidate];
        timerForCheckBooking = nil;
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    localNotification.alertBody = @"Booking Confirmed. Click here to see the details.";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [self.view setUserInteractionEnabled:YES];
    [loadingView setHidden:YES];
    
    
    [_mapView clear];
    [_mapView stopRendering] ;
    [_mapView removeFromSuperview] ;
    _mapView = nil ;
    
    // start/set ride timer for tracking in case of cancellation. If more than 4 minutes.
    NSDate *currentDate = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"rideTimer"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [MyUtils setUserDefault:@"bookingID" value:[notificationDict valueForKey:@"booking_id"]];
    
    AfterBooking *registerController ;
    if (appDel.iSiPhone5) {
        registerController = [[AfterBooking alloc] initWithNibName:@"AfterBooking" bundle:nil];
    }
    else{
        registerController = [[AfterBooking alloc] initWithNibName:@"AfterBookingLow" bundle:nil];
    }
    registerController.notificationDriverDetailsDict = notificationDict;
    registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:registerController animated:YES completion:nil];
    
    
}
 -(void)requestToServerForCancelRequest{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] cancelRequestByRider:[GlobalVariable getBookingID]];
    
    if(bSuccess)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView setHidden:YES];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No cars available at the moment. Please try again in a few minutes." message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0.3];
                [UIView commitAnimations];
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        });
    }
    else{
        [loadingView setHidden:YES];
    }
}

-(void)showContactDialog{
//    [self.view setUserInteractionEnabled:YES];
//    [loadingView setHidden:YES];
//    AfterBooking *registerController = [[AfterBooking alloc] initWithNibName:@"AfterBooking" bundle:nil];
//    registerController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
//    [self presentViewController:registerController animated:YES completion:nil];
}


- (IBAction)backToHomePage:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
    [timer invalidate];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)getDefaultCard{
    
    [lblCardName setHidden:YES];
    [lblCardNameWithLast4 setHidden:YES];
    [btnAddOrChangeCard setHidden:YES];
    
    btnConfirmBooking.backgroundColor = [UIColor lightGrayColor];
    [btnConfirmBooking setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
    btnConfirmBooking.userInteractionEnabled=NO;
    
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    [activityIndicator startAnimating];
    [self.view setUserInteractionEnabled:NO];
    NSString *URL = [NSString stringWithFormat:@"%@get_default_card.php",BackendBaseURL];
    NSDictionary *params =  @{
                              @"rider_id": [MyUtils getUserDefault:@"riderID"]
                              };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Object: %@", responseObject);
        
        if ([[responseObject valueForKey:@"status"] isEqualToString:@"0"]) {
            _modeAddCard = 0;
            NSData *JSONdata = [[responseObject valueForKey:@"Mycard"] dataUsingEncoding:NSUTF8StringEncoding];
            if (JSONdata != nil) {
                NSError * error =nil;
                
                NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
                NSMutableArray * arr = [[NSMutableArray alloc]init];
                for (int i = 0; i < [jsonUserInfo count]; i++) {
                    CardMaster * fund = [[CardMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                    [arr addObject:fund];
                }
                [[DataStore sharedInstance] addCards:arr];
            }
            [self setCardData];
        }
        else{
            [activityIndicator stopAnimating];
            [activityIndicator setHidesWhenStopped:YES];
            [self.view setUserInteractionEnabled:YES];
            _modeAddCard = 1;
            [lblCardName setHidden:NO];
            [lblCardNameWithLast4 setHidden:NO];
            [lblCardName setText:@"NO CARD"];
            lblCardNameWithLast4.text = @"To Continue";
            [btnAddOrChangeCard setTitle:@"Add New Card" forState:UIControlStateNormal];
            [btnAddOrChangeCard setHidden:NO];
            btnConfirmBooking.backgroundColor = [UIColor lightGrayColor];
            [btnConfirmBooking setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.3] forState:UIControlStateNormal];
            btnConfirmBooking.userInteractionEnabled=NO;
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self exampleViewController:self didFinishWithError:error];
    }];
    
}

-(void)setCardData{
    [self.view setUserInteractionEnabled:YES];
    [activityIndicator stopAnimating];
    [activityIndicator setHidesWhenStopped:YES];
    
    btnConfirmBooking.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnConfirmBooking setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnConfirmBooking.userInteractionEnabled=YES;
    
    [lblCardName setHidden:NO];
    [lblCardNameWithLast4 setHidden:NO];
    [btnAddOrChangeCard setHidden:NO];
    cardArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllCard]];
    CardMaster * cardObj = [cardArray objectAtIndex:0];
    lblCardName.text = [cardObj valueForKey:@"brand"];
    
    UIColor *color = [UIColor redColor];
    NSString *endingIn = @"Ending In";
    NSString *lblCardDetails = [NSString stringWithFormat:@"%@ %@",endingIn,[cardObj valueForKey:@"last4"]];
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc]initWithString:lblCardDetails attributes:nil];
    NSString *endingShortStr = [cardObj valueForKey:@"last4"];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:color};
    [mutAttrStr setAttributes:attributes range:NSMakeRange([endingIn length]+1, endingShortStr.length)];
    lblCardNameWithLast4.attributedText = mutAttrStr;
    
    btnConfirmBooking.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnConfirmBooking setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnConfirmBooking.userInteractionEnabled=YES;
    
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error {
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        //[self.navigationController popViewControllerAnimated:YES];
    }];
    [alertController addAction:action];
    [controller presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)AddOrChangeCard:(id)sender{
    
    if (_modeAddCard==1) {
        AddCard *addController;
        if (appDel.iSiPhone5) {
            addController = [[AddCard alloc] initWithNibName:@"AddCard" bundle:nil];
        }
        else{
            addController = [[AddCard alloc] initWithNibName:@"AddCardLow" bundle:nil];
        }
        addController.AddCardMode = 2;
        addController.delegate=self;
        addController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:addController animated:YES completion:nil];
    }
    else if(_modeAddCard==0){
        Payment *paymentController;
        if (appDel.iSiPhone5) {
            paymentController = [[Payment alloc] initWithNibName:@"Payment" bundle:nil];
        }
        else{
            paymentController = [[Payment alloc] initWithNibName:@"PaymentLow" bundle:nil];
        }
        paymentController.delegate=self;
        paymentController.setDefaultCardMode=1;
        paymentController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:paymentController animated:YES completion:nil];
    }
    
}

-(void)sendDatafromAddCardToPayNowPage
{
    [self getDefaultCard];
}

-(void)sendDatafromCardListToPayNowPage
{
    [self getDefaultCard];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
