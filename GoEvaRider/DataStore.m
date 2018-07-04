//
//  DataStore.m
//  EditFX
//
//  Created by Kalyan Mohan Paul on 4/27/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import "DataStore.h"


@implementation DataStore

+ (id)sharedInstance {
    static DataStore *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        driverDict = [[NSMutableDictionary alloc] init];
        riderDict = [[NSMutableDictionary alloc] init];
        carCategoryDict = [[NSMutableDictionary alloc] init];
        complaintDict = [[NSMutableDictionary alloc] init];
        carDict = [[NSMutableDictionary alloc] init];
        carAvailablityDict = [[NSMutableDictionary alloc] init];
        cancelDict = [[NSMutableDictionary alloc] init];
        bookingDict = [[NSMutableDictionary alloc] init];
        legalDict = [[NSMutableDictionary alloc] init];
        helpDict = [[NSMutableDictionary alloc] init];
        cardDict = [[NSMutableDictionary alloc] init];
        driverLiveLocationDict = [[NSMutableDictionary alloc] init];
        settingDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}


#pragma mark instance methods

 -(void)addDriver:(NSArray *)driverArray
{
    [driverDict removeAllObjects];
    if (driverArray != nil && [driverArray count] > 0)
    {
        for (int  i= 0; i< [driverArray count]; i++)
        {
            
            DriverMaster * fund = [driverArray objectAtIndex:i];
            
            [driverDict setValue:fund forKey:fund.id];
            
        }
    }
}

-(NSArray *)getAllDriver
{
    return [driverDict allValues];
}

-(DriverMaster *)getDriverByID:(NSString *)ID
{
    DriverMaster *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [driverDict valueForKey:ID];
    }
    
    return fund;
}

/* Car Availablity */

#pragma mark instance methods

-(void)addCarAvailablity:(NSArray *)carAvailablityArray
{
    [carAvailablityDict removeAllObjects];
    if (carAvailablityArray != nil && [carAvailablityArray count] > 0)
    {
        for (int  i= 0; i< [carAvailablityArray count]; i++)
        {
            
            CarAvailablity * fund = [carAvailablityArray objectAtIndex:i];
            
            [carAvailablityDict setValue:fund forKey:fund.id];
            
        }
    }
}

-(NSArray *)getAllCarAvailablity
{
    return [carAvailablityDict allValues];
}

-(CarAvailablity *)getCarAvailablityByID:(NSString *)ID
{
    CarAvailablity *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [carAvailablityDict valueForKey:ID];
    }
    
    return fund;
}

/* Car Details */

#pragma mark instance methods

-(void)addCar:(NSArray *)carArray
{
    [carDict removeAllObjects];
    if (carArray != nil && [carArray count] > 0)
    {
        for (int  i= 0; i< [carArray count]; i++)
        {
            
            CarMaster * fund = [carArray objectAtIndex:i];
            
            [carDict setValue:fund forKey:fund.id];
            
        }
    }
}

-(NSArray *)getAllCar
{
    return [carDict allValues];
}

-(CarMaster *)getCarByID:(NSString *)ID
{
    CarMaster *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [carDict valueForKey:ID];
    }
    
    return fund;
}

/* Rider Details */

#pragma mark instance methods

-(void)addRider:(NSArray *)riderArray
{
    [riderDict removeAllObjects];
    if (riderArray != nil && [riderArray count] > 0)
    {
        for (int  i= 0; i< [riderArray count]; i++)
        {
            
            RiderMaster * fund = [riderArray objectAtIndex:i];
            
            [riderDict setValue:fund forKey:fund.id];
            
        }
    }
}

-(NSArray *)getRider
{
    return [riderDict allValues];
}

-(RiderMaster *)getRiderByID:(NSString *)ID
{
    RiderMaster *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [riderDict valueForKey:ID];
    }
    
    return fund;
}

/* Cancel reason list */

#pragma mark instance methods

-(void)addCancelReason:(NSArray *)cancelReasonArray
{
    [cancelDict removeAllObjects];
    if (cancelReasonArray != nil && [cancelReasonArray count] > 0)
    {
        for (int  i= 0; i< [cancelReasonArray count]; i++)
        {
            CancelReason * fund = [cancelReasonArray objectAtIndex:i];
            [cancelDict setValue:fund forKey:fund.id];
        }
    }
}

