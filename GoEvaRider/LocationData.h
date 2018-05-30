//
//  LocationData.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 7/17/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocationData : NSObject

@property(nonatomic,retain)NSString *locationAddress;
@property(nonatomic,retain)NSString *latitude;
@property(nonatomic,retain)NSString *longitude;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;
@end
