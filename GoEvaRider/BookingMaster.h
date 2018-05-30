//
//  BookingMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookingMaster : NSObject

@property(nonatomic,retain)NSString *booking_id;
@property(nonatomic,retain)NSString *booking_date;
@property(nonatomic,retain)NSString *booking_time;
@property(nonatomic,retain)NSString *car_name;
@property(nonatomic,retain)NSString *total_fare;
@property(nonatomic,retain)NSString *pickup_location;
@property(nonatomic,retain)NSString *drop_location;
@property(nonatomic,retain)NSString *ride_start_time;
@property(nonatomic,retain)NSString *ride_completion_time;
@property(nonatomic,retain)NSString *booking_status; // Cancel or Complete
@property(nonatomic,retain)NSString *driver_rating;


-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
