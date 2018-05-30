//
//  MyProfileUpdate.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@protocol senddataProtocol2 <NSObject>

-(void)sendDataTobackToDocumentPage2:(NSString *)fieldData documentMode:(NSInteger)documentMode;

@end

@interface MyProfileUpdate : UIViewController{
    AppDelegate *appDel;
    UIView *loadingView;
    IBOutlet UILabel *lblTitle;
    IBOutlet UITextField *txtContent;
    IBOutlet UIButton *btnSave;
    IBOutlet UIView *otpView, *viewForm;
    IBOutlet UITextField *txtOtp;
    IBOutlet UIButton *btnSubmit;
    IBOutlet UIButton *btnClose;
}
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,assign)id delegate;
@property (nonatomic) NSInteger profileMode;
@property (nonatomic) NSString *content;
- (IBAction)closeOTP:(UIButton *)sender;
- (IBAction)saveForm:(UIButton *)sender;
- (IBAction)submitOTP:(UIButton *)sender;
- (IBAction)backToProfile:(UIButton *)sender;

@end
