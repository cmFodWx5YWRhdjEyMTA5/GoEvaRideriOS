//
//  CardMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/17/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "CardMaster.h"

@implementation CardMaster

@synthesize id;
@synthesize brand;
@synthesize country;
@synthesize customer_id;
@synthesize rider_id;
@synthesize exp_month;
@synthesize exp_year;
@synthesize funding;
@synthesize last4;
@synthesize card_holder_name;
@synthesize default_source;
@synthesize first_name;
@synthesize last_name;

-(id)init
{
    self.id = @"";
    self.brand= @"";
    self.country= @"";
    self.customer_id= @"";
    self.rider_id= @"";
    self.exp_month= @"";
    self.exp_year= @"";
    self.funding= @"";
    self.last4= @"";
    self.card_holder_name= @"";
    self.default_source= @"";
    self.first_name= @"";
    self.last_name= @"";
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.brand= [jsonObjects valueForKey:@"brand"];
    self.country= [jsonObjects valueForKey:@"country"];
    self.customer_id= [jsonObjects valueForKey:@"customer_id"];
    self.rider_id= [jsonObjects valueForKey:@"rider_id"];
    self.exp_month= [jsonObjects valueForKey:@"exp_month"];
    self.exp_year= [jsonObjects valueForKey:@"exp_year"];
    self.funding= [jsonObjects valueForKey:@"funding"];
    self.last4= [jsonObjects valueForKey:@"last4"];
    self.card_holder_name= [jsonObjects valueForKey:@"card_holder_name"];
    self.default_source= [jsonObjects valueForKey:@"default_source"];
    self.first_name= [jsonObjects valueForKey:@"first_name"];
    self.last_name= [jsonObjects valueForKey:@"last_name"];
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
