//
//  CarMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *driver_id;
@property(nonatomic,retain)NSString *car_id;
@property(nonatomic,retain)NSString *seat_capacity;
@property(nonatomic,retain)NSString *car_type_id;
@property(nonatomic,retain)NSString *car_name;
@property(nonatomic,retain)NSString *car_reg_no;
@property(nonatomic,retain)NSString *car_plate_no;
@property(nonatomic,retain)NSString *car_pic;
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *car_category;
@property(nonatomic,retain)NSString *normal_image;
@property(nonatomic,retain)NSString *peak_hour_image;
@property(nonatomic,retain)NSString *driver_name;
@property(nonatomic,retain)NSString *mobile_no;
@property(nonatomic,retain)NSString *email_id;
@property(nonatomic,retain)NSString *profile_pic;
@property(nonatomic,retain)NSString *driver_ratting;
@property(nonatomic,retain)NSString *driver_all_doc_uploaded;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
