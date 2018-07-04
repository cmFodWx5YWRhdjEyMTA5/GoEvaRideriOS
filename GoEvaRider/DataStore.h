//
//  DataStore.h
//  EditFX
//
//  Created by Kalyan Mohan Paul on 4/27/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DriverMaster.h"
#import "CarMaster.h"
#import "RiderMaster.h"
#import "CarCategory.h"
#import "ComplaintMaster.h"
#import "CarAvailablity.h"
#import "CancelReason.h"
#import "BookingMaster.h"
#import "LegalMaster.h"
#import "HelpMaster.h"
#import "BookingDetailMaster.h"
#import "CardMaster.h"
#import "DriverLiveLocation.h"
#import "SettingMaster.h"

@interface DataStore : NSObject{
    
    NSMutableDictionary *driverDict;
    NSMutableDictionary *riderDict;
    NSMutableDictionary *carCategoryDict;
    NSMutableDictionary *complaintDict;
    NSMutableDictionary *carDict;
    NSMutableDictionary *carAvailablityDict;
    NSMutableDictionary *cancelDict;
    NSMutableDictionary *bookingDict;
    NSMutableDictionary *legalDict;
    NSMutableDictionary *helpDict;
    NSMutableDictionary *cardDict;
    NSMutableDictionary *driverLiveLocationDict;
    NSMutableDictionary *settingDict;
    
}
+ (id)sharedInstance;

//For Top Menu

-(void)addDriver:(NSArray *)driverArray;
-(NSArray *)getAllDriver;
-(DriverMaster *)getDriverByID:(NSString *)ID;

-(void)addRider:(NSArray *)riderArray;
-(NSArray *)getRider;
-(RiderMaster *)getRiderByID:(NSString *)ID;

-(void)addCarCategory:(NSArray *)carCategoryArray;
-(NSArray *)getAllCarCategory;
-(CarCategory *)getCarCategoryByID:(NSString *)ID;

-(void)addComplaint:(NSArray *)complaintArray;
-(NSArray *)getAllComplaint;
-(ComplaintMaster *)getComplaintByID:(NSString *)ID;

-(void)addCar:(NSArray *)carArray;
-(NSArray *)getAllCar;
-(CarMaster *)getCarByID:(NSString *)ID;

-(void)addCarAvailablity:(NSArray *)carAvailablityArray;
-(NSArray *)getAllCarAvailablity;
-(CarAvailablity *)getCarAvailablityByID:(NSString *)ID;

-(void)addCancelReason:(NSArray *)cancelReasonArray;
-(NSArray *)getAllCancelReason;
-(CancelReason *)getCancelReasonByID:(NSString *)ID;


-(void)addLegalMenu:(NSArray *)legalMenuArray;
-(NSArray *)getAllLegalMenu;
-(LegalMaster *)getLegalMenuByID:(NSString *)ID;

-(void)addHelpMenu:(NSArray *)helpMenuArray;
-(NSArray *)getAllHelpMenu;
-(HelpMaster *)getHelpMenuByID:(NSString *)ID;

-(void)addBookig:(NSArray *)bookingArray;
-(NSArray *)getAllBooking;
-(BookingDetailMaster *)getBookingByID:(NSString *)ID;

-(void)addCards:(NSArray *)cardArray;
-(NSArray *)getAllCard;
-(CardMaster *)getCardByID:(NSString *)ID;

-(void)addDriverLiveLocation:(NSArray *)driverArray;
-(NSArray *)getDriverLiveLocation;

-(void)addSetting:(NSArray *)settingArray;
-(NSArray *)getSetting;
@end
