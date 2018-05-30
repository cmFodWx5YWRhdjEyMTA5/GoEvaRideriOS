//
//  ChangePassword.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface ChangePassword : UIViewController{
    AppDelegate *appDel;
    UIView *loadingView;
    IBOutlet UIButton *btnSave;
}
@property (strong, nonatomic) IBOutlet UITextField *userOldPassword;
@property (strong, nonatomic) IBOutlet UITextField *userNewPassword;
@property (strong, nonatomic) IBOutlet UITextField *userRetypeNewPassword;
@property (strong, nonatomic) UIWindow *window;

- (IBAction)updatePassowrd:(id)sender;
- (IBAction)backToProfile:(UIButton *)sender;

@end
