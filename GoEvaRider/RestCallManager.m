//
//  RestCallManager.m
//  EditFX
//
//  Created by Kalyan Mohan Paul on 4/27/16.
//  Copyright © 2016 Infologic. All rights reserved.
//


#import "RestCallManager.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "DataStore.h"
#import "WebServiceResponse.h"
#import "GlobalVariable.h"



@implementation RestCallManager

#pragma mark Singleton Methods

+ (id)sharedInstance {
    static RestCallManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
- (id)init {
    self = [super init];
    if ( self )
    {
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}


#pragma mark rechability test

-(NSString *)getBaseUrl
{
    return @"http://goeva.co/goevaapp/webservice/";
    //return @"http://goeva.co/goevaapp/webservice-beta/";
}


/*
 Connectivity testing code pulled from Apple's Reachability Example: http://developer.apple.com/library/ios/#samplecode/Reachability
 */
+(BOOL)hasConnectivity {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

#pragma mark restcall Methods

-(WebServiceResponse *)getCallWithUrl:(NSString *) FeedURL
{
    // NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:FeedURL]];
    WebServiceResponse *webresponse=nil ;
    if(RestCallManager.hasConnectivity)
    {
        
        //NSLog(@"url is :%@",FeedURL);
        
        NSURL * url= [NSURL URLWithString:FeedURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        NSURLResponse *resp = nil;
        NSError *err = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest: request returningResponse: &resp error: &err];
        
        if(response != nil)
        {
            //NSString * theString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            //NSLog(@"response: %@", theString);
            
            NSError *error = nil;
            NSDictionary *webResponsedict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            
            webresponse = [[WebServiceResponse alloc] initWithJsonData:webResponsedict];
        }
        // return webresponse;
    }else{
        //        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"No internet connection available. Please check internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //        [loginAlert show];
        //        return nil;
        webresponse = [[WebServiceResponse alloc] init];
        webresponse.Data = @"Connect to the Internet to use GoEva";
        webresponse.StatusCode=@"-200";
    }
    
    return webresponse;
}

-(WebServiceResponse *)postCallWithUrl:(NSString *)url postJsonString:(NSString *) jsonData
{
    WebServiceResponse *webresponse=nil;
    if(RestCallManager.hasConnectivity)
    {
        //NSLog(@"Requesting url is %@", url);
        
        NSURL *FeedUrl = [NSURL URLWithString:url];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:FeedUrl
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        NSString*post = [NSString stringWithFormat:@"%@", jsonData];
        //NSLog(@"%@",post);
        NSData *requestData = [NSData dataWithBytes:[post UTF8String] length:[post length]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: requestData];
        
        //NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        NSError * error = nil;
        NSURLResponse *resp = nil;
        NSData *response =[NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
        
        //NSLog(@"%@",response);
        if(response != Nil)
        {
             NSDictionary *webResponsedict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            
            webresponse = [[WebServiceResponse alloc] initWithJsonData:webResponsedict];
        }
        else
        {
            webresponse = nil;
        }
        
    }else{
        //        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"No internet connection available. Please check internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //        [loginAlert show];
        //        return nil;
        webresponse = [[WebServiceResponse alloc] init];
        webresponse.Data = @"Connect to the Internet to use GoEva.";
        webresponse.StatusCode = @"-200";
        
    }
    
    return webresponse;
}


// For Direct post data
-(WebServiceResponse *)postCallWithUrlDirectly:(NSString *)url postJsonString:(NSString *) jsonData
{
    WebServiceResponse *webresponse=nil;
    if(RestCallManager.hasConnectivity)
    {
        //NSLog(@"Requesting url is %@", url);
        
        NSURL *FeedUrl = [NSURL URLWithString:url];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:FeedUrl
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        NSString*post = [NSString stringWithFormat:@"%@", jsonData];
        NSData *requestData = [NSData dataWithBytes:[post UTF8String] length:[post length]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: requestData];
        
        //NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        NSError * error = nil;
        NSURLResponse *resp = nil;
        NSData *response =[NSURLConnection sendSynchronousRequest:request returningResponse:&resp error:&error];
        
        //NSLog(@"%@",response);
        if(response != Nil)
        {
            NSDictionary *webResponsedict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
            
            webresponse = [[WebServiceResponse alloc] initWithJsonData:webResponsedict];
        }
        else
        {
            webresponse = nil;
        }
        
    }else{
        //        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Attention!" message:@"No internet connection available. Please check internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        //        [loginAlert show];
        //        return nil;
        webresponse = [[WebServiceResponse alloc] init];
        webresponse.Data = @"Connect to the Internet to use GoEva.";
        webresponse.StatusCode = @"-200";
        
    }
    
    return webresponse;
}




// To get encoded string leans like include %20 inside the string

-(NSString *) getEncodedString:(NSString *)NormalString{
    
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (CFStringRef)NormalString,                                                                                                    NULL,
                                                                             (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                             kCFStringEncodingUTF8 ));
    
    return encodedString;
    
}

// Get Nearest Car

-(BOOL)getNearestCar:(NSString *)currentLat
         currentLong:(NSString *)currentLong
           carTypeID:(NSString *)carTypeID
             pickCar:(NSString *)pickCar{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@get_nearest_car",baseUrl];
    
    NSString *dataUrl = [NSString stringWithFormat:@"current_lattitude=%@&current_longitude=%@&car_type_id=%@&pick_car=%@",
                         [self getEncodedString:currentLat],
                         [self getEncodedString:currentLong],
                         [self getEncodedString:carTypeID],
                         pickCar];
    
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            
            NSMutableArray * arr = [[NSMutableArray alloc]init];
                for (int i = 0; i < [jsonUserInfo count]; i++) {
                  CarAvailablity * fund = [[CarAvailablity alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                  [arr addObject:fund];
                }
            [[DataStore sharedInstance] addCarAvailablity:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)check_distance_range: (NSString *)rider_id
                  sourceLat:(NSString *)sourceLat
                 sourceLong:(NSString *)sourceLong
                    descLat:(NSString *)descLat
                   descLong:(NSString *)descLong{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@check_distance_range",baseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"rider_id=%@&ride_source_lat=%@&ride_source_long=%@&ride_dest_lat=%@&ride_dest_long=%@",
                         rider_id,
                         sourceLat,
                         sourceLong,
                         descLat,
                         descLong];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

// Request Booking

-(BOOL)requestBooking:(NSString *)rider_id
       availabilityID:(NSString *)availabilityID
            carTypeID:(NSString *)carTypeID
       pickupLocation:(NSString *)pickupLocation
         dropLocation:(NSString *)dropLocation
            sourceLat:(NSString *)sourceLat
           sourceLong:(NSString *)sourceLong
              descLat:(NSString *)descLat
             descLong:(NSString *)descLong
              pickCar:(NSString *)pickCar{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@confirm_booking",baseUrl];
    
    NSString *dataUrl = [NSString stringWithFormat:@"rider_id=%@&availability_id=%@&car_type_id=%@&pickup_location=%@&drop_location=%@&ride_source_lat=%@&ride_source_long=%@&ride_dest_lat=%@&ride_dest_long=%@&pick_car=%@",
                         rider_id,
                         availabilityID,
                         carTypeID,
                         pickupLocation,
                         dropLocation,
                         sourceLat,
                         sourceLong,
                         descLat,
                         descLong,
                         pickCar];
    
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setBookingID:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    
    return false;
}


-(NSMutableDictionary *)checkRequestStatus:(NSString *)requestID{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@check_driver_confirmation_from_rider_end?request_id=%@",baseUrl,requestID];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    NSMutableDictionary *jsonUserInfo;
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            
            jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            return jsonUserInfo;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return nil;
    }
    return nil;
}

-(NSMutableDictionary *)checkIncompleteRideInRiderEnd:(NSString *)bookingID{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@check_incomplete_ride_in_rider_end?booking_id=%@",baseUrl,bookingID];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    NSMutableDictionary *jsonUserInfo;
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
        }
        [GlobalVariable setGlobalMessage:webResponse.StatusCode];
        return jsonUserInfo;
    }
    else if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"1"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.StatusCode];
        return nil;
    }
    else{
        [GlobalVariable setGlobalMessage:@"We are having an issue connecting to the server. Please try again."];
        return nil;
    }
    return nil;
}


-(BOOL)getCarDetails:(NSString *)carID{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@get_car_details?car_id=%@",baseUrl,carID];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            
            NSMutableArray * arr = [[NSMutableArray alloc]init];
                for (int i = 0; i < [jsonUserInfo count]; i++) {
                CarMaster * fund = [[CarMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
                }
                [[DataStore sharedInstance] addCar:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}


-(NSString *)requestRegistrationOTP:(NSString *)mobileNo
                          is_resend:(NSString *)is_resend{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"mobile_number=%@&is_resend=%@",
                         mobileNo,
                         is_resend];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_get_signup_otp",baseUrl];
    
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return webResponse.StatusCode;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return @"-1001";
    }
    return nil;
}

-(BOOL)registrationByOTP:(NSString *)mobileNumber
                 sendOtp:(NSString *)sendOtp
                deviceID:(NSString *)deviceID
              deviceType:(NSString *)deviceType
             deviceToken:(NSString *)deviceToken{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"mobile_number=%@&send_otp=%@&device_id=%@&device_type=%@&device_token=%@",
                         mobileNumber,
                         sendOtp,
                         deviceID,
                         deviceType,
                         deviceToken];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_check_signup_otp",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                RiderMaster * fund = [[RiderMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addRider:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)registrationByNormal:(NSString *)input{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_signup",baseUrl];
     WebServiceResponse *webResponse = [self postCallWithUrl:strURL postJsonString:input];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                RiderMaster * fund = [[RiderMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addRider:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

// request for Login OTP
-(NSString *)requestLoginOTP:(NSString *)emailIdOrmobileNo
             loginThroughOTP:(NSString *)loginThroughOTP{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"mobileNoOrEmailID=%@&loginThroughOTP=%@",
                         emailIdOrmobileNo,
                         loginThroughOTP];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_signin",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return webResponse.StatusCode;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return @"-1001";
    }
    return nil;
}

// Login

-(BOOL)login:(NSString *)input{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_signin_step_2",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrl:strURL postJsonString:input];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                RiderMaster * fund = [[RiderMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addRider:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    else{
        [GlobalVariable setGlobalMessage:@"There are some problem with Server. Try after some time."];
        return false;
    }
    return false;
}


