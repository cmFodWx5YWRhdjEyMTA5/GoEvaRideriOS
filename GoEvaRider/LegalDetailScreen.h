//
//  LegalDetailScreen.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/20/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "LegalMaster.h"

@interface LegalDetailScreen : UIViewController{
    
    AppDelegate *appDel;
    LegalMaster *legalObj;
    UIView *loadingView;
    IBOutlet UIWebView *legalView;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSString *legalHelpMenuID;
@property (nonatomic) NSInteger screenModeForLegalHelp;

@end
