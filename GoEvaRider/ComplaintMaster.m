//
//  ComplaintMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "ComplaintMaster.h"

@implementation ComplaintMaster

@synthesize id;
@synthesize complain_token_number;
@synthesize title;
@synthesize content;
@synthesize dateofcomplain;
@synthesize response_status;
@synthesize status;
@synthesize rider_id;
@synthesize driver_id;
@synthesize car_id;

-(id)init
{
    self.id = @"";
    self.complain_token_number = @"";
    self.title = @"";
    self.content = @"";
    self.dateofcomplain = @"";
    self.response_status = @"";
    self.status = @"";
    self.rider_id = @"";
    self.driver_id = @"";
    self.car_id = @"";
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.complain_token_number = [jsonObjects valueForKey:@"complain_token_number"];
    self.title = [jsonObjects valueForKey:@"title"];
    self.content = [jsonObjects valueForKey:@"content"];
    self.dateofcomplain = [jsonObjects valueForKey:@"dateofcomplain"];
    self.response_status = [jsonObjects valueForKey:@"response_status"];
    self.status = [jsonObjects valueForKey:@"status"];
    self.rider_id = [jsonObjects valueForKey:@"rider_id"];
    self.driver_id = [jsonObjects valueForKey:@"driver_id"];
    self.car_id = [jsonObjects valueForKey:@"car_id"];
    
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
