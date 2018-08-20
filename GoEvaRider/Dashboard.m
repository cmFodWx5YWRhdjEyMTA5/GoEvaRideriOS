//
//  Dashboard.m
//  GoEvaRider
//

#import "Dashboard.h"
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
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "GlobalVariable.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface Dashboard ()

@end

@implementation Dashboard{
    GMSMapView *_mapView;
    BOOL _firstLocationUpdate;
    GMSMarker *locationMarker;
    UIImageView *_londonView;
    AVAudioPlayer *player;
    CLLocation *userCurrentLocation;
    NSTimer *sec10Timer;
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
    
    viewBadge1.layer.cornerRadius = viewBadge1.frame.size.width / 2;
    viewBadge1.clipsToBounds = YES;
    viewBadge2.layer.cornerRadius = viewBadge2.frame.size.width / 2;
    viewBadge2.clipsToBounds = YES;
    viewBadge3.layer.cornerRadius = viewBadge3.frame.size.width / 2;
    viewBadge3.clipsToBounds = YES;
    
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
    //modeForViewControllerDismiss=@"0"; // 0 => Location track in mapView 1=> not Track
    
    loaderImg1.image=[UIImage animatedImageNamed:@"loading_" duration:1.0f];
    loaderImg2.image=[UIImage animatedImageNamed:@"loading_" duration:1.0f];
    loaderImg3.image=[UIImage animatedImageNamed:@"loading_" duration:1.0f];
    [lblTime1 setHidden:YES];
    [lblTime2 setHidden:YES];
    [lblTime3 setHidden:YES];
    
    [lblBadge1 setText:@"0"];
    [lblBadge2 setText:@"0"];
    [lblBadge3 setText:@"0"];
    returnPickupAddressMode=0;
    
//    NSDate *dateToFire = [[NSDate date] dateByAddingTimeInterval:30*60];
//    //To get date in  `hour:minute` format.
//    NSDateFormatter *dateFormatterHHMM=[NSDateFormatter new];
//    [dateFormatterHHMM setDateFormat:@"hh:mm a"];
//    NSString *timeString=[dateFormatterHHMM stringFromDate:dateToFire];
//    NSLog(@"Current Time: %@", timeString);
    
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
    
    inputViewContainer.frame = CGRectMake(10, 490, 300, 135);
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         if (appDel.iSiPhone5) {
                             inputViewContainer.frame = CGRectMake(10, 25, 299, 135);
                         }
                         else{
                             inputViewContainer.frame = CGRectMake(10, 10, 299, 135);
                         }
                     }
                     completion:^(BOOL finished){
                     }];
    [self.view addSubview:inputViewContainer];
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:inputViewContainer.bounds];
    
    inputViewContainer.layer.masksToBounds = NO;
    inputViewContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    inputViewContainer.layer.shadowOffset = CGSizeMake(0.0f, 1.5f);
    inputViewContainer.layer.shadowOpacity = 0.5f;
    inputViewContainer.layer.shadowPath = shadowPath3.CGPath;
    inputViewContainer.layer.cornerRadius = 10;
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:39.50
                                                            longitude:-98.35
                                                                 zoom:15];
    
    _mapView = [GMSMapView mapWithFrame:_mapViewContainer.bounds camera:camera];
    _mapView.delegate=self;
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.padding = UIEdgeInsetsMake(80, 0, 20, 0);
    
    [_mapViewContainer addSubview:_mapView];
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        _mapView.myLocationEnabled = YES;
        
    });
    _firstLocationUpdate = NO;
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
    lblTitle.text = @"Home";
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
    
    
    //
    //
    // Listen to the myLocation property of GMSMapView.
    [_mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    if (returnPickupAddressMode==1) {
//        _firstLocationUpdate = YES;// For no update in map
//        locationMarker.map  = nil;
//        locationMarker = [[GMSMarker alloc] init];
//        locationMarker.appearAnimation=kGMSMarkerAnimationPop;
//        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
//        locationMarker.iconView = _londonView;
//        CLLocationCoordinate2D fromLocation = CLLocationCoordinate2DMake([pickupLocation.latitude doubleValue],[pickupLocation.longitude doubleValue]);
//        locationMarker.position = fromLocation;
//        locationMarker.map = _mapView;
//        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:fromLocation zoom:15];
//        [_mapView animateWithCameraUpdate:updatedCamera];
    }
    if (returnDropAddressMode==1) {
//        _firstLocationUpdate = YES;// For no update in map
//        locationMarker.map  = nil;
//        locationMarker = [[GMSMarker alloc] init];
//        locationMarker.appearAnimation=kGMSMarkerAnimationPop;
//        _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
//        locationMarker.iconView = _londonView;
//        CLLocationCoordinate2D toLocation = CLLocationCoordinate2DMake([dropLocation.latitude doubleValue],[dropLocation.longitude doubleValue]);
//        locationMarker.position = toLocation;
//        locationMarker.map = _mapView;
//        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:toLocation zoom:15];
//        [_mapView animateWithCameraUpdate:updatedCamera];
    }
    if (!sec10Timer) {
    sec10Timer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                  target:self selector:@selector(timeIntervalFor10Sec:) userInfo:nil repeats:YES];
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
    [self viewSetup:tap.data];
    
}

