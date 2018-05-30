//
//  BookingDetailMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/12/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "BookingDetailMaster.h"

@implementation BookingDetailMaster

@synthesize id;
@synthesize booking_id;
@synthesize booking_datetime;
@synthesize car_name;
@synthesize car_category_id;
@synthesize car_category_name;
@synthesize pickup_location;
@synthesize drop_location;
@synthesize ride_start_time;
@synthesize ride_completion_time;
@synthesize booking_status;
@synthesize driver_rating;
@synthesize rider_rating;
@synthesize pickup_lat;
@synthesize pickup_long;
@synthesize drop_lat;
@synthesize drop_long;
@synthesize driver_name;
@synthesize driver_image;
@synthesize total_time;
@synthesize total_distance;
@synthesize total_fare;
@synthesize total_base_fare;
@synthesize taxes;

-(id)init
{
    self.id = @"";
    self.booking_id = @"";
    self.booking_datetime = @"";
    self.car_name = @"";
    self.car_category_id = @"";
    self.car_category_name = @"";
    self.total_fare = @"";
    self.pickup_location = @"";
    self.drop_location = @"";
    self.ride_start_time = @"";
    self.ride_completion_time = @"";
    self.booking_status = @"";
    self.driver_rating = @"";
    self.rider_rating = @"";
    self.pickup_lat = @"";
    self.pickup_long = @"";
    self.drop_lat = @"";
    self.drop_long = @"";
    self.driver_name = @"";
    self.driver_image = @"";
    self.total_time = @"";
    self.total_distance = @"";
    self.total_base_fare = @"";
    self.taxes = @"";
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.booking_id = [jsonObjects valueForKey:@"booking_id"];
    self.booking_datetime = [jsonObjects valueForKey:@"booking_datetime"];
    self.car_name = [jsonObjects valueForKey:@"car_name"];
    self.car_category_id = [jsonObjects valueForKey:@"car_category_id"];
    self.car_category_name = [jsonObjects valueForKey:@"car_category_name"];
    self.total_fare = [jsonObjects valueForKey:@"total_fare"];
    self.pickup_location = [jsonObjects valueForKey:@"pickup_location"];
    self.drop_location = [jsonObjects valueForKey:@"drop_location"];
    self.ride_start_time = [jsonObjects valueForKey:@"ride_start_time"];
    self.ride_completion_time = [jsonObjects valueForKey:@"ride_completion_time"];
    self.booking_status = [jsonObjects valueForKey:@"booking_status"];
    self.driver_rating = [jsonObjects valueForKey:@"driver_rating"];
    self.rider_rating = [jsonObjects valueForKey:@"rider_rating"];
    self.pickup_lat = [jsonObjects valueForKey:@"pickup_lat"];
    self.pickup_long = [jsonObjects valueForKey:@"pickup_long"];
    self.drop_lat = [jsonObjects valueForKey:@"drop_lat"];
    self.drop_long = [jsonObjects valueForKey:@"drop_long"];
    self.driver_name = [jsonObjects valueForKey:@"driver_name"];
    self.driver_image = [jsonObjects valueForKey:@"driver_image"];
    self.total_distance = [jsonObjects valueForKey:@"total_distance"];
    self.total_time = [jsonObjects valueForKey:@"total_time"];
    self.total_base_fare = [jsonObjects valueForKey:@"total_base_fare"];
    self.taxes = [jsonObjects valueForKey:@"taxes"];
    
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
