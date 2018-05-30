//
//  PaymentCardList.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/2/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>

typedef NS_ENUM(NSInteger, STPBackendChargeResult) {
    STPBackendChargeResultSuccess,
    STPBackendChargeResultFailure,
};

typedef void (^STPSourceSubmissionHandler)(STPBackendChargeResult status, NSError *error);

@protocol ExampleViewControllerDelegate <NSObject>

- (void)exampleViewController:(UIViewController *)controller didFinishWithMessage:(NSString *)message;
- (void)exampleViewController:(UIViewController *)controller didFinishWithError:(NSError *)error;
- (void)createBackendChargeWithSource:(NSString *)sourceID completion:(STPSourceSubmissionHandler)completion;

@end
@interface PaymentCardList : UIViewController

- (IBAction)AddNewCard:(id)sender;

@end