- (IBAction)rideNowBtn:(UIButton *)sender{
    
    
    
        if ([txtDropLocation.text isEqualToString:@""]) {
            UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
            [currentWindow makeToast:@"Please enter dropoff location. "];
            return;
        }
        if ([selectedCarType isEqualToString:@""]) {
                UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
                [currentWindow makeToast:@"Please choose a ride to continue."];
                return;
        }
    
    
    if([RestCallManager hasConnectivity]){
        loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Loading..."];
        [self.view addSubview:loadingView];
        [self.view setUserInteractionEnabled:NO];
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        self.navigationController.view.userInteractionEnabled = NO;
        [NSThread detachNewThreadSelector:@selector(requestToServerCheckDistanceRange) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [loginAlert show];
    }
}

-(void)requestToServerCheckDistanceRange{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] check_distance_range:[MyUtils getUserDefault:@"riderID"] sourceLat:pickupLocation.latitude sourceLong:pickupLocation.longitude descLat:dropLocation.latitude descLong:dropLocation.longitude];
    
    if(bSuccess)
    {
            [self performSelectorOnMainThread:@selector(goToChooseCar) withObject:nil waitUntilDone:YES];
    }
    else{
        
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //            [self.view setUserInteractionEnabled:YES];
        //            self.navigationController.navigationBar.userInteractionEnabled = YES;
        //            self.navigationController.view.userInteractionEnabled = YES;
        //        });
        [self performSelectorOnMainThread:@selector(outOfDistanceRange) withObject:nil waitUntilDone:YES];
    }
}

-(void)goToChooseCar{
    
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    
    NSString *awayTime=@"";
    NSString *estimatedFareCostPerMile=@"";
    returnPickupAddressMode=0;
    if ([sec10Timer isValid]) {
        [sec10Timer invalidate];
    }
    sec10Timer = nil;
    
    for (CarAvailablity *carObj in carAvailablityArray) {
        if ([[carObj car_type_id] isEqualToString:selectedCarType]) {
            //[lblTime1 setText:[carObj estimated_time]];
            awayTime= [carObj estimated_time];
            estimatedFareCostPerMile = [carObj distance_wise_rate];
            break;
        }
    }
    if ([awayTime isEqualToString:@""]) {
        UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
        [currentWindow makeToast:@"No cars available, please try again in a few mins."];
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    ChooseCar *chooseCar;
    if (appDel.iSiPhone5) {
        chooseCar = [[ChooseCar alloc] initWithNibName:@"ChooseCar" bundle:nil];
    }
    else{
        chooseCar = [[ChooseCar alloc] initWithNibName:@"ChooseCarLow" bundle:nil];
    }
    chooseCar.selectedCar=selectedCarType;
    chooseCar.awayTimeFromCustomer=awayTime;
    chooseCar.estimatedFareCostPerMile = estimatedFareCostPerMile;
    [MyUtils saveCustomObject:pickupLocation key:@"pickupLocation"];
    [MyUtils saveCustomObject:dropLocation key:@"dropLocation"];
    chooseCar.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:chooseCar animated:YES completion:nil];
    
}