-(BOOL)fetchCancelReason:(NSString *)userType{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"user_type=%@",userType];
    NSString *strURL=[NSString stringWithFormat:@"%@fetch_cancel_reason",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                CancelReason * fund = [[CancelReason alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addCancelReason:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    else{
        [GlobalVariable setGlobalMessage:@"There are some problem with Server. Try after some time."];
        return false;
    }
    return false;
}


-(BOOL)cancelRide:(NSString *)bookingID
         userType:(NSString *)userType
        isCharged:(NSString *)isCharged
  riderCurrentLat:(NSString *)riderCurrentLat
 riderCurrentLong:(NSString *)riderCurrentLong
   cancelReasonID:(NSString *)cancelReasonID{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"booking_id=%@&user_type=%@&is_charged=%@&user_current_lat=%@&user_current_long=%@&cancel_reason_id=%@",
             bookingID,
             userType,
             isCharged,
             riderCurrentLat,
             riderCurrentLong,
             cancelReasonID];
    NSString *strURL=[NSString stringWithFormat:@"%@cancel_trip",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    else{
        [GlobalVariable setGlobalMessage:@"There are some problem with Server. Try after some time."];
        return false;
    }
    return false;
}

-(BOOL)rateUsDriver:(NSString *)bookingID
           userType:(NSString *)userType
        ratingValue:(NSString *)ratingValue
           comments:(NSString *)comments{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"booking_id=%@&user_type=%@&rating=%@&comment=%@",
                         bookingID,
                         userType,
                         ratingValue,
                         comments];
    NSString *strURL=[NSString stringWithFormat:@"%@give_rate",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    else{
        [GlobalVariable setGlobalMessage:@"There are some problem with Server. Try after some time."];
        return false;
    }
    return false;
}


// Get Legal Menu

-(BOOL)getLegalMenu:(NSString *)user_type{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@fetch_legal_content?user_type=%@",baseUrl,user_type];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                LegalMaster * fund = [[LegalMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addLegalMenu:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)getHelpMenu:(NSString *)user_type{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@fetch_help_content?user_type=%@",baseUrl,user_type];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                HelpMaster * fund = [[HelpMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addHelpMenu:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)getRiderDetails:(NSString *)userID
              userType:(NSString *)userType{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@get_profile_details?user_id=%@&user_type=%@",
                      baseUrl,
                      userID,
                      userType];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                RiderMaster * fund = [[RiderMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addRider:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)riderProfileImageUpload:(NSString *)input{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@update_profile_image",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrl:strURL postJsonString:input];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
         [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)submitprofileData:(NSString *)input{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@update_profile",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrl:strURL postJsonString:input];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)changePassword:(NSString *)riderID
             userType:(NSString *)userType
          oldPassword:(NSString *)oldPassword
          newPassword:(NSString *)newPassword{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"user_id=%@&user_type=%@&old_password=%@&new_password=%@",
                         riderID,
                         userType,
                         oldPassword,
                         newPassword];
    
    NSString *strURL=[NSString stringWithFormat:@"%@change_password",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}


-(BOOL)forgotPasswordStep1:mobileOrEmail{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"mobileNoOrEmailID=%@",mobileOrEmail];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_reset_password_step_1",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)forgotPasswordStep2:(NSString *)mobileOrEmail otpValue:(NSString *)otpValue{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"mobileNoOrEmailID=%@&otp=%@",mobileOrEmail,otpValue];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_reset_password_step_2",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)forgotPasswordStep3:(NSString *)mobileOrEmail
               newPassword:(NSString *)newPassword{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"mobileNoOrEmailID=%@&password=%@",mobileOrEmail,newPassword];
    NSString *strURL=[NSString stringWithFormat:@"%@rider_reset_password_step_3",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    [GlobalVariable setGlobalMessage:@"We are having an issue connecting to the server. Please try again."];
    return false;
}

-(BOOL)getTripList:(NSString *)riderID{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@trip_list?rider_id=%@",baseUrl,riderID];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                BookingDetailMaster *fund = [[BookingDetailMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addBookig:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    else
    {
        [GlobalVariable setGlobalMessage:@"Some problem with the server. Please try again."];
        return false;
    }
    return false;
}


-(NSString *)getDriverLocationForArriving:(NSString *)driverID
                                bookingID:(NSString *)bookingID{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@get_driver_location_for_arriving?driver_id=%@&booking_id=%@",
                      baseUrl,
                      driverID,
                      bookingID];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                DriverLiveLocation *fund = [[DriverLiveLocation alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addDriverLiveLocation:arr];
            return webResponse.StatusCode;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return webResponse.StatusCode;
    }
    return nil;
}

-(NSString *)getEstimatedTimeOfRideAfterStartTrip:(NSString *)driverID
                                         userType:(NSString *)userType
                                        bookingID:(NSString *)bookingID
                                 driverCurrentlat:(NSString *)driverCurrentlat
                                driverCurrentLong:(NSString *)driverCurrentLong{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    if (driverCurrentlat==nil)  driverCurrentlat=@"";
    if (driverCurrentLong==nil)  driverCurrentLong=@"";
    NSString *strURL=[NSString stringWithFormat:@"%@get_estimated_timeOf_ride_after_startTrip?driver_id=%@&user_type=%@&booking_id=%@&driver_current_lat=%@&driver_current_long=%@",
                      baseUrl,
                      driverID,
                      userType,
                      bookingID,
                      driverCurrentlat,
                      driverCurrentLong];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                DriverLiveLocation *fund = [[DriverLiveLocation alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addDriverLiveLocation:arr];
            return webResponse.StatusCode;
        }
    }
    else if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"1"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                BookingDetailMaster *fund = [[BookingDetailMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addBookig:arr];
            return webResponse.StatusCode;
        }
    }
    else{
        [GlobalVariable setGlobalMessage:@"We are having an issue connecting to the server. Please try again."];
        return nil;
    }
   return nil;
}


-(BOOL)cancelRequestByRider:(NSString *)requestID{
    
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"request_id=%@",requestID];
    NSString *strURL=[NSString stringWithFormat:@"%@cancel_on_timeout",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:@""];
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:@""];
        return false;
    }
    [GlobalVariable setGlobalMessage:@"We are having an issue connecting to the server. Please try again."];
    return false;
}

