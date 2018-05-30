//
//  Payment.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 6/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Stripe/Stripe.h>

@protocol payNowMode <NSObject>
-(void)sendDatafromCardListToPayNowPage;
@end

@interface Payment : UIViewController{
    AppDelegate *appDel;
    IBOutlet UIButton *btnAddCard;
    NSMutableArray *cardArray;
    UIView *loadingView;
    IBOutlet UIView *innerView, *viewSwipeDelete;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSInteger setDefaultCardMode;
@property (strong, nonatomic) IBOutlet UITableView *tableViewCard;
@property(nonatomic,assign)id delegate;
- (IBAction)addCard:(id)sender;
- (IBAction)backToHome:(UIButton *)sender;
@end
