//
//  LocationData.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/17/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "LocationData.h"

@implementation LocationData

@synthesize locationAddress;
@synthesize latitude;
@synthesize longitude;

-(id)init
{
    self.locationAddress = @"";
    self.latitude = @"";
    self.longitude = @"";
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.locationAddress forKey:@"locationAddress"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.locationAddress = [decoder decodeObjectForKey:@"locationAddress"];
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
    }
    return self;
}

@end
