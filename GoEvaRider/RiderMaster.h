//
//  RiderMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RiderMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *rider_id;
@property(nonatomic,retain)NSString *user_type;
@property(nonatomic,retain)NSString *rider_name;
@property(nonatomic,retain)NSString *rider_mobile;
@property(nonatomic,retain)NSString *rider_email;
@property(nonatomic,retain)NSString *profile_pic;
@property(nonatomic,retain)NSString *signup_date;
@property(nonatomic,retain)NSString *password;
@property(nonatomic,retain)NSString *login_through_otp;
@property(nonatomic,retain)NSString *device_id;
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *ratting;
@property(nonatomic,retain)NSString *device_token;
@property(nonatomic,retain)NSString *device_type;

@property(nonatomic,retain)NSString *pickup_address;
@property(nonatomic,retain)NSString *drop_address;
@property(nonatomic,retain)NSString *pickup_lat;
@property(nonatomic,retain)NSString *pickup_long;
@property(nonatomic,retain)NSString *drop_lat;
@property(nonatomic,retain)NSString *drop_long;

@property(nonatomic,retain)NSString *distance_in_mile;
@property(nonatomic,retain)NSString *duration_in_min;
@property(nonatomic,retain)NSString *booking_status;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end

