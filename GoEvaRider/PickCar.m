//
//  PickCar.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 10/10/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "PickCar.h"
#import "PickCarDetail.h"
#import "PickupLocation.h"
#import "DropLocation.h"
#import "MyUtils.h"
#import "MYTapGestureRecognizer.h"
#import "ChooseCar.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import "CarAvailablity.h"
#import "UIView+Toast.h"
#import "MyUtils.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "Dashboard.h"
#import "DashboardCaller.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PickCar ()

@end

@implementation PickCar{
    GMSMapView *_mapView;
    BOOL _firstLocationUpdate;
    GMSMarker *locationMarker;
    UIImageView *_londonView;
    AVAudioPlayer *player;
    GMSMarker *pickerMarker;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self searchFields];
    
    viewChooseCar.layer.cornerRadius = viewChooseCar.frame.size.width / 2;
    viewChooseCar.clipsToBounds = YES;
    
    viewChooseCarPro.layer.cornerRadius = viewChooseCarPro.frame.size.width / 2;
    viewChooseCarPro.clipsToBounds = YES;
    
    viewChooseCarGRP.layer.cornerRadius = viewChooseCarGRP.frame.size.width / 2;
    viewChooseCarGRP.clipsToBounds = YES;
    
    [viewFrom setUserInteractionEnabled:YES];
    [viewTo setUserInteractionEnabled:YES];
    [viewChooseCar setUserInteractionEnabled:YES];
    [viewChooseCarPro setUserInteractionEnabled:YES];
    [viewChooseCarGRP setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(pickupLocationController)];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(dropLocationController)];
    [viewFrom addGestureRecognizer:tap];
    [viewTo addGestureRecognizer:tap2];
    
    MYTapGestureRecognizer *tap3 = [[MYTapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(viewSelectedCar:)];
    tap3.data=@"1";
    MYTapGestureRecognizer *tap4 = [[MYTapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(viewSelectedCar:)];
    tap4.data=@"2";
    MYTapGestureRecognizer *tap5 = [[MYTapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(viewSelectedCar:)];
    tap5.data=@"3";
    
    [viewChooseCar addGestureRecognizer:tap3];
    [viewChooseCarPro addGestureRecognizer:tap4];
    [viewChooseCarGRP addGestureRecognizer:tap5];
    selectedCarType =@"";
    
    returnPickupAddressMode=0;
    returnDropAddressMode=0;
    
}

-(void) searchFields{
    
    textFieldFromMode=@"1";
    textFieldToMode=@"0";
    shadowPath = [UIBezierPath bezierPathWithRect:viewFrom.bounds];
    viewFrom.layer.masksToBounds = NO;
    viewFrom.layer.shadowColor = [UIColor redColor].CGColor;
    viewFrom.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    viewFrom.layer.shadowOpacity = 1.0f;
    viewFrom.layer.shadowPath = shadowPath.CGPath;
    viewFrom.layer.cornerRadius = 3;
    txtPickupLocation.textColor = [UIColor blackColor];
    txtPickupLocation.font =[UIFont systemFontOfSize:15];
    img_editFrom.hidden=NO;
    markerFrom.frame = CGRectMake(1, 5, 22, 22);
    
    shadowPath2 = [UIBezierPath bezierPathWithRect:viewTo.bounds];
    viewTo.layer.masksToBounds = NO;
    viewTo.layer.shadowColor = [UIColor blackColor].CGColor;
    viewTo.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    viewTo.layer.shadowOpacity = 0.5f;
    viewTo.layer.shadowPath = shadowPath2.CGPath;
    viewTo.layer.cornerRadius = 3;
    txtDropLocation.textColor = [UIColor grayColor];
    txtDropLocation.font =[UIFont systemFontOfSize:13];
    img_editTo.hidden=YES;
    markerTo.frame = CGRectMake(4, 8, 18, 18);
    
    inputViewContainer.frame = CGRectMake(10, 70, 299, 135);
    [self.view addSubview:inputViewContainer];
    
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:inputViewContainer.bounds];
    inputViewContainer.layer.masksToBounds = NO;
    inputViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    inputViewContainer.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    inputViewContainer.layer.shadowOpacity = 0.5f;
    inputViewContainer.layer.shadowPath = shadowPath3.CGPath;
    inputViewContainer.layer.cornerRadius = 10;
}

- (void)applicationIsActive:(NSNotification *)notification {
    //NSLog(@"Application Did Become Active");
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    //NSLog(@"Application Entered Foreground");
    _firstLocationUpdate=NO;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        // iOS 7.0 or later
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xDA4131);
        self.navigationController.navigationBar.translucent = NO;
    }else {
        // iOS 6.1 or earlier
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0xDA4131);
    }
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UILabel *lblTitle = [[UILabel alloc] init];
    lblTitle.text = self.pageTitle;
    lblTitle.backgroundColor = [UIColor clearColor];
    lblTitle.textColor = [UIColor whiteColor];
    lblTitle.shadowOffset = CGSizeMake(0, 1);
    lblTitle.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [lblTitle sizeToFit];
    self.navigationItem.titleView = lblTitle;
    
    MyUtils *utils= [[MyUtils alloc] init];
    [utils setupMenuBarButtonItems:self tilteLable:self.pageTitle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    _firstLocationUpdate = NO;
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:22.619160
                                                                longitude:88.398099
                                                                     zoom:16];
        
        _mapView = [GMSMapView mapWithFrame:_mapViewContainer.bounds camera:camera];
        _mapView.delegate=self;
        _mapView.settings.compassButton = YES;
        _mapView.settings.myLocationButton = YES;
        _mapView.padding = UIEdgeInsetsMake(0, 0, 20, 0);
        // Listen to the myLocation property of GMSMapView.
        [_mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        [_mapViewContainer addSubview:_mapView];
        // Ask for My Location data after the map has already been added to the UI.
        dispatch_async(dispatch_get_main_queue(), ^{
            _mapView.myLocationEnabled = YES;
            
        });
    
    if (returnPickupAddressMode==1) {
        _firstLocationUpdate = YES;// For no update in map
        locationMarker.map  = nil;
        locationMarker = [[GMSMarker alloc] init];
        locationMarker.appearAnimation=kGMSMarkerAnimationPop;
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        locationMarker.iconView = _londonView;
        CLLocationCoordinate2D fromLocation = CLLocationCoordinate2DMake([pickupLocation.latitude doubleValue],[pickupLocation.longitude doubleValue]);
        locationMarker.position = fromLocation;
        locationMarker.map = _mapView;
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:fromLocation zoom:16];
        [_mapView animateWithCameraUpdate:updatedCamera];
    }
    if (returnDropAddressMode==1) {
        _firstLocationUpdate = YES;// For no update in map
        locationMarker.map  = nil;
        locationMarker = [[GMSMarker alloc] init];
        locationMarker.appearAnimation=kGMSMarkerAnimationPop;
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        locationMarker.iconView = _londonView;
        CLLocationCoordinate2D toLocation = CLLocationCoordinate2DMake([dropLocation.latitude doubleValue],[dropLocation.longitude doubleValue]);
        locationMarker.position = toLocation;
        locationMarker.map = _mapView;
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:toLocation zoom:16];
        [_mapView animateWithCameraUpdate:updatedCamera];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

