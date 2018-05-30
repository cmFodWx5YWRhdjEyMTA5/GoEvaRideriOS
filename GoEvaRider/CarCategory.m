//
//  CarCategory.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "CarCategory.h"

@implementation CarCategory

@synthesize id;
@synthesize car_category;
@synthesize normal_image;
@synthesize peak_hour_image;
@synthesize status;

-(id)init
{
    self.id = @"";
    self.car_category = @"";
    self.normal_image = @"";
    self.peak_hour_image = @"";
    self.status = @"";
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.car_category = [jsonObjects valueForKey:@"car_category"];
    self.normal_image = [jsonObjects valueForKey:@"normal_image"];
    self.peak_hour_image = [jsonObjects valueForKey:@"peak_hour_image"];
    self.status = [jsonObjects valueForKey:@"status"];
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
