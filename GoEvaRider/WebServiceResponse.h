//
//  WebServiceResponse.h
//  EditFX
//
//  Created by Kalyan Mohan Paul on 4/27/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebServiceResponse : NSObject

@property(nonatomic, retain)NSString *StatusCode;
@property(nonatomic, retain)NSString *Data;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;


@end
