//
//  BookingMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "BookingMaster.h"

@implementation BookingMaster

@synthesize booking_id;
@synthesize booking_date;
@synthesize booking_time;
@synthesize car_name;
@synthesize total_fare;
@synthesize pickup_location;
@synthesize drop_location;
@synthesize ride_start_time;
@synthesize ride_completion_time;
@synthesize booking_status;
@synthesize driver_rating;

-(id)init
{
    self.booking_id = @"";
    self.booking_date = @"";
    self.booking_time = @"";
    self.car_name = @"";
    self.total_fare = @"";
    self.pickup_location = @"";
    self.drop_location = @"";
    self.ride_start_time = @"";
    self.ride_completion_time = @"";
    self.booking_status = @"";
    self.driver_rating = @"";
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.booking_id = [jsonObjects valueForKey:@"booking_id"];
    self.booking_date = [jsonObjects valueForKey:@"booking_date"];
    self.booking_time = [jsonObjects valueForKey:@"booking_time"];
    self.car_name = [jsonObjects valueForKey:@"car_name"];
    self.total_fare = [jsonObjects valueForKey:@"total_fare"];
    self.pickup_location = [jsonObjects valueForKey:@"pickup_location"];
    self.drop_location = [jsonObjects valueForKey:@"drop_location"];
    self.ride_start_time = [jsonObjects valueForKey:@"ride_start_time"];
    self.ride_completion_time = [jsonObjects valueForKey:@"ride_completion_time"];
    self.booking_status = [jsonObjects valueForKey:@"booking_status"];
    self.driver_rating = [jsonObjects valueForKey:@"driver_rating"];
    
    return self;
}

-(NSString *)JSONRepresentation
{
    NSDictionary * dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.booking_id,@"booking_id", nil];
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString* string = [[NSString alloc] initWithData:jsonData
                                             encoding:NSUTF8StringEncoding];
    return string;
}


@end
