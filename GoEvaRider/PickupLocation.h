//
//  SearchLocation.h
//  GoEvaRider
//
//  Created by Kalyan Paul on 20/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutocompleteBaseViewController.h"

@protocol senddataProtocol <NSObject>

-(void)sendDatafromPickupToDashboard:(GMSPlace *)place;
//-(void)sendDataBackToHomepage:(NSString *)mode;

@end

@interface PickupLocation : AutocompleteBaseViewController{
    IBOutlet UIView *DestinationSearchShadow;
    IBOutlet UIButton *btnBack;
    IBOutlet UIImageView *imgDemo;
    IBOutlet UITextField *_searchField;
}
@property (strong, nonatomic) UIWindow *window;
@property(weak) id delegate;

- (IBAction)homePage:(UIButton *)sender;

@end
