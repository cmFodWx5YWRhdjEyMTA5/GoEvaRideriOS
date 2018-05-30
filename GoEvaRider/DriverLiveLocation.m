//
//  DriverLiveLocation.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 1/16/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import "DriverLiveLocation.h"

@implementation DriverLiveLocation

@synthesize id;
@synthesize driver_id;
@synthesize current_lat;
@synthesize current_long;
@synthesize remaining_time;
@synthesize remaining_distance;

-(id)init
{
    self.id = @"";
    self.driver_id= @"";
    self.current_lat= @"";
    self.current_long= @"";
    self.remaining_time= @"";
    self.remaining_distance= @"";
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.driver_id= [jsonObjects valueForKey:@"driver_id"];
    self.current_lat= [jsonObjects valueForKey:@"current_lat"];
    self.current_long= [jsonObjects valueForKey:@"current_long"];
    self.remaining_time= [jsonObjects valueForKey:@"remaining_time"];
    self.remaining_distance = [jsonObjects valueForKey:@"remaining_distance"];
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