-(void) viewSetup:(NSString *)selectedCar{
    
    carAvaialblityID=@"";
    if([selectedCar isEqualToString:@"1"]){
        
        // For GoEva Selected Condition
        viewChooseCar.layer.borderWidth = 2.0f;
        viewChooseCar.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCar.textColor = UIColorFromRGB(0xff0000);
        [lblCar setFont:[UIFont systemFontOfSize:12 weight:2]];
        lblViewChooseCar.backgroundColor = UIColorFromRGB(0xffffff);
        lblViewChooseCar.layer.cornerRadius = 8;
        lblViewChooseCar.clipsToBounds = YES;
        
        // For GoEvaPro Normal Condition
        viewChooseCarPro.layer.borderWidth = 0.0f;
        viewChooseCarPro.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCarPro.textColor = UIColorFromRGB(0xffffff);
        [lblCarPro setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCarPro.backgroundColor = [UIColor clearColor];
        lblViewChooseCarPro.clipsToBounds = YES;
        
        // For GoEva GRP Normal Condition
        viewChooseCarGRP.layer.borderWidth = 0.0f;
        viewChooseCarGRP.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCarGRP.textColor = UIColorFromRGB(0xffffff);
        [lblCarGRP setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCarGRP.backgroundColor = [UIColor clearColor];
        lblViewChooseCarGRP.clipsToBounds = YES;
    }
    else if([selectedCar isEqualToString:@"2"]){
        
        // For GoEva Pro Selected Condition
        viewChooseCarPro.layer.borderWidth = 2.0f;
        viewChooseCarPro.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCarPro.textColor = UIColorFromRGB(0xff0000);
        [lblCarPro setFont:[UIFont systemFontOfSize:12 weight:2]];
        lblViewChooseCarPro.backgroundColor = UIColorFromRGB(0xffffff);
        lblViewChooseCarPro.layer.cornerRadius = 8;
        lblViewChooseCarPro.clipsToBounds = YES;
        
        // For GoEva Normal Condition
        viewChooseCar.layer.borderWidth = 0.0f;
        viewChooseCar.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCar.textColor = UIColorFromRGB(0xffffff);
        [lblCar setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCar.backgroundColor = [UIColor clearColor];
        lblViewChooseCar.clipsToBounds = YES;
        
        // For GoEva GRP Normal Condition
        viewChooseCarGRP.layer.borderWidth = 0.0f;
        viewChooseCarGRP.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCarGRP.textColor = UIColorFromRGB(0xffffff);
        [lblCarGRP setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCarGRP.backgroundColor = [UIColor clearColor];
        lblViewChooseCarGRP.clipsToBounds = YES;
    }
    else if([selectedCar isEqualToString:@"3"]){
        
        // For GoEva GRP Selected Condition
        viewChooseCarGRP.layer.borderWidth = 2.0f;
        viewChooseCarGRP.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCarGRP.textColor = UIColorFromRGB(0xff0000);
        [lblCarGRP setFont:[UIFont systemFontOfSize:12 weight:2]];
        lblViewChooseCarGRP.backgroundColor = UIColorFromRGB(0xffffff);
        lblViewChooseCarGRP.layer.cornerRadius = 8;
        lblViewChooseCarGRP.clipsToBounds = YES;
        
        // For GoEva Normal Condition
        viewChooseCar.layer.borderWidth = 0.0f;
        viewChooseCar.layer.borderColor = [UIColor whiteColor].CGColor;
        lblCar.textColor = UIColorFromRGB(0xffffff);
        [lblCar setFont:[UIFont systemFontOfSize:11]];
        lblViewChooseCar.backgroundColor = [UIColor clearColor];
        lblViewChooseCar.clipsToBounds = YES;
        
        // For GoEvaPro Normal Condition
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


-(void)viewSelectedCar:(UITapGestureRecognizer *)tapRecognizer {
    
    MYTapGestureRecognizer *tap = (MYTapGestureRecognizer *)tapRecognizer;
    //NSLog(@"data : %@", tap.data);
    selectedCarType=tap.data;
    
//    for(GMSMarker *pin in self.googleMapsDriverPins) {
//        NSLog(@"pin :%@ ",pin.userData);
//                if ([pin.userData isEqualToString: tap.data]){
//                    pin.map = nil;
//                }
//    }
    
    for(GMSMarker *pin in self.googleMapsDriverPins) {
        pin.map = nil;
    }
    self.googleMapsDriverPins = nil;
    self.googleMapsDriverPins = [NSMutableArray arrayWithCapacity:carAvailablityArray.count];
    for (CarAvailablity *carObj in carAvailablityArray) {
        pickerMarker = [[GMSMarker alloc] init];
        pickerMarker.appearAnimation=kGMSMarkerAnimationPop;
        pickerMarker.title =@"Car Selected";
        UIView *viewMarker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [viewMarker setBackgroundColor:[UIColor clearColor]];
        UIImageView *imgMarker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_gray_marker"]];
        [imgMarker setFrame:CGRectMake(0, 0, 50, 50)];
        [imgMarker setUserInteractionEnabled:YES];
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                              action:@selector(selectedMarker)];
        [viewMarker addSubview:imgMarker];
        
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 24, 18)];
        [lblTime setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f]];
        lblTime.textAlignment = NSTextAlignmentCenter;
        [lblTime setText:[[[carObj estimated_time] componentsSeparatedByString:@" "] objectAtIndex:0]];
        [viewMarker addSubview:lblTime];
        
        UILabel *lblMin = [[UILabel alloc] initWithFrame:CGRectMake(15, 21, 18, 14)];
        [lblMin setFont:[UIFont systemFontOfSize:7]];
        lblMin.textAlignment = NSTextAlignmentCenter;
        [lblMin setText:@"MIN"];
        [viewMarker addSubview:lblMin];
        
        if ([[carObj car_type_id] isEqualToString:tap.data]) {
            pickerMarker.iconView = viewMarker;
            [pickerMarker setUserData:[carObj availability_id]];
            pickerMarker.position = CLLocationCoordinate2DMake([carObj.online_current_lat floatValue],[carObj.online_current_long floatValue]);
            pickerMarker.map = _mapView;
            [self.googleMapsDriverPins addObject:pickerMarker];
        }
       
    }
    
    [self viewSetup:tap.data];
    
}

- (IBAction)rideNowBtn:(UIButton *)sender{
    
    NSString *awayTime=@"";
    NSString *estimatedFareCostPerMile=@"";
    returnPickupAddressMode=0;
    returnDropAddressMode=0;
    if ([txtDropLocation.text isEqualToString:@""]) {
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow makeToast:@"Please enter dropoff location. "];
        return;
    }
    if ([carAvaialblityID isEqualToString:@""]) {
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow makeToast:@"Please select a car to continue. "];
        return;
    }
    for (CarAvailablity *carObj in carAvailablityArray) {
        if ([[carObj availability_id] isEqualToString:carAvaialblityID]) {
            awayTime= [carObj estimated_time];
            estimatedFareCostPerMile = [carObj distance_wise_rate];
            break;
        }
    }
//    if ([awayTime isEqualToString:@""]) {
//        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
//        [currentWindow makeToast:@"No cab available. pLease try after some time."];
//        return;
//    }
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    PickCarDetail *chooseCar;
    if (appDel.iSiPhone5) {
        chooseCar = [[PickCarDetail alloc] initWithNibName:@"PickCarDetail" bundle:nil];
    }
    else{
        chooseCar = [[PickCarDetail alloc] initWithNibName:@"PickCarDetailLow" bundle:nil];
    }
    chooseCar.availabilityID = carAvaialblityID;
    chooseCar.selectedCar=selectedCarType;
    chooseCar.awayTimeFromCustomer=awayTime;
    chooseCar.estimatedFareCostPerMile = estimatedFareCostPerMile;
    [MyUtils saveCustomObject:pickupLocation key:@"pickupLocation"];
    [MyUtils saveCustomObject:dropLocation key:@"dropLocation"];
    chooseCar.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:chooseCar animated:YES completion:nil];
}


