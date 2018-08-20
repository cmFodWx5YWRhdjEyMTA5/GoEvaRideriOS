//
//  RestCallManager.h
//  saltnsoap
//
//  Created by Kalyan Mohan Paul on 4/27/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceResponse.h"
#import "CarAvailablity.h"
#import "CarMaster.h"
#import "RiderMaster.h"
#import "BookingDetailMaster.h"
@interface RestCallManager : NSObject

+ (id)sharedInstance;
-(WebServiceResponse *)getCallWithUrl:(NSString *) FeedURL;
-(WebServiceResponse *)postCallWithUrl:(NSString *)url postJsonString:(NSString *) jsonData;
+(BOOL)hasConnectivity;
-(NSString *)getBaseUrl;

-(BOOL)getNearestCar:(NSString *)currentLat currentLong:(NSString *)currentLong carTypeID:(NSString *)carTypeID pickCar:(NSString *)pickCar;
-(BOOL)check_distance_range: (NSString *)rider_id sourceLat:(NSString *)sourceLat sourceLong:(NSString *)sourceLong descLat:(NSString *)descLat descLong:(NSString *)descLong;
-(BOOL)requestBooking:(NSString *)rider_id availabilityID:(NSString *)availabilityID carTypeID:(NSString *)carTypeID pickupLocation:(NSString *)pickupLocation dropLocation:(NSString *)dropLocation sourceLat:(NSString *)sourceLat sourceLong:(NSString *)sourceLong descLat:(NSString *)descLat descLong:(NSString *)descLong pickCar:(NSString *)pickCar;

-(NSMutableDictionary *)checkRequestStatus:(NSString *)requestID;

-(BOOL)getCarDetails:(NSString *)carID;

-(NSString *)requestRegistrationOTP:(NSString *)mobileNo is_resend:(NSString *)is_resend;

-(BOOL)registrationByOTP:(NSString *)mobileNumber sendOtp:(NSString *)sendOtp deviceID:(NSString *)deviceID deviceType:(NSString *)deviceType deviceToken:(NSString *)deviceToken;

-(BOOL)registrationByNormal:(NSString *)input;

-(NSString *)requestLoginOTP:(NSString *)emailIdOrmobileNo loginThroughOTP:(NSString *)loginThroughOTP;
-(BOOL)login:(NSString *)input;

-(BOOL)fetchCancelReason:(NSString *)userType;

-(BOOL)cancelRide:(NSString *)bookingID userType:(NSString *)userType isCharged:(NSString *)isCharged riderCurrentLat:(NSString *)riderCurrentLat riderCurrentLong:(NSString *)riderCurrentLong cancelReasonID:(NSString *)cancelReasonID;

-(BOOL)rateUsDriver:(NSString *)bookingID userType:(NSString *)userType ratingValue:(NSString *)ratingValue comments: (NSString *)comments;

-(BOOL)getLegalMenu:(NSString *)user_type;

-(BOOL)getHelpMenu:(NSString *)user_type;

-(BOOL)getRiderDetails:(NSString *)userID userType:(NSString *)userType;

-(BOOL)riderProfileImageUpload:(NSString *)input;
-(BOOL)submitprofileData:(NSString *)input;
-(BOOL)changePassword:(NSString *)riderID userType:(NSString *)userType oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword;
-(BOOL)forgotPasswordStep1:(NSString *)mobileOrEmail;
-(BOOL)forgotPasswordStep2:(NSString *)mobileOrEmail otpValue:(NSString *)otpValue;
-(BOOL)forgotPasswordStep3:(NSString *)mobileOrEmail newPassword:(NSString *)newPassword;
-(BOOL)getTripList:(NSString *)riderID;
-(NSString *)getDriverLocationForArriving:(NSString *)driverID bookingID:(NSString *)bookingID;
-(NSString *)getEstimatedTimeOfRideAfterStartTrip:(NSString *)driverID userType:(NSString *)userType bookingID:(NSString *)bookingID driverCurrentlat:(NSString *)driverCurrentlat driverCurrentLong:(NSString *)driverCurrentLong;
-(BOOL)cancelRequestByRider:(NSString *)requestID;
-(BOOL)getSettings:(NSString *)userType;
-(NSMutableDictionary *)checkIncompleteRideInRiderEnd:(NSString *)bookingID;

@end
