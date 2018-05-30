//
//  BookingDetailMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/12/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookingDetailMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *booking_id;
@property(nonatomic,retain)NSString *booking_datetime;
@property(nonatomic,retain)NSString *car_name;
@property(nonatomic,retain)NSString *car_category_id;
@property(nonatomic,retain)NSString *car_category_name;
@property(nonatomic,retain)NSString *pickup_location;
@property(nonatomic,retain)NSString *drop_location;
@property(nonatomic,retain)NSString *ride_start_time;
@property(nonatomic,retain)NSString *ride_completion_time;
@property(nonatomic,retain)NSString *booking_status; // Cancel or Complete
@property(nonatomic,retain)NSString *driver_rating;
@property(nonatomic,retain)NSString *rider_rating;
@property(nonatomic,retain)NSString *pickup_lat;
@property(nonatomic,retain)NSString *pickup_long;
@property(nonatomic,retain)NSString *drop_lat;
@property(nonatomic,retain)NSString *drop_long;
@property(nonatomic,retain)NSString *driver_name;
@property(nonatomic,retain)NSString *driver_image;
@property(nonatomic,retain)NSString *total_time;
@property(nonatomic,retain)NSString *total_distance;
@property(nonatomic,retain)NSString *total_fare;
@property(nonatomic,retain)NSString *total_base_fare;
@property(nonatomic,retain)NSString *taxes;


-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
