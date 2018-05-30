//
//  PayNow.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/21/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "PayNow.h"
#import <AFNetworking/AFNetworking.h>
#import "Dashboard.h"
#import "MFSideMenu.h"
#import "SideMenuViewController.h"
#import "Constant.h"
#import "MyUtils.h"
#import <Stripe/Stripe.h>
#import "AddCard.h"
#import "CardMaster.h"
#import "DataStore.h"
#import "Payment.h"
#import "RateUsDriver.h"
#import "DashboardCaller.h"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

@interface PayNow ()

@end

@implementation PayNow{
    NSArray *cardBrand;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:activityIndicator];
    cardBrand = [NSArray arrayWithObjects:@"Visa", @"MasterCard",@"JCB", @"Diners Club", @"Discover",@"American Express", nil];
    tableViewCard.separatorStyle=NO;
    [imgCard setHidden:YES];
    [lblCardNameWithLast4 setHidden:YES];
    [lblDontHaveCard setHidden:YES];
    [btnAddOrChangeCard setHidden:YES];
    btnPayNow.layer.cornerRadius = 10;
    lblPrice.text = [NSString stringWithFormat:@"$%.2f",self.amount];
    lblPaymentDesc.text = [NSString stringWithFormat:@"You are about to send $%.2f securely to GoEva App.",self.amount];
    [self getDefaultCard];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)getDefaultCard{
    
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    [activityIndicator startAnimating];
    [self.view setUserInteractionEnabled:NO];
    NSString *URL = [NSString stringWithFormat:@"%@get_default_card.php",BackendBaseURL];
    NSDictionary *params =  @{
                              @"rider_id": [MyUtils getUserDefault:@"riderID"]
                              };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //NSLog(@"Object: %@", responseObject);
        
        if ([[responseObject valueForKey:@"status"] isEqualToString:@"0"]) {
            _modeAddCard = 0;
            NSData *JSONdata = [[responseObject valueForKey:@"Mycard"] dataUsingEncoding:NSUTF8StringEncoding];
            if (JSONdata != nil) {
                NSError * error =nil;
                
                NSMutableArray *jsonUserInfo = [NSJSONSerialization JSONObjectWithData:JSONdata options:NSJSONReadingMutableLeaves error:&error];
                NSMutableArray * arr = [[NSMutableArray alloc]init];
                for (int i = 0; i < [jsonUserInfo count]; i++) {
                    CardMaster * fund = [[CardMaster alloc] initWithJsonData:[jsonUserInfo objectAtIndex:i]];
                    [arr addObject:fund];
                }
                [[DataStore sharedInstance] addCards:arr];
            }
            [self setData];
        }
        else{
            [activityIndicator stopAnimating];
            [self.view setUserInteractionEnabled:YES];
            _modeAddCard = 1;
            [imgCard setHidden:YES];
            [lblCardNameWithLast4 setHidden:YES];
            [btnAddOrChangeCard setTitle:@"Add New Card" forState:UIControlStateNormal];
            [btnAddOrChangeCard setHidden:NO];
            [lblDontHaveCard setHidden:NO];
            btnPayNow.backgroundColor = [UIColor lightGrayColor];
            btnPayNow.titleLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5];
            [btnPayNow setUserInteractionEnabled:NO];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self exampleViewController:self didFinishWithError:error];
    }];
    
}

