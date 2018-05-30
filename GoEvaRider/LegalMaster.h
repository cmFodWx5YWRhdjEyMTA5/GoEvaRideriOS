//
//  LegalMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/19/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LegalMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *cat_name;
@property(nonatomic,retain)NSString *content;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
