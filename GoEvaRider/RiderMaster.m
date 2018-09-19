//
//  RiderMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "RiderMaster.h"

@implementation RiderMaster

@synthesize id;
@synthesize rider_id;
@synthesize user_type;
@synthesize rider_name;
@synthesize rider_mobile;
@synthesize rider_email;
@synthesize profile_pic;
@synthesize signup_date;
@synthesize password;
@synthesize login_through_otp;
@synthesize device_id;
@synthesize status;
@synthesize ratting;
@synthesize device_token;
@synthesize device_type;

@synthesize booking_id;
@synthesize pickup_address;
@synthesize drop_address;
@synthesize pickup_lat;
@synthesize pickup_long;
@synthesize drop_lat;
@synthesize drop_long;

@synthesize distance_in_mile;
@synthesize duration_in_min;
@synthesize booking_status;

-(id)init
{
    self.id = @"";
    self.rider_id = @"";
    self.user_type = @"";
    self.rider_name = @"";
    self.rider_mobile = @"";
    self.rider_email = @"";
    self.profile_pic = @"";
    self.signup_date = @"";
    self.password = @"";
    self.login_through_otp = @"";
    self.device_id = @"";
    self.status = @"";
    self.ratting = @"";
    self.device_token = @"";
    self.device_type = @"";
    
    self.booking_id = @"";
    self.pickup_address = @"";
    self.drop_address = @"";
    self.pickup_lat = @"";
    self.pickup_long = @"";
    self.drop_lat = @"";
    self.drop_long = @"";
    
    self.distance_in_mile = @"";
    self.duration_in_min = @"";
    self.booking_status = @"";
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    
    self.id = [jsonObjects valueForKey:@"id"];
    self.rider_id = [jsonObjects valueForKey:@"rider_id"];
    self.user_type = [jsonObjects valueForKey:@"user_type"];
    self.rider_name = [jsonObjects valueForKey:@"rider_name"];
    self.rider_mobile = [jsonObjects valueForKey:@"rider_mobile"];
    self.rider_email = [jsonObjects valueForKey:@"rider_email"];
    self.profile_pic = [jsonObjects valueForKey:@"profile_pic"];
    self.signup_date = [jsonObjects valueForKey:@"signup_date"];
    self.password = [jsonObjects valueForKey:@"password"];
    self.login_through_otp = [jsonObjects valueForKey:@"login_through_otp"];
    self.device_id = [jsonObjects valueForKey:@"device_id"];
    self.status = [jsonObjects valueForKey:@"status"];
    self.ratting = [jsonObjects valueForKey:@"ratting"];
    self.device_token = [jsonObjects valueForKey:@"device_token"];
    self.device_type = [jsonObjects valueForKey:@"device_type"];
    
    self.booking_id = [jsonObjects valueForKey:@"booking_id"];
    self.pickup_address = [jsonObjects valueForKey:@"pickup_address"];
    self.drop_address = [jsonObjects valueForKey:@"drop_address"];
    self.pickup_lat = [jsonObjects valueForKey:@"pickup_lat"];
    self.pickup_long = [jsonObjects valueForKey:@"pickup_long"];
    self.drop_lat = [jsonObjects valueForKey:@"drop_lat"];
    self.drop_long = [jsonObjects valueForKey:@"drop_long"];
    
    self.distance_in_mile = [jsonObjects valueForKey:@"distance_in_mile"];
    self.duration_in_min = [jsonObjects valueForKey:@"duration_in_min"];
    self.booking_status = [jsonObjects valueForKey:@"booking_status"];
    return self;
}

-(NSString *)JSONRepresentation
{
    NSDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           self.id,@"id",
                           self.rider_id,@"rider_id",
                           self.user_type,@"user_type",
                           self.rider_name,@"rider_name",
                           self.rider_mobile, @"rider_mobile",
                           self.rider_email, @"rider_email",
                           self.profile_pic, @"profile_pic",
                           self.signup_date,@"signup_date",
                           self.password, @"password",
                           self.login_through_otp,@"login_through_otp",
                           self.device_id,@"device_id",
                           self.status,@"status",
                           self.ratting,@"ratting",
                           self.device_token,@"device_token",
                           self.device_type,@"device_type",
                           
                           self.booking_id,@"booking_id",
                           self.pickup_address,@"pickup_address",
                           self.drop_address,@"drop_address",
                           self.pickup_lat,@"pickup_lat",
                           self.pickup_long,@"pickup_long",
                           self.drop_lat = @"drop_lat",
                           self.drop_long = @"drop_long",
                           
                           self.distance_in_mile,@"distance_in_mile",
                           self.duration_in_min,@"duration_in_min",
                           self.booking_status,@"booking_status",
                           nil];
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString* string = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return string;
}


@end
