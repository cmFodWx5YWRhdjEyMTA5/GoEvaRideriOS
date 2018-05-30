//
//  LegalScreen.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "HelpMaster.h"

@interface LegalScreen : UIViewController{
    AppDelegate *appDel;
    UIView *loadingView;
    HelpMaster *helpObj;
    NSMutableArray *legalArray;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSInteger pageModeForHelpAndLegalMenu;
@property (nonatomic) NSString *helpMenuID;
@property (strong, nonatomic) IBOutlet UITableView *tableLegal;

@end