// Get settings
-(BOOL)getSettings:(NSString *)userType{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *dataUrl = [NSString stringWithFormat:@"user_type=%@",userType];
    NSString *strURL=[NSString stringWithFormat:@"%@get_setting",baseUrl];
    WebServiceResponse *webResponse = [self postCallWithUrlDirectly:strURL postJsonString:dataUrl];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        NSData *JSONdata = [webResponse.Data dataUsingEncoding:NSUTF8StringEncoding];
        if (JSONdata != nil) {
            NSError * error =nil;
            NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
            NSMutableArray * arr = [[NSMutableArray alloc]init];
            for (int i = 0; i < [jsonUserInfo count]; i++) {
                SettingMaster * fund = [[SettingMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                [arr addObject:fund];
            }
            [[DataStore sharedInstance] addSetting:arr];
            return true;
        }
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    else{
        [GlobalVariable setGlobalMessage:@"We are having an issue connecting to the server. Please try again."];
        return false;
    }
    return false;
}

-(BOOL)addTips:(NSString *)bookingID amount:(NSString *)amount{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@add_tips?booking_id=%@&tips_amount=%@",
                      baseUrl,
                      bookingID,
                      amount];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
            return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}

-(BOOL)removeTips:(NSString *)bookingID{
    NSString *baseUrl = [[RestCallManager sharedInstance] getBaseUrl];
    NSString *strURL=[NSString stringWithFormat:@"%@remove_tips?booking_id=%@",
                      baseUrl,
                      bookingID];
    WebServiceResponse *webResponse = [self getCallWithUrl:strURL];
    if(webResponse != nil && [webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        return true;
    }
    else if(webResponse != nil && ![webResponse.StatusCode isEqualToString:@"0"] && webResponse.Data != nil)
    {
        [GlobalVariable setGlobalMessage:webResponse.Data];
        return false;
    }
    return false;
}
@end