-(void)setData{
    [self.view setUserInteractionEnabled:YES];
    [activityIndicator stopAnimating];
    [imgCard setHidden:NO];
    [lblCardNameWithLast4 setHidden:NO];
    [btnAddOrChangeCard setHidden:NO];
    [lblDontHaveCard setHidden:YES];
    btnPayNow.backgroundColor = UIColorFromRGB(0xCC3333);
    btnPayNow.titleLabel.textColor = [UIColor whiteColor];
    [btnPayNow setUserInteractionEnabled:YES];
    [btnAddOrChangeCard setTitle:@"Change Card" forState:UIControlStateNormal];
    cardArray = [NSMutableArray arrayWithArray:[[DataStore sharedInstance] getAllCard]];
    /* CardMaster * cardObj;
    for (int i=0; i<cardArray.count; i++) {
        if ([[[cardArray objectAtIndex:i] valueForKey:@"default_source"] isEqualToString:@"1"]) {
            cardObj = [cardArray objectAtIndex:i];
        }
        else{
            return;
        }
    }*/
    CardMaster * cardObj = [cardArray objectAtIndex:0];
    NSInteger item = [cardBrand indexOfObject:[cardObj valueForKey:@"brand"]];
    switch (item) {
        case 0:
            imgCard.image = [UIImage imageNamed:@"card_visa"];
            break;
        case 1:
            imgCard.image = [UIImage imageNamed:@"card_mastercard"];
            break;
        case 2:
            imgCard.image = [UIImage imageNamed:@"card_jcb"];
            break;
        case 3:
            imgCard.image = [UIImage imageNamed:@"card_diners"];
            break;
        case 4:
            imgCard.image = [UIImage imageNamed:@"card_discover"];
            break;
        case 5:
            imgCard.image = [UIImage imageNamed:@"card_amex"];
            break;
        default:
            imgCard.image = [UIImage imageNamed:@"card_unknown"];
            break;
    }
    
    UIColor *color = [UIColor blueColor];
    NSString *card = @"Card";
    NSString *endingIn = @"Ending In";
    
    NSString *lblCardDetails = [NSString stringWithFormat:@"%@ %@ XXXX%@",card,endingIn,[cardObj valueForKey:@"last4"]];
    NSMutableAttributedString *mutAttrStr = [[NSMutableAttributedString alloc]initWithString:lblCardDetails attributes:nil];
    NSString *endingShortStr = endingIn;
    NSDictionary *attributes = @{NSForegroundColorAttributeName:color};
    [mutAttrStr setAttributes:attributes range:NSMakeRange([card length]+1, endingShortStr.length)];
    lblCardNameWithLast4.attributedText = mutAttrStr;
}

- (IBAction)AddOrChangeCard:(id)sender{

    if (_modeAddCard==1) {
        AddCard *addController;
        if (appDel.iSiPhone5) {
            addController = [[AddCard alloc] initWithNibName:@"AddCard" bundle:nil];
        }
        else{
            addController = [[AddCard alloc] initWithNibName:@"AddCardLow" bundle:nil];
        }
        addController.AddCardMode = 2;
        addController.delegate=self;
        addController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:addController animated:YES completion:nil];
    }
    else if(_modeAddCard==0){
        Payment *paymentController;
        if (appDel.iSiPhone5) {
            paymentController = [[Payment alloc] initWithNibName:@"Payment" bundle:nil];
        }
        else{
            paymentController = [[Payment alloc] initWithNibName:@"PaymentLow" bundle:nil];
        }
        paymentController.delegate=self;
        paymentController.setDefaultCardMode=1;
        paymentController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        [self presentViewController:paymentController animated:YES completion:nil];
    }
    
}

-(void)sendDatafromAddCardToPayNowPage
{
    [self getDefaultCard];
}

-(void)sendDatafromCardListToPayNowPage
{
    [self getDefaultCard];
}


- (IBAction)payNow:(id)sender {
    
    if (!BackendBaseURL) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{NSLocalizedDescriptionKey: @"You must set a backend base URL in Constants.m to create a charge."}];
        [self exampleViewController:self didFinishWithError:error];
        return;
    }
    loadingView = [MyUtils customLoaderFullWindowWithText:self.window loadingText:@"Processing..."];
    [self.view addSubview:loadingView];
    NSString *URL = [NSString stringWithFormat:@"%@payment.php",BackendBaseURL];
    NSDictionary *params =  @{
                              @"rider_id": [MyUtils getUserDefault:@"riderID"],
                              @"booking_id": _bookingID,
                              @"amount": [NSNumber numberWithDouble:self.amount],
                              @"currency": @"usd",
                              @"description":[MyUtils getUserDefault:@"riderMobileNo"]
                              };
    
    
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
    NSString *lblTitle;
    if ([[responseObject objectForKey:@"status"] isEqualToString:@"0"])
        lblTitle=@"Success!!!";
    else
        lblTitle=@"Failure";
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:lblTitle message:[responseObject objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        if ([[responseObject objectForKey:@"status"] isEqualToString:@"0"]) {
            //[self homepageSelector];
            RateUsDriver *rateUs;
            if (appDel.iSiPhone5) {
                rateUs = [[RateUsDriver alloc] initWithNibName:@"RateUsDriver" bundle:nil];
            }
            else{
                rateUs = [[RateUsDriver alloc] initWithNibName:@"RateUsDriverLow" bundle:nil];
            }
            rateUs.bookingID = _bookingID;
            rateUs.driverImage = _driverImage;
            rateUs.driverName = _driverName;
            rateUs.screenMode = @"0";
            rateUs.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
            [self presentViewController:rateUs animated:YES completion:nil];
        }
        else{
            
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

- (IBAction)backToPage:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)rateUsDriver{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
