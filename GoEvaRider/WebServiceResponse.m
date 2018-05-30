//
//  WebServiceResponse.m
//  EditFX
//
//  Created by Kalyan Mohan Paul on 4/27/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import "WebServiceResponse.h"

@implementation WebServiceResponse

@synthesize StatusCode;
@synthesize Data;


-(id)init
{
    Data = @"";
    StatusCode = @"-100";
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    
    Data = [jsonObjects valueForKey:@"Data"];
    
    StatusCode =  [jsonObjects valueForKey:@"StatusCode"];
    
    
    return self;
    
}

@end
