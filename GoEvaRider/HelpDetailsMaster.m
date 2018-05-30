//
//  HelpDetailsMaster.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/20/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "HelpDetailsMaster.h"

@implementation HelpDetailsMaster

@synthesize id;
@synthesize cat_id;
@synthesize sub_cat_name;
@synthesize content;

-(id)init
{
    self.id = @"";
    self.cat_id = @"";
    self.sub_cat_name = @"";
    self.content = @"";
    return self;
}

-(id)initWithJsonData:(NSDictionary *)jsonObjects
{
    self.id = [jsonObjects valueForKey:@"id"];
    self.cat_id = [jsonObjects valueForKey:@"cat_id"];
    self.sub_cat_name = [jsonObjects valueForKey:@"sub_cat_name"];
    self.content = [jsonObjects valueForKey:@"content"];
    
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