- (void)dealloc {
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        _firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        //NSLog(@"Jasim %f, %f",location.coordinate.latitude,location.coordinate.longitude);
        
        /* Add My location on Map */
        _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:16];
        locationMarker = [[GMSMarker alloc] init];
        locationMarker.appearAnimation=kGMSMarkerAnimationPop;
        UIImage *house = [UIImage imageNamed:@"map_marker"];
        //house = [house imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _londonView = [[UIImageView alloc] initWithImage:house];
        //_londonView.tintColor = [UIColor redColor];
        locationMarker.iconView = _londonView;
        //_londonView.frame = CGRectMake(self.view.frame.origin.x/2, 0, 20, 40);
        //locationMarker.tracksViewChanges = YES;
        locationMarker.position = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
        locationMarker.map = _mapView;
        /* End */
        
        [self reverseGeoCoding:location];
        
    }
}

-(void) reverseGeoCoding : (CLLocation *) location{
    
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        //NSLog(@"reverse geocoding results:");
        
        for(GMSAddress* addressObj in [response results])
        {
            _fromAddressArray=[[NSArray alloc]init];
            _fromAddress=@"";
            //NSLog(@"coordinate.latitude=%f", addressObj.coordinate.latitude);
            //NSLog(@"coordinate.longitude=%f", addressObj.coordinate.longitude);
            userCurrentLat = [NSString stringWithFormat:@"%f",addressObj.coordinate.latitude];
            userCurrentLong = [NSString stringWithFormat:@"%f",addressObj.coordinate.longitude];
            /*NSLog(@"Description=%@",addressObj.description);
            //NSLog(@"address1=%@",addressObj.addressLine1);
            //NSLog(@"address2=%@",addressObj.addressLine2);
            NSLog(@"thoroughfare=%@", addressObj.thoroughfare);
            NSLog(@"locality=%@", addressObj.locality);
            NSLog(@"subLocality=%@", addressObj.subLocality);
            NSLog(@"administrativeArea=%@", addressObj.administrativeArea);
            NSLog(@"postalCode=%@", addressObj.postalCode);
            NSLog(@"country=%@", addressObj.country);
            NSLog(@"lines=%@", addressObj.lines);*/
            _fromAddressArray=addressObj.lines;
            //                for (int i=0; i<_fromAddressArray.count; i++) {
            //                    _fromAddress=[_fromAddress stringByAppendingString:[_fromAddressArray objectAtIndex:i]];
            //                }
            _fromAddress = [_fromAddressArray componentsJoinedByString:@", "];
            txtPickupLocation.text=_fromAddress;
            //NSLog(@"formatted address1=%@", [_fromAddressArray objectAtIndex:0]);
            pickupLocation = [[LocationData alloc] init];
            pickupLocation.locationAddress = [NSString stringWithFormat:@"%@",_fromAddress];
            pickupLocation.latitude = [NSString stringWithFormat:@"%f",addressObj.coordinate.latitude];
            pickupLocation.longitude = [NSString stringWithFormat:@"%f",addressObj.coordinate.longitude];
            
            break;
        }
        
        if([RestCallManager hasConnectivity]){
            
            [self.view setUserInteractionEnabled:NO];
            self.navigationController.navigationBar.userInteractionEnabled = NO;
            self.navigationController.view.userInteractionEnabled = NO;
            [NSThread detachNewThreadSelector:@selector(requestToServer) toTarget:self withObject:nil];
        }
        else{
            UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [loginAlert show];
        }
    }];
    
}
-(void)pickupLocationController{
    //textFieldFromMode=@"1";
    //textFieldToMode=@"0";
    if ([textFieldFromMode isEqualToString:@"1"]) {
        PickupLocation *pickupController;
        if (appDel.iSiPhone5) {
            pickupController = [[PickupLocation alloc] initWithNibName:@"PickupLocation" bundle:nil];
        }
        else{
            pickupController = [[PickupLocation alloc] initWithNibName:@"PickupLocationLow" bundle:nil];
        }
        pickupController.delegate=self;
        pickupController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:pickupController animated:YES completion:nil];
    }
    else{
        textFieldFromMode=@"1";
        textFieldToMode=@"0";
        locationMarker.map  = nil;
        locationMarker = [[GMSMarker alloc] init];
        locationMarker.appearAnimation=kGMSMarkerAnimationPop;
        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
        locationMarker.iconView = _londonView;
        CLLocationCoordinate2D fromLocation = CLLocationCoordinate2DMake([pickupLocation.latitude doubleValue],[pickupLocation.longitude doubleValue]);
        locationMarker.position = fromLocation;
        locationMarker.map = _mapView;
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:fromLocation zoom:16];
        [_mapView animateWithCameraUpdate:updatedCamera];
        
        [self showContactDialog];
        
        viewFrom.layer.masksToBounds = NO;
        viewFrom.layer.shadowColor = [UIColor redColor].CGColor;
        viewFrom.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        viewFrom.layer.shadowOpacity = 1.0f;
        viewFrom.layer.shadowPath = shadowPath.CGPath;
        viewFrom.layer.cornerRadius = 3;
        txtPickupLocation.textColor = [UIColor blackColor];
        txtPickupLocation.font =[UIFont systemFontOfSize:15];
        img_editFrom.hidden=NO;
        markerFrom.frame = CGRectMake(1, 5, 22, 22);
        
        viewTo.layer.masksToBounds = NO;
        viewTo.layer.shadowColor = [UIColor blackColor].CGColor;
        viewTo.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        viewTo.layer.shadowOpacity = 0.5f;
        viewTo.layer.shadowPath = shadowPath2.CGPath;
        viewTo.layer.cornerRadius = 3;
        txtDropLocation.textColor = [UIColor grayColor];
        txtDropLocation.font =[UIFont systemFontOfSize:13];
        img_editTo.hidden=YES;
        markerTo.frame = CGRectMake(4, 8, 18, 18);
    }
}

