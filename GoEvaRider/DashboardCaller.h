//
//  DashboardCaller.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 2/7/18.
//  Copyright © 2018 Kalyan Paul. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface DashboardCaller : NSObject{
    AppDelegate *appDel;
}
-(id)init;
+(void)homepageSelector:(UIViewController *)controller;
@end
