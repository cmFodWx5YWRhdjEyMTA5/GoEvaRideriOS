//
//  GlobalVariable.h
//  saltnsoap
//
//  Created by Kalyan Mohan Paul on 2/9/17.
//  Copyright © 2017 Infologic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVariable : NSObject

+(void)setGlobalMessage:(NSString *)message;
+(NSString *)getGlobalMessage;

+(void)setDeviceTokenPushNotification:(NSString *)deviceToken;
+(NSString *)getDeviceTokenPushNotification;

+(void)setBookingID:(NSString *)booking_id;
+(NSString *)getBookingID;

+(NSString *)getUserType;

@end
