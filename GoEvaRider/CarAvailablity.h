//
//  CarAvailablity.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarAvailablity : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *availability_id;
@property(nonatomic,retain)NSString *car_type_id;
@property(nonatomic,retain)NSString *car_name;
@property(nonatomic,retain)NSString *online_current_lat;
@property(nonatomic,retain)NSString *online_current_long;
@property(nonatomic,retain)NSString *car_category;
@property(nonatomic,retain)NSString *normal_image;
@property(nonatomic,retain)NSString *peak_hour_image;
@property(nonatomic,retain)NSString *distance;
@property(nonatomic,retain)NSString *estimated_time;
@property(nonatomic,retain)NSString *distance_wise_rate;
@property(nonatomic,retain)NSString *time_wise_rate;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