-(NSArray *)getAllCancelReason
{
    return [cancelDict allValues];
}

-(CancelReason *)getCancelReasonByID:(NSString *)ID
{
    CancelReason *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [cancelDict valueForKey:ID];
    }
    
    return fund;
}

#pragma For Legal Menu

-(void)addLegalMenu:(NSArray *)legalMenuArray
{
    [legalDict removeAllObjects];
    if (legalMenuArray != nil && [legalMenuArray count] > 0)
    {
        for (int  i= 0; i< [legalMenuArray count]; i++)
        {
            LegalMaster * fund = [legalMenuArray objectAtIndex:i];
            [legalDict setValue:fund forKey:fund.id];
        }
    }
}

-(NSArray *)getAllLegalMenu
{
    return [legalDict allValues];
}

-(LegalMaster *)getLegalMenuByID:(NSString *)ID
{
    LegalMaster *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [legalDict valueForKey:ID];
    }
    
    return fund;
}


#pragma For Help Menu

-(void)addHelpMenu:(NSArray *)helpMenuArray
{
    [helpDict removeAllObjects];
    if (helpMenuArray != nil && [helpMenuArray count] > 0)
    {
        for (int  i= 0; i< [helpMenuArray count]; i++)
        {
            HelpMaster * fund = [helpMenuArray objectAtIndex:i];
            [helpDict setValue:fund forKey:fund.id];
        }
    }
}

-(NSArray *)getAllHelpMenu
{
    return [helpDict allValues];
}

-(HelpMaster *)getHelpMenuByID:(NSString *)ID
{
    HelpMaster *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [helpDict valueForKey:ID];
    }
    
    return fund;
}

#pragma For Get Trip

-(void)addBookig:(NSArray *)bookingArray
{
    [bookingDict removeAllObjects];
    if (bookingArray != nil && [bookingArray count] > 0)
    {
        for (int  i= 0; i< [bookingArray count]; i++)
        {
            BookingDetailMaster * fund = [bookingArray objectAtIndex:i];
            [bookingDict setValue:fund forKey:fund.booking_id];
        }
    }
}

-(NSArray *)getAllBooking
{
    return [bookingDict allValues];
}

-(BookingDetailMaster *)getBookingByID:(NSString *)ID
{
    BookingDetailMaster *fund;
    
    if (ID != nil && ![ID isEqualToString:@""]) {
        
        fund = [bookingDict valueForKey:ID];
    }
    
    return fund;
}

-(void)setObject:(BookingDetailMaster *)bookDetailObj{
    [bookingDict setValue:bookDetailObj forKey:bookDetailObj.booking_id];
}


#pragma For Get Cards

-(void)addCards:(NSArray *)cardArray
{
    [cardDict removeAllObjects];
    if (cardArray != nil && [cardArray count] > 0)
    {
        for (int  i= 0; i< [cardArray count]; i++)
        {
            CardMaster * fund = [cardArray objectAtIndex:i];
            [cardDict setValue:fund forKey:fund.id];
        }
    }
}

-(NSArray *)getAllCard
{
    return [cardDict allValues];
}

-(CardMaster *)getCardByID:(NSString *)ID
{
    CardMaster *fund;
    if (ID != nil && ![ID isEqualToString:@""]) {
        fund = [cardDict valueForKey:ID];
    }
    return fund;
}

#pragma Add Driver Live Location

-(void)addDriverLiveLocation:(NSArray *)driverArray
{
    [driverLiveLocationDict removeAllObjects];
    if (driverArray != nil && [driverArray count] > 0)
    {
        for (int  i= 0; i< [driverArray count]; i++)
        {
            DriverLiveLocation * fund = [driverArray objectAtIndex:i];
            [driverLiveLocationDict setValue:fund forKey:fund.id];
        }
    }
}

-(NSArray *)getDriverLiveLocation
{
    return [driverLiveLocationDict allValues];
}

#pragma Add Setting

-(void)addSetting:(NSArray *)settingArray
{
    [settingDict removeAllObjects];
    if (settingArray != nil && [settingArray count] > 0)
    {
        for (int  i= 0; i< [settingArray count]; i++)
        {
            SettingMaster * fund = [settingArray objectAtIndex:i];
            [settingDict setValue:fund forKey:fund.id];
        }
    }
}

-(NSArray *)getSetting
{
    return [settingDict allValues];
}
@end
