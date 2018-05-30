//
//  CarMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "CarMaster.h"

@implementation CarMaster

@synthesize id;
@synthesize driver_id;
@synthesize car_id;
@synthesize seat_capacity;
@synthesize car_type_id;
@synthesize car_name;
@synthesize car_reg_no;
@synthesize car_plate_no;
@synthesize car_pic;
@synthesize status;
@synthesize car_category;
@synthesize normal_image;
@synthesize peak_hour_image;
@synthesize driver_name;
@synthesize email_id;
@synthesize mobile_no;
@synthesize profile_pic;
@synthesize driver_ratting;


-(id)init
{
    self.id = @"";
    self.driver_id = @"";
    self.car_id = @"";
    self.seat_capacity = @"";
    self.car_type_id = @"";
    self.car_name = @"";
    self.car_reg_no = @"";
    self.car_plate_no = @"";
    self.car_pic = @"";
    self.status = @"";
    self.car_category = @"";
    self.normal_image = @"";
    self.peak_hour_image = @"";
    self.driver_name = @"";
    self.mobile_no = @"";
    self.email_id = @"";
    self.profile_pic = @"";
    self.driver_ratting = @"";
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.driver_id = [jsonObjects valueForKey:@"driver_id"];
    self.car_id = [jsonObjects valueForKey:@"car_id"];
    self.seat_capacity = [jsonObjects valueForKey:@"seat_capacity"];
    self.car_type_id = [jsonObjects valueForKey:@"car_type_id"];
    self.car_name = [jsonObjects valueForKey:@"car_name"];
    self.car_reg_no = [jsonObjects valueForKey:@"car_reg_no"];
    self.car_plate_no = [jsonObjects valueForKey:@"car_plate_no"];
    self.car_pic = [jsonObjects valueForKey:@"car_pic"];
    self.status = [jsonObjects valueForKey:@"status"];
    self.car_category = [jsonObjects valueForKey:@"car_category"];
    self.normal_image = [jsonObjects valueForKey:@"normal_image"];
    self.peak_hour_image = [jsonObjects valueForKey:@"peak_hour_image"];
    self.driver_name = [jsonObjects valueForKey:@"driver_name"];
    self.email_id = [jsonObjects valueForKey:@"email_id"];
    self.mobile_no = [jsonObjects valueForKey:@"mobile_no"];
    self.profile_pic = [jsonObjects valueForKey:@"profile_pic"];
    self.driver_ratting = [jsonObjects valueForKey:@"driver_ratting"];
    
    return self;
}

-(NSString *)JSONRepresentation
{
    NSDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.id,@"id", nil];
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString* string = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return string;
}


@end
