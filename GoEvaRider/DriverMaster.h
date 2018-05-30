//
//  DriverMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>

@interface DriverMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *driver_id;
@property(nonatomic,retain)NSString *user_type;
@property(nonatomic,retain)NSString *driver_name;
@property(nonatomic,retain)NSString *mobile_no;
@property(nonatomic,retain)NSString *email_id;
@property(nonatomic,retain)NSString *password;
@property(nonatomic,retain)NSString *device_id;
@property(nonatomic,retain)NSString *reg_dt;
@property(nonatomic,retain)NSString *profile_pic;
@property(nonatomic,retain)NSString *driver_licence;
@property(nonatomic,retain)NSString *isowner;
@property(nonatomic,retain)NSString *signup_date;
@property(nonatomic,retain)NSString *device_token;
@property(nonatomic,retain)NSString *device_type;
@property(nonatomic,retain)NSString *status;


-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
