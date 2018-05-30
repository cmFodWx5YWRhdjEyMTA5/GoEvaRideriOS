//
//  HelpDetailsMaster.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/20/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HelpDetailsMaster : NSObject

@property(nonatomic,retain)NSString *id;
@property(nonatomic,retain)NSString *cat_id;
@property(nonatomic,retain)NSString *sub_cat_name;
@property(nonatomic,retain)NSString *content;

-(id)init;
-(id)initWithJsonData:(NSDictionary *)jsonObjects;
-(NSString *)JSONRepresentation;

@end
