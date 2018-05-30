//
//  CardMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/17/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CardMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *brand;
@property(nonatomic,retain)NSString *country;
@property(nonatomic,retain)NSString *customer_id;
@property(nonatomic,retain)NSString *rider_id;
@property(nonatomic,retain)NSString *exp_month;
@property(nonatomic,retain)NSString *exp_year;
@property(nonatomic,retain)NSString *funding;
@property(nonatomic,retain)NSString *last4;
@property(nonatomic,retain)NSString *card_holder_name;
@property(nonatomic,retain)NSString *default_source;
@property(nonatomic,retain)NSString *first_name;
@property(nonatomic,retain)NSString *last_name;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
