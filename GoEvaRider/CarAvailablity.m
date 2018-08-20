//
//  CarAvailablity.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "CarAvailablity.h"

@implementation CarAvailablity

@synthesize id;
@synthesize availability_id;
@synthesize car_type_id;
@synthesize car_name;
@synthesize online_current_lat;
@synthesize online_current_long;
@synthesize car_category;
@synthesize normal_image;
@synthesize peak_hour_image;
@synthesize distance;
@synthesize estimated_time;
@synthesize distance_wise_rate;
@synthesize time_wise_rate;
@synthesize count_avacar;

-(id)init
{
    self.id = @"";
    self.availability_id = @"";
    self.car_type_id = @"";
    self.car_name = @"";
    self.online_current_lat = @"";
    self.online_current_long = @"";
    self.car_category = @"";
    self.normal_image = @"";
    self.peak_hour_image = @"";
    self.distance = @"";
    self.estimated_time = @"";
    self.distance_wise_rate = @"";
    self.time_wise_rate = @"";
    self.count_avacar = @"";
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.availability_id = [jsonObjects valueForKey:@"availability_id"];
    self.car_type_id = [jsonObjects valueForKey:@"car_type_id"];
    self.car_name = [jsonObjects valueForKey:@"car_name"];
    self.online_current_lat = [jsonObjects valueForKey:@"online_current_lat"];
    self.online_current_long = [jsonObjects valueForKey:@"online_current_long"];
    self.car_category = [jsonObjects valueForKey:@"car_category"];
    self.normal_image = [jsonObjects valueForKey:@"normal_image"];
    self.peak_hour_image = [jsonObjects valueForKey:@"peak_hour_image"];
    self.distance = [jsonObjects valueForKey:@"distance"];
    self.estimated_time = [jsonObjects valueForKey:@"estimated_time"];
    self.distance_wise_rate = [jsonObjects valueForKey:@"distance_wise_rate"];
    self.time_wise_rate = [jsonObjects valueForKey:@"time_wise_rate"];
    self.count_avacar = [jsonObjects valueForKey:@"count_avacar"];
    
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