-(void)dropLocationController{
    
    if ([txtDropLocation.text isEqualToString:@""]) {
        locationMarker.map  = nil;
        textFieldFromMode=@"0";
        textFieldToMode=@"1";
        viewFrom.layer.masksToBounds = NO;
        viewFrom.layer.shadowColor = [UIColor blackColor].CGColor;
        viewFrom.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        viewFrom.layer.shadowOpacity = 0.5f;
        viewFrom.layer.shadowPath = shadowPath.CGPath;
        viewFrom.layer.cornerRadius = 3;
        txtPickupLocation.textColor = [UIColor grayColor];
        txtPickupLocation.font =[UIFont systemFontOfSize:13];
        img_editFrom.hidden=YES;
        markerFrom.frame = CGRectMake(4, 8, 18, 18);
        
        viewTo.layer.masksToBounds = NO;
        viewTo.layer.shadowColor = [UIColor redColor].CGColor;
        viewTo.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        viewTo.layer.shadowOpacity = 1.0f;
        viewTo.layer.shadowPath = shadowPath2.CGPath;
        viewTo.layer.cornerRadius = 3;
        txtDropLocation.textColor = [UIColor blackColor];
        txtDropLocation.font =[UIFont systemFontOfSize:15];
        img_editTo.hidden=NO;
        markerTo.frame = CGRectMake(1, 5, 22, 22);
        
        DropLocation *dropController;
        if (appDel.iSiPhone5) {
            dropController = [[DropLocation alloc] initWithNibName:@"DropLocation" bundle:nil];
        }
        else{
            dropController = [[DropLocation alloc] initWithNibName:@"DropLocationLow" bundle:nil];
        }
        dropController.delegate=self;
        dropController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:dropController animated:YES completion:nil];
        
    }
    else{
        viewFrom.layer.masksToBounds = NO;
        viewFrom.layer.shadowColor = [UIColor blackColor].CGColor;
        viewFrom.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        viewFrom.layer.shadowOpacity = 0.5f;
        viewFrom.layer.shadowPath = shadowPath.CGPath;
        viewFrom.layer.cornerRadius = 3;
        txtPickupLocation.textColor = [UIColor grayColor];
        txtPickupLocation.font =[UIFont systemFontOfSize:13];
        img_editFrom.hidden=YES;
        markerFrom.frame = CGRectMake(4, 8, 18, 18);
        
        viewTo.layer.masksToBounds = NO;
        viewTo.layer.shadowColor = [UIColor redColor].CGColor;
        viewTo.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        viewTo.layer.shadowOpacity = 1.0f;
        viewTo.layer.shadowPath = shadowPath2.CGPath;
        viewTo.layer.cornerRadius = 3;
        txtDropLocation.textColor = [UIColor blackColor];
        txtDropLocation.font =[UIFont systemFontOfSize:15];
        img_editTo.hidden=NO;
        markerTo.frame = CGRectMake(1, 5, 22, 22);
        
        if ([textFieldToMode isEqualToString:@"0"]) {
            locationMarker.map  = nil;
            textFieldFromMode=@"0";
            textFieldToMode=@"1";
            locationMarker = [[GMSMarker alloc] init];
            locationMarker.appearAnimation=kGMSMarkerAnimationPop;
            _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
            locationMarker.iconView = _londonView;
            CLLocationCoordinate2D toLocation = CLLocationCoordinate2DMake([dropLocation.latitude doubleValue],[dropLocation.longitude doubleValue]);
            locationMarker.position = toLocation;
            locationMarker.map = _mapView;
            GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:toLocation zoom:16];
            [_mapView animateWithCameraUpdate:updatedCamera];
        }
        else{
            DropLocation *dropController;
            if (appDel.iSiPhone5) {
                dropController = [[DropLocation alloc] initWithNibName:@"DropLocation" bundle:nil];
            }
            else{
                dropController = [[DropLocation alloc] initWithNibName:@"DropLocationLow" bundle:nil];
            }
            dropController.delegate=self;
            dropController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
            [self presentViewController:dropController animated:YES completion:nil];
        }
        
    }
}

