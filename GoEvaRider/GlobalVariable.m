//
//  GlobalVariable.m
//  saltnsoap
//
//  Created by Kalyan Mohan Paul on 2/9/17.
//  Copyright © 2017 Infologic. All rights reserved.
//

#import "GlobalVariable.h"

#define USER_TYPE  @"1";

@implementation GlobalVariable

static NSString *globalMessage;
static NSString *deviceTokenStatic;
static NSString *bookingID;

+(void)setGlobalMessage:(NSString *)message{
    globalMessage=message;
}

+(NSString *)getGlobalMessage{
    return globalMessage;
}

+(void)setDeviceTokenPushNotification:(NSString *)deviceToken{
    deviceTokenStatic=deviceToken;
}

+(NSString *)getDeviceTokenPushNotification{
    return deviceTokenStatic;
}

+(void)setBookingID:(NSString *)booking_id{
    bookingID=booking_id;
}

+(NSString *)getBookingID{
    return bookingID;
}

+(NSString *)getUserType{
    return USER_TYPE;
}

@end
