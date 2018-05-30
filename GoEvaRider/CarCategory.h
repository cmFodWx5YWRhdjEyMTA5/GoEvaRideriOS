//
//  CarCategory.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarCategory : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *car_category;
@property(nonatomic,retain)NSString *normal_image;
@property(nonatomic,retain)NSString *peak_hour_image;
@property(nonatomic,retain)NSString *status;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