-(void)sendDatafromPickupToDashboard:(GMSPlace *)place
{
    //NSLog(@"recieve Text: %@",place);
    txtPickupLocation.text = [NSString stringWithFormat:@"%@, %@",place.name,place.formattedAddress];
    returnPickupAddressMode=1;
    returnDropAddressMode=0;
    /* Add Pickup Marker*/
    
    pickupLocation =[[LocationData alloc] init];
    pickupLocation.locationAddress = [NSString stringWithFormat:@"%@, %@",place.name,place.formattedAddress];
    pickupLocation.latitude = [NSString stringWithFormat:@"%f",place.coordinate.latitude];
    pickupLocation.longitude = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    userCurrentLat = [NSString stringWithFormat:@"%f",place.coordinate.latitude];
    userCurrentLong = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    if([RestCallManager hasConnectivity]){
        
        [self.view setUserInteractionEnabled:NO];
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        self.navigationController.view.userInteractionEnabled = NO;
        [NSThread detachNewThreadSelector:@selector(requestToServer) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)sendDatafromDropToDashboard:(GMSPlace *)place
{
    //NSLog(@"recieve Text: %@",place);
    txtDropLocation.text = [NSString stringWithFormat:@"%@, %@",place.name,place.formattedAddress];
    returnPickupAddressMode=0;
    returnDropAddressMode=1;
    dropLocation =[[LocationData alloc] init];
    dropLocation.locationAddress = [NSString stringWithFormat:@"%@, %@",place.name,place.formattedAddress];
    dropLocation.latitude = [NSString stringWithFormat:@"%f",place.coordinate.latitude];
    dropLocation.longitude = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
}


- (BOOL) didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
    CLLocation *myLocation = mapView.myLocation;
    //NSLog(@"%f %f", myLocation.coordinate.latitude,myLocation.coordinate.longitude);
    /* Add My location on Map */
    textFieldFromMode=@"1";
    textFieldToMode=@"0";
    locationMarker.map  = nil;
    locationMarker = [[GMSMarker alloc] init];
    locationMarker.appearAnimation=kGMSMarkerAnimationPop;
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    locationMarker.iconView = _londonView;
    locationMarker.position = CLLocationCoordinate2DMake(myLocation.coordinate.latitude,myLocation.coordinate.longitude);
    locationMarker.map = _mapView;
    /* End */
    
    viewFrom.layer.masksToBounds = NO;
    viewFrom.layer.shadowColor = [UIColor redColor].CGColor;
    viewFrom.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    viewFrom.layer.shadowOpacity = 1.0f;
    viewFrom.layer.shadowPath = shadowPath.CGPath;
    viewFrom.layer.cornerRadius = 3;
    txtPickupLocation.textColor = [UIColor blackColor];
    txtPickupLocation.font =[UIFont systemFontOfSize:15];
    img_editFrom.hidden=NO;
    markerFrom.frame = CGRectMake(1, 5, 22, 22);
    
    viewTo.layer.masksToBounds = NO;
    viewTo.layer.shadowColor = [UIColor blackColor].CGColor;
    viewTo.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    viewTo.layer.shadowOpacity = 0.5f;
    viewTo.layer.shadowPath = shadowPath2.CGPath;
    viewTo.layer.cornerRadius = 3;
    txtDropLocation.textColor = [UIColor grayColor];
    txtDropLocation.font =[UIFont systemFontOfSize:13];
    img_editTo.hidden=YES;
    markerTo.frame = CGRectMake(4, 8, 18, 18);
    
    [self reverseGeoCoding:myLocation];
    return NO;
}

-(void)requestToServer{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] getNearestCar:userCurrentLat currentLong:userCurrentLong carTypeID:@""  pickCar:@"1"];
    
    if(bSuccess)
    {
        carAvailablityArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getAllCarAvailablity]];
        if([carAvailablityArray count]>0){
            [self performSelectorOnMainThread:@selector(showContactDialog) withObject:nil waitUntilDone:YES];
        }
        else{
            [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
        }
    }
    else{
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(void)showContactDialog{
    
    [self.view setUserInteractionEnabled:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    carAvailablityArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getAllCarAvailablity]];
    
    for(GMSMarker *pin in self.googleMapsDriverPins) {
        pin.map = nil;
    }
    self.googleMapsDriverPins = nil;
    self.googleMapsDriverPins = [NSMutableArray arrayWithCapacity:carAvailablityArray.count];
    for (CarAvailablity *carObj in carAvailablityArray) {
        pickerMarker = [[GMSMarker alloc] init];
        pickerMarker.appearAnimation=kGMSMarkerAnimationPop;
        pickerMarker.title =@"Car Selected";
        UIView *viewMarker = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [viewMarker setBackgroundColor:[UIColor clearColor]];
        UIImageView *imgMarker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_gray_marker"]];
        [imgMarker setFrame:CGRectMake(0, 0, 50, 50)];
        [viewMarker addSubview:imgMarker];
        
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(12, 7, 24, 18)];
        [lblTime setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f]];
        lblTime.textAlignment = NSTextAlignmentCenter;
        [lblTime setText:[[[carObj estimated_time] componentsSeparatedByString:@" "] objectAtIndex:0]];
        [viewMarker addSubview:lblTime];
        
        UILabel *lblMin = [[UILabel alloc] initWithFrame:CGRectMake(15, 21, 18, 14)];
        [lblMin setFont:[UIFont systemFontOfSize:7]];
        lblMin.textAlignment = NSTextAlignmentCenter;
        [lblMin setText:@"MIN"];
        [viewMarker addSubview:lblMin];
        
        if ([[carObj car_type_id] isEqualToString:@"1"]) {
            
            //[imgMarker setImage:[UIImage imageNamed:@"ic_gray_marker"]];
        }
        else if ([[carObj car_type_id] isEqualToString:@"2"]) {
            
            //[imgMarker setImage:[UIImage imageNamed:@"ic_gray_marker"]];
        }
        else if ([[carObj car_type_id] isEqualToString:@"3"]) {
            
            //[imgMarker setImage:[UIImage imageNamed:@"ic_gray_marker"]];
        }
        pickerMarker.iconView = viewMarker;
        [pickerMarker setUserData:[carObj availability_id]];
        pickerMarker.position = CLLocationCoordinate2DMake([carObj.online_current_lat floatValue],[carObj.online_current_long floatValue]);
        pickerMarker.map = _mapView;
        [self.googleMapsDriverPins addObject:pickerMarker];
    }
    
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    //NSLog(@"%@",marker.userData);
    carAvaialblityID = marker.userData;
    return NO;
}

-(void)noCarFound{
    [self.view setUserInteractionEnabled:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
}


- (IBAction)backToHomePage:(id)sender {
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];
//    [UIView commitAnimations];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [DashboardCaller homepageSelector:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
