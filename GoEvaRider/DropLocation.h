//
//  DropLocation.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/30/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutocompleteBaseViewController.h"

@protocol senddataProtocol <NSObject>

-(void)sendDatafromDropToDashboard:(GMSPlace *)place;
//-(void)sendDataBackToHomepage:(NSString *)mode;

@end

@interface DropLocation : AutocompleteBaseViewController{
    IBOutlet UIView *DestinationSearchShadow;
    IBOutlet UIButton *btnBack;
    IBOutlet UIImageView *imgDemo;
    IBOutlet UITextField *_searchField;
}
@property (strong, nonatomic) UIWindow *window;
@property(weak) id delegate;

- (IBAction)homePage:(UIButton *)sender;

@end
