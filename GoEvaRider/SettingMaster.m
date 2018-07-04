//
//  SettingMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/2/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import "SettingMaster.h"

@implementation SettingMaster

@synthesize id;
@synthesize search_radius;
@synthesize cancellation_charge;
@synthesize min_duration_for_cancellation_charge;

-(id)init
{
    self.id =@"";
    self.search_radius = @"";
    self.cancellation_charge = @"";
    self.min_duration_for_cancellation_charge = @"";
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.search_radius= [jsonObjects valueForKey:@"search_radius"];
    self.cancellation_charge= [jsonObjects valueForKey:@"cancellation_charge"];
    self.min_duration_for_cancellation_charge= [jsonObjects valueForKey:@"min_duration_for_cancellation_charge"];
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
