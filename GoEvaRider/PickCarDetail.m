//
//  PickCarDetail.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 10/12/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "PickCarDetail.h"
#import "AfterBooking.h"
#import "Dashboard.h"
#import "MYTapGestureRecognizer.h"
#import "MyUtils.h"
#import "RestCallManager.h"
#import "DataStore.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PickCarDetail ()

@end

@implementation PickCarDetail{
    GMSMapView *_mapView;
    GMSMarker *pickupMarker;
    GMSMarker *dropMarker;
    UIView *_londonView;
    NSTimer *timer;
    int j;
    AVAudioPlayer *player;
}

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    loadingView = [MyUtils customLoaderFullWindowWithText:self.window loadingText:@"REQUESTING..."];
    [self.view addSubview:loadingView];
    [loadingView setHidden:YES];
    
    viewChooseCar.layer.cornerRadius = viewChooseCar.frame.size.width / 2;
    viewChooseCar.clipsToBounds = YES;
    
    j=0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForBookConfirmation:) name:@"pushNotificationForBookConfirmation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForNoCabFound:) name:@"pushNotificationForNoCabFound" object:nil];
    _arrayPolylineGreen = [[NSMutableArray alloc] init];
    _path2 = [[GMSMutablePath alloc]init];
    
    pickupLocation = [MyUtils loadCustomObjectWithKey:@"pickupLocation"];
    dropLocation = [MyUtils loadCustomObjectWithKey:@"dropLocation"];
    [lblPickupLocation setText:[NSString stringWithFormat:@"%@",pickupLocation.locationAddress]];
    [lblDropLocation setText:[NSString stringWithFormat:@"%@",dropLocation.locationAddress]];
    [lblAwayTime setText:[NSString stringWithFormat:@"%@ Away",self.awayTimeFromCustomer]];
    if([self.estimatedFareCostPerMile isEqual:[NSNull null]])
        lblPricePerMile.hidden=YES;
    else
    [lblPricePerMile setText:[NSString stringWithFormat:@"$%@ / Miles",self.estimatedFareCostPerMile]];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:22.619160
                                                            longitude:88.398099
                                                                 zoom:12];
    _mapView = [GMSMapView mapWithFrame:_mapViewContainer.bounds camera:camera];
    _mapView.settings.compassButton = YES;
    _mapView.settings.myLocationButton = NO;
    [_mapViewContainer addSubview:_mapView];
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        _mapView.myLocationEnabled = YES;
    });
    
    pickupMarker = [[GMSMarker alloc] init];
    pickupMarker.title = @"Pickup Location";
    pickupMarker.snippet = pickupLocation.locationAddress;
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    [_londonView setFrame:CGRectMake(0, 0, 15, 30)];
    pickupMarker.iconView = _londonView;
    pickupMarker.position = CLLocationCoordinate2DMake([pickupLocation.latitude floatValue],[pickupLocation.longitude floatValue]);
    
    pickupMarker.map = _mapView;
    
    
    dropMarker = [[GMSMarker alloc] init];
    dropMarker.title = @"Drop Location";
    dropMarker.snippet = dropLocation.locationAddress;
    _londonView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_marker"]];
    [_londonView setFrame:CGRectMake(0, 0, 15, 30)];
    dropMarker.iconView = _londonView;
    dropMarker.position = CLLocationCoordinate2DMake([dropLocation.latitude floatValue],[dropLocation.longitude floatValue]);
    
    dropMarker.map = _mapView;
    
    [self createPolyLine];
}

-(void)createPolyLine{
    
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           [pickupLocation.latitude floatValue],
                           [pickupLocation.longitude floatValue],
                           [dropLocation.latitude floatValue],
                           [dropLocation.longitude floatValue],
                           @"AIzaSyAYHNZXoW6fkpTGvh0aGjqbXIp2ulzjTmw"];
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
            
            timer = [NSTimer scheduledTimerWithTimeInterval:0.003 repeats:true block:^(NSTimer * _Nonnull timer) {
                [self animate:path];
            }];
        }
        @catch (NSException * e) {
            //NSLog(@"Exception: %@", e);
            UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"There is no any routes available. Please choose another drop location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [loginAlert show];
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

- (void) pushNotificationForBookConfirmation:(NSNotification *)notification{
    
    [timer invalidate];
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
    
}

- (void) pushNotificationForNoCabFound:(NSNotification *)notification{
    
    NSDictionary *dict = [notification userInfo];
    NSDictionary *notificationDict= [dict valueForKey:@"aps"];
    [self.view setUserInteractionEnabled:YES];
    [loadingView setHidden:YES];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No cab found. Please try again." message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        [timer invalidate];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView commitAnimations];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (IBAction)confirmBooking:(id)sender {
  
    if([RestCallManager hasConnectivity]){
        
        [timer invalidate];
        timer = nil;
        
        [loadingView setHidden:NO];
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


-(void)requestToServer{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] requestBooking:[MyUtils getUserDefault:@"riderID"] availabilityID:self.availabilityID carTypeID:self.selectedCar pickupLocation:pickupLocation.locationAddress dropLocation:dropLocation.locationAddress sourceLat:pickupLocation.latitude sourceLong:pickupLocation.longitude descLat:dropLocation.latitude descLong:dropLocation.longitude pickCar:@"1"];
    
    if(bSuccess)
    {
        [self performSelectorOnMainThread:@selector(showContactDialog) withObject:nil waitUntilDone:YES];
    }
    else{
        // Do Something
    }
}

-(void)showContactDialog{
    
    //
}


- (IBAction)backToPickCarPage:(id)sender {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView commitAnimations];
    [self dismissViewControllerAnimated:YES completion:nil];
    [timer invalidate];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