/*- (void)dealloc {
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}*/

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    userCurrentLocation = [change objectForKey:NSKeyValueChangeNewKey];
    NSLog(@"Jasim %f, %f",userCurrentLocation.coordinate.latitude,userCurrentLocation.coordinate.longitude);
    
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        _firstLocationUpdate = YES;

        /* Add My location on Map */
        locationMarker.map  = nil;
        _mapView.camera = [GMSCameraPosition cameraWithTarget:userCurrentLocation.coordinate
                                                         zoom:15];
        locationMarker = [[GMSMarker alloc] init];
        locationMarker.appearAnimation=kGMSMarkerAnimationPop;
        UIImage *house = [UIImage imageNamed:@"map_marker"];
        //house = [house imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _londonView = [[UIImageView alloc] initWithImage:house];
        //_londonView.tintColor = [UIColor redColor];
        locationMarker.iconView = _londonView;
        //_londonView.frame = CGRectMake(self.view.frame.origin.x/2, 0, 20, 40);
        //locationMarker.tracksViewChanges = YES;
        locationMarker.position = CLLocationCoordinate2DMake(userCurrentLocation.coordinate.latitude,userCurrentLocation.coordinate.longitude);
        locationMarker.map = _mapView; // this is a memory leak. please fix it
        /* End */

        [self reverseGeoCoding:userCurrentLocation];

    }
}

-(void)timeIntervalFor10Sec:(NSTimer *)timer{
    CLLocation *fromLocation;
    if (returnPickupAddressMode==1) {
        fromLocation = [[CLLocation alloc] initWithLatitude:[pickupLocation.latitude doubleValue] longitude:[pickupLocation.longitude doubleValue]];
    }
    else{
        fromLocation = userCurrentLocation;
    }
    [self reverseGeoCoding:fromLocation];
}

-(void) reverseGeoCoding : (CLLocation *) currentLocation{
    
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude) completionHandler:^(GMSReverseGeocodeResponse* response, NSError* error) {
        //NSLog(@"reverse geocoding results:");
        if(error==nil){
            for(GMSAddress* addressObj in [response results])
            {
                _fromAddressArray=[[NSArray alloc]init];
                _fromAddress=@"";
                //NSLog(@"coordinate.latitude=%f", addressObj.coordinate.latitude);
                //NSLog(@"coordinate.longitude=%f", addressObj.coordinate.longitude);
                userCurrentLat = [NSString stringWithFormat:@"%f",addressObj.coordinate.latitude];
                userCurrentLong = [NSString stringWithFormat:@"%f",addressObj.coordinate.longitude];
                //NSLog(@"Description=%@",addressObj.description);
                //NSLog(@"address1=%@",addressObj.addressLine1);
                //NSLog(@"address2=%@",addressObj.addressLine2);
                //NSLog(@"thoroughfare=%@", addressObj.thoroughfare);
                //NSLog(@"locality=%@", addressObj.locality);
                //NSLog(@"subLocality=%@", addressObj.subLocality);
                //NSLog(@"administrativeArea=%@", addressObj.administrativeArea);
                //NSLog(@"postalCode=%@", addressObj.postalCode);
                //NSLog(@"country=%@", addressObj.country);
                //NSLog(@"lines=%@", addressObj.lines);
                _fromAddressArray=addressObj.lines;
                //                for (int i=0; i<_fromAddressArray.count; i++) {
                //                    _fromAddress=[_fromAddress stringByAppendingString:[_fromAddressArray objectAtIndex:i]];
                //                }
                _fromAddress = [_fromAddressArray componentsJoinedByString:@", "];
                if (returnPickupAddressMode==0) {
                    txtPickupLocation.text=_fromAddress;
                }
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
                [loaderImg1 setHidden:NO];
                [lblTime1 setHidden:YES];
                [loaderImg2 setHidden:NO];
                [lblTime2 setHidden:YES];
                [loaderImg3 setHidden:NO];
                [lblTime3 setHidden:YES];
                [NSThread detachNewThreadSelector:@selector(requestToServer) toTarget:self withObject:nil];
            }
            else{
                UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [loginAlert show];
            }
        }
        else{
            txtPickupLocation.text = @"Unkonwn Address...";
        }
    }];
    
}


