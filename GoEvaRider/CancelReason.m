//
//  CancelReason.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "CancelReason.h"

@implementation CancelReason

@synthesize id;
@synthesize cancel_reason;

-(id)init
{
    self.id = @"";
    self.cancel_reason = @"";
    
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.cancel_reason = [jsonObjects valueForKey:@"cancel_reason"];
    
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
