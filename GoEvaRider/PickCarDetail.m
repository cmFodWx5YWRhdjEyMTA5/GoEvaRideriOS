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
#import <Stripe/Stripe.h>
#import "CardMaster.h"
#import <AFNetworking/AFNetworking.h>
#import "Payment.h"
#import "AddCard.h"
#import "Constant.h"
#import "GlobalVariable.h"

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
    NSTimer *timerForCheckBooking;
    int checkLoop;
    int j;
    AVAudioPlayer *player;
    NSArray *cardBrand; 
}

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    viewChooseCar.layer.cornerRadius = viewChooseCar.frame.size.width / 2;
    viewChooseCar.clipsToBounds = YES;
    
    j=0;
    
   /* [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForBookConfirmation:) name:@"pushNotificationForBookConfirmation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationForNoCabFound:) name:@"pushNotificationForNoCabFound" object:nil];*/
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
            
            timer = [NSTimer scheduledTimerWithTimeInterval:0.003 repeats:false block:^(NSTimer * _Nonnull timer) {
                [self animate:path];
            }];
        }
        @catch (NSException * e) {
            //NSLog(@"Exception: %@", e);
//            UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Oops!!!" message:@"There is no any routes available. Please choose another drop location." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [loginAlert show];
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

/*- (void) pushNotificationForBookConfirmation:(NSNotification *)notification{
    
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
    
}*/

/*- (void) pushNotificationForNoCabFound:(NSNotification *)notification{
    
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
    
}*/

- (IBAction)confirmBooking:(id)sender {
  
    if([RestCallManager hasConnectivity]){
        
        [timer invalidate];
        timer = nil;
        
        [loadingView setHidden:NO];
        [self.view setUserInteractionEnabled:NO];
        self.navigationController.navigationBar.userInteractionEnabled = NO;
        self.navigationController.view.userInteractionEnabled = NO;
        timerForCheckBooking = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                                target:self selector:@selector(checkingBooingRequest:) userInfo:nil repeats:YES];
        [NSThread detachNewThreadSelector:@selector(requestToServer) toTarget:self withObject:nil];
    }
    else{
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"Please make sure you phone is coneccted to the internet to use GoEva app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
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


-(void)requestToServer{
    
    BOOL bSuccess;
    bSuccess =  [[RestCallManager sharedInstance] requestBooking:[MyUtils getUserDefault:@"riderID"] availabilityID:self.availabilityID carTypeID:self.selectedCar pickupLocation:pickupLocation.locationAddress dropLocation:dropLocation.locationAddress sourceLat:pickupLocation.latitude sourceLong:pickupLocation.longitude descLat:dropLocation.latitude descLong:dropLocation.longitude pickCar:@"1"];
    
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
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry, selected GoEva ride not available. Please choose another one." message:@"" preferredStyle:UIAlertControllerStyleAlert];
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
    
    [MyUtils setUserDefault:@"bookingID" value:[GlobalVariable getBookingID]];
    
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
