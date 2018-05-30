//
//  CancelReason.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/11/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CancelReason : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *cancel_reason;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