-(void)pickupLocationController{
    //textFieldFromMode=@"1";
    //textFieldToMode=@"0";
    if ([textFieldFromMode isEqualToString:@"1"]) {
        if ([sec10Timer isValid]) {
            [sec10Timer invalidate];
        }
        sec10Timer = nil;
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
        GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:fromLocation zoom:15];
        [_mapView animateWithCameraUpdate:updatedCamera];
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
            GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:toLocation zoom:15];
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
    NSLog(@"Pickup: %@",txtPickupLocation.text);
    NSLog(@"Drop: %@",txtDropLocation.text);
    txtPickupLocation.text = [NSString stringWithFormat:@"%@, %@",place.name,place.formattedAddress];
//    if (![txtPickupLocation.text isEqualToString:@""] && ![txtDropLocation.text isEqualToString:@""]) {
//        CLLocationCoordinate2D coordTo = {.latitude = [dropLocation.latitude doubleValue], .longitude = [dropLocation.longitude doubleValue]};
//        NSNumber *distanceBetweenFromTo =[MyUtils calculateDistanceInMetersBetweenCoord:place.coordinate coord:coordTo];
//        if ([distanceBetweenFromTo doubleValue]>100000) { // For 100 Km
//            txtPickupLocation.text = @"";
//
//            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"It seems that you are outside of the distance range. Please choose another location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [errorAlert show];
//
//            return;
//        }
//    }
    
    btnRideNow.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnRideNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRideNow.userInteractionEnabled=YES;
    
    
    returnPickupAddressMode=1;
    
    pickupLocation =[[LocationData alloc] init];
    pickupLocation.locationAddress = [NSString stringWithFormat:@"%@, %@",place.name,place.formattedAddress];
    pickupLocation.latitude = [NSString stringWithFormat:@"%f",place.coordinate.latitude];
    pickupLocation.longitude = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    userCurrentLat = [NSString stringWithFormat:@"%f",place.coordinate.latitude];
    userCurrentLong = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    
    
    
    _firstLocationUpdate = YES;
    locationMarker.map  = nil;
    locationMarker = [[GMSMarker alloc] init];
    locationMarker.appearAnimation=kGMSMarkerAnimationPop;
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    locationMarker.iconView = _londonView;
    CLLocationCoordinate2D fromLocation = CLLocationCoordinate2DMake([pickupLocation.latitude doubleValue],[pickupLocation.longitude doubleValue]);
    locationMarker.position = fromLocation;
    locationMarker.map = _mapView;
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:fromLocation zoom:15];
    [_mapView animateWithCameraUpdate:updatedCamera];
    
    
    
    
    
    if([RestCallManager hasConnectivity]){
        
        [self.view setUserInteractionEnabled:NO];
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        self.navigationController.view.userInteractionEnabled = NO;
        [loaderImg1 setHidden:NO];
        [lblTime1 setHidden:YES];
        [loaderImg2 setHidden:NO];
        [lblTime2 setHidden:YES];
        [loaderImg3 setHidden:NO];
        [lblTime3 setHidden:YES];
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
//    if (![txtPickupLocation.text isEqualToString:@""] && ![txtDropLocation.text isEqualToString:@""]) {
//        CLLocationCoordinate2D coordFrom = {.latitude = [pickupLocation.latitude doubleValue], .longitude = [pickupLocation.longitude doubleValue]};
//        NSNumber *distanceBetweenFromTo =[MyUtils calculateDistanceInMetersBetweenCoord:coordFrom coord:place.coordinate];
//        if ([distanceBetweenFromTo doubleValue]>100000) { // For 100 Km
//            txtDropLocation.text = @"";
//
//            UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"It seems that you are outside of the distance range. Please choose another location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [errorAlert show];
//            return;
//        }
//    }
    
    btnRideNow.backgroundColor = UIColorFromRGB(0xC0392B);
    [btnRideNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnRideNow.userInteractionEnabled=YES;
    
    
    dropLocation =[[LocationData alloc] init];
    dropLocation.locationAddress = [NSString stringWithFormat:@"%@, %@",place.name,place.formattedAddress];
    dropLocation.latitude = [NSString stringWithFormat:@"%f",place.coordinate.latitude];
    dropLocation.longitude = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    
    _firstLocationUpdate = YES;// For no update in map
    locationMarker.map  = nil;
    locationMarker = [[GMSMarker alloc] init];
    locationMarker.appearAnimation=kGMSMarkerAnimationPop;
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    locationMarker.iconView = _londonView;
    CLLocationCoordinate2D toLocation = CLLocationCoordinate2DMake([dropLocation.latitude doubleValue],[dropLocation.longitude doubleValue]);
    locationMarker.position = toLocation;
    locationMarker.map = _mapView;
    
//    GMSCameraPosition *cameraPosition = [GMSCameraPosition cameraWithLatitude:[dropLocation.latitude doubleValue]
//                                                                    longitude:[dropLocation.longitude doubleValue]
//                                                                         zoom:15.0];
//    
//    [_mapView animateToCameraPosition:cameraPosition];
    
    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:toLocation zoom:15];
    [_mapView animateWithCameraUpdate:updatedCamera];
    
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
    returnPickupAddressMode=0;// For get the current location that will reflect on timer 10 sec
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
    bSuccess =  [[RestCallManager sharedInstance] getNearestCar:userCurrentLat currentLong:userCurrentLong carTypeID:@""  pickCar:@"0"];
    
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
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.view setUserInteractionEnabled:YES];
//            self.navigationController.navigationBar.userInteractionEnabled = YES;
//            self.navigationController.view.userInteractionEnabled = YES;
//        });
        [self performSelectorOnMainThread:@selector(noCarFound) withObject:nil waitUntilDone:YES];
    }
}

