//
//  HelpMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/19/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "HelpMaster.h"

@implementation HelpMaster

@synthesize id;
@synthesize cat_name;
@synthesize sub_cat_array;

-(id)init
{
    self.id = @"";
    self.cat_name = @"";
    self.sub_cat_array = [[NSMutableArray alloc] init];
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.cat_name = [jsonObjects valueForKey:@"cat_name"];
    self.sub_cat_array = [jsonObjects valueForKey:@"sub_cat_array"];
    
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
