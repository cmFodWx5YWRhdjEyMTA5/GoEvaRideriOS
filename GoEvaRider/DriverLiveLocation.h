//
//  DriverLiveLocation.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 1/16/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriverLiveLocation : NSObject


@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *driver_id;
@property(nonatomic,retain)NSString *current_lat;
@property(nonatomic,retain)NSString *current_long;
@property(nonatomic,retain)NSString *remaining_time;
@property(nonatomic,retain)NSString *remaining_distance;


-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
