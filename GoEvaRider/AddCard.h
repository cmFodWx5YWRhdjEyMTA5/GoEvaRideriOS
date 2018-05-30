//
//  AddCard.h
//  GoEvaRider
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Stripe/Stripe.h>

@protocol refereshCardList <NSObject>
-(void)sendDatafromAddCardToCardList;
-(void)sendDatafromAddCardToPayNowPage;
@end

@interface AddCard : UIViewController{
    AppDelegate *appDel;
    IBOutlet UIView *innerView;
    IBOutlet UIView *viewCardNumber, *viewFirstName, *viewLastname, *viewCardName;
    IBOutlet UIButton *btnClose, *btnAdd;
    IBOutlet UIView *viewAlertAddCard, *viewInnerAlertAddCard;
    IBOutlet UITextField *txtFirstName, *txtLastName, *txtCardName;
    UIView *loadingView;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NSInteger AddCardMode;
@property(nonatomic,assign)id delegate;

- (IBAction)AddCard:(UIButton *)sender;
- (IBAction)closeAlert:(UIButton *)sender;

@end
