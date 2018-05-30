//
//  DriverMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "DriverMaster.h"

@implementation DriverMaster

@synthesize id;
@synthesize driver_id;
@synthesize user_type;
@synthesize driver_name;
@synthesize mobile_no;
@synthesize email_id;
@synthesize password;
@synthesize device_id;
@synthesize reg_dt;
@synthesize profile_pic;
@synthesize driver_licence;
@synthesize isowner;
@synthesize device_type;
@synthesize device_token;
@synthesize signup_date;
@synthesize status;


-(id)init
{
    self.id = @"";
    self.driver_id = @"";
    self.user_type = @"";
    self.driver_name = @"";
    self.mobile_no = @"";
    self.email_id = @"";
    self.password = @"";
    self.device_id = @"";
    self.reg_dt = @"";
    self.profile_pic = @"";
    self.driver_licence = @"";
    self.isowner = @"";
    self.device_type = @"";
    self.device_token = @"";
    self.signup_date = @"";
    self.status = @"";
    
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    
    self.id = [jsonObjects valueForKey:@"id"];
    self.driver_id = [jsonObjects valueForKey:@"driver_id"];
    self.user_type = [jsonObjects valueForKey:@"user_type"];
    self.driver_name = [jsonObjects valueForKey:@"driver_name"];
    self.mobile_no = [jsonObjects valueForKey:@"mobile_no"];
    self.email_id = [jsonObjects valueForKey:@"email_id"];
    self.password = [jsonObjects valueForKey:@"password"];
    self.device_id = [jsonObjects valueForKey:@"device_id"];
    self.reg_dt = [jsonObjects valueForKey:@"reg_dt"];
    self.profile_pic = [jsonObjects valueForKey:@"profile_pic"];
    self.driver_licence = [jsonObjects valueForKey:@"driver_licence"];
    self.isowner = [jsonObjects valueForKey:@"isowner"];
    self.device_type = [jsonObjects valueForKey:@"device_type"];
    self.device_token = [jsonObjects valueForKey:@"device_token"];
    self.signup_date = [jsonObjects valueForKey:@"signup_date"];
    self.status = [jsonObjects valueForKey:@"status"];
    
    
    return self;
}

-(NSString *)JSONRepresentation
{
    NSDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           self.id,@"id",
                           self.driver_id,@"driver_id",
                           self.user_type,@"user_type",
                           self.driver_name,@"driver_name",
                           self.mobile_no,@"mobile_no",
                           self.email_id,@"email_id",
                           self.password,@"password",
                           self.device_id,@"device_id",
                           self.reg_dt,@"reg_dt",
                           self.profile_pic,@"profile_pic",
                           self.driver_licence,@"driver_licence",
                           self.isowner,@"isowner",
                           self.device_type,@"device_type",
                           self.device_token,@"device_token",
                           self.signup_date,@"signup_date",
                           self.status,@"status",
                           nil];
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString* string = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return string;
}


@end
