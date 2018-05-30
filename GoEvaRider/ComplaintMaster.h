//
//  ComplaintMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComplaintMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *complain_token_number;
@property(nonatomic,retain)NSString *title;
@property(nonatomic,retain)NSString *content;
@property(nonatomic,retain)NSString *dateofcomplain;
@property(nonatomic,retain)NSString *response_status;
@property(nonatomic,retain)NSString *status;
@property(nonatomic,retain)NSString *rider_id;
@property(nonatomic,retain)NSString *driver_id;
@property(nonatomic,retain)NSString *car_id;


-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
