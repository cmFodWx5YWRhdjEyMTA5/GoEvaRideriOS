//
//  SettingMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/2/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *search_radius;
@property(nonatomic,retain)NSString *cancellation_charge;
@property(nonatomic,retain)NSString *min_duration_for_cancellation_charge;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
