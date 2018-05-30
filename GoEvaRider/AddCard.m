//
//  AddCard.m
//  GoEvaRider
//
//  Created by Kalyan Paul on 12/06/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "AddCard.h"
#import "Dashboard.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "Payment.h"
#import "UIView+Toast.h"
#import "Constant.h"
#import "MyUtils.h"
#import <AFNetworking/AFNetworking.h>
#import "DashboardCaller.h"

@interface AddCard ()<STPPaymentCardTextFieldDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIScrollView *scrollView;
@end

@implementation AddCard
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    viewAlertAddCard.frame = CGRectMake(0, 490, 320, 252);
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         viewAlertAddCard.frame = CGRectMake(0, 25, 320, 252);
                     }
                     completion:^(BOOL finished){
                     }];
    [innerView addSubview:viewAlertAddCard];
    UIBezierPath *shadowPath3 = [UIBezierPath bezierPathWithRect:viewAlertAddCard.bounds];
    
    viewInnerAlertAddCard.layer.masksToBounds = NO;
    viewInnerAlertAddCard.layer.shadowColor = [UIColor blackColor].CGColor;
    viewInnerAlertAddCard.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    viewInnerAlertAddCard.layer.shadowOpacity = 0.2f;
    viewInnerAlertAddCard.layer.shadowPath = shadowPath3.CGPath;
    viewInnerAlertAddCard.layer.cornerRadius = 5;
    

    viewCardNumber.layer.cornerRadius = 5;
    viewCardNumber.layer.borderColor = [UIColor grayColor].CGColor;
    viewCardNumber.layer.borderWidth =1.0;
    
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    paymentTextField.cursorColor = [UIColor purpleColor];
    paymentTextField.postalCodeEntryEnabled = YES;
    self.paymentTextField = paymentTextField;
    [viewCardNumber addSubview:paymentTextField];
    
    viewFirstName.layer.cornerRadius = 5;
    viewFirstName.layer.borderColor = [UIColor grayColor].CGColor;
    viewFirstName.layer.borderWidth =1.0;
    
    viewLastname.layer.cornerRadius = 5;
    viewLastname.layer.borderColor = [UIColor grayColor].CGColor;
    viewLastname.layer.borderWidth =1.0;
    
    viewCardName.layer.cornerRadius = 5;
    viewCardName.layer.borderColor = [UIColor grayColor].CGColor;
    viewCardName.layer.borderWidth =1.0;
    if (_AddCardMode==0) {
        [btnClose setTitle:@"Skip" forState:UIControlStateNormal];
    }
    else{
        [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat padding = 15;
    CGRect bounds = self.view.bounds;
    self.paymentTextField.frame = CGRectMake(0, 0, 285, 44);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.paymentTextField becomeFirstResponder];
}

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    //self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
}

- (IBAction)AddCard:(UIButton *)sender{
    
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:STPErrorMessageKey
                                             code:STPAPIError
                                         userInfo:@{NSLocalizedDescriptionKey: @"Please set a Stripe Publishable Key in Constants.m"}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    if (![self.paymentTextField isValid]) {
        [self.view makeToast:@"Card details is not valid."
                    duration:3.0
                    position:CSToastPositionTop];
        return;
    }
    if ([txtFirstName.text isEqualToString:@""] || [[txtFirstName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ||
        [txtLastName.text isEqualToString:@""] || [[txtLastName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ||
        [txtCardName.text isEqualToString:@""] || [[txtCardName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] ) {
        
        [self.view makeToast:@"All fields are necessary."
                    duration:3.0
                    position:CSToastPositionTop];
        return;
    }
    [txtFirstName resignFirstResponder];
    [txtLastName resignFirstResponder];
    [txtCardName resignFirstResponder];
    loadingView = [MyUtils customLoaderWithText:self.window loadingText:@"Adding..."];
    [self.view addSubview:loadingView];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error == nil) {
                                                  //NSLog(@"MyToken : %@",token);
                                                  [self postStripeTokenForAddCard:token.tokenId];
                                              }
                                              else{
                                                  [self exampleViewController:self didFinishWithError:error];
                                                  return;
                                              }
                                          }];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}


-(void) postStripeTokenForAddCard:(NSString *)tokenID {
    
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    NSString *URL = [NSString stringWithFormat:@"%@add_card.php",BackendBaseURL];
    NSDictionary *params =  @{@"stripeToken": tokenID,
                              @"rider_id": [MyUtils getUserDefault:@"riderID"],
                              @"first_name": txtFirstName.text,
                              @"last_name": txtLastName.text,
                              @"card_holder_name": txtCardName.text};

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Object: %@", responseObject);
        [self exampleViewController:self didFinishWithMessage:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self exampleViewController:self didFinishWithError:error];
    }];
    
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithMessage:(id)responseObject {
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[responseObject objectForKey:@"status"] message:[responseObject objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            if (self.AddCardMode==0) {// For go to home page
                [DashboardCaller homepageSelector:self];
            }
            else if (self.AddCardMode==1){ // For back to card List
                 [delegate sendDatafromAddCardToCardList];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else if (self.AddCardMode==2){ // For back to PayNow Page
                [delegate sendDatafromAddCardToPayNowPage];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            
        }];
        [alertController addAction:action];
        [controller presentViewController:alertController animated:YES completion:nil];
    
}

- (void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error {
    [loadingView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
            //[self.navigationController popViewControllerAnimated:YES];
        }];
        [alertController addAction:action];
        [controller presentViewController:alertController animated:YES completion:nil];
    
}

// Delegate Method of TextField
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)closeAlert:(UIButton *)sender{
    if (self.AddCardMode==0) {
        [DashboardCaller homepageSelector:self];
    }
    else{
    [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