-(void)showContactDialog{
    
    /* loaderImg.animationImages = [NSArray arrayWithObjects:
     [UIImage imageNamed:@"loading_1.png"],
     [UIImage imageNamed:@"loading_2.png"],
     [UIImage imageNamed:@"loading_3.png"],
     nil];
     loaderImg.animationDuration = 1.0f;
     loaderImg.animationRepeatCount = 3;
     [loaderImg startAnimating];*/
    [self.view setUserInteractionEnabled:YES];
    [loadingView removeFromSuperview];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    carAvailablityArray=[NSMutableArray arrayWithArray: [[DataStore sharedInstance] getAllCarAvailablity]];
    
    for (CarAvailablity *carObj in carAvailablityArray) {
        if ([[carObj car_type_id] isEqualToString:@"1"]) {
            if ([carObj estimated_time] == (id)[NSNull null]) {
                [loaderImg1 setHidden:NO];
            }else{
                [loaderImg1 setHidden:YES];
                [lblTime1 setHidden:NO];
                [lblTime1 setText:[carObj estimated_time]];
                [lblBadge1 setText:[carObj count_avacar]];
            }
        }
        else if ([[carObj car_type_id] isEqualToString:@"2"]) {
            if ([carObj estimated_time] == (id)[NSNull null]) {
                [loaderImg2 setHidden:NO];
            }else{
                [loaderImg2 setHidden:YES];
                [lblTime2 setHidden:NO];
                [lblTime2 setText:[carObj estimated_time]];
                [lblBadge2 setText:[carObj count_avacar]];
            }
            
        }
        else if ([[carObj car_type_id] isEqualToString:@"3"]) {
            if ([carObj estimated_time] == (id)[NSNull null]) {
                [loaderImg3 setHidden:NO];
            }
            else{
                [loaderImg3 setHidden:YES];
                [lblTime3 setHidden:NO];
                [lblTime3 setText:[carObj estimated_time]];
                [lblBadge3 setText:[carObj count_avacar]];
            }
        }
    }
      
}

-(void)noCarFound{
    
    [self.view setUserInteractionEnabled:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    [loaderImg1 setHidden:NO];
    [lblTime1 setHidden:YES];
    [loaderImg2 setHidden:NO];
    [lblTime2 setHidden:YES];
    [loaderImg3 setHidden:NO];
    [lblTime3 setHidden:YES];
    
    [lblBadge1 setText:@"0"];
    [lblBadge2 setText:@"0"];
    [lblBadge3 setText:@"0"];
}

-(void)outOfDistanceRange{
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.view.userInteractionEnabled = YES;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!!!" message:[GlobalVariable getGlobalMessage] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"CHANGE DROP" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
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
    }];
    
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
