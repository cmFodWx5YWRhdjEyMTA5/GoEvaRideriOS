//
//  Constant.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/2/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "Constant.h"

// This can be found at https://dashboard.stripe.com/account/apikeys
 NSString *const StripePublishableKey = @"pk_test_rNbFsHsp4zedsw2wUCXBFfUE"; // TODO: Test API Key

 //NSString *const StripePublishableKey = @"pk_live_9LYxnGra38OMccKgjPXNX2Tq"; // TODO: Live API Key

// To set this up, check out https://github.com/stripe/example-ios-backend
// This should be in the format https://my-shiny-backend.herokuapp.com

 NSString *const BackendBaseURL = @"http://goeva.co/goevaapp/stripe_payment_service-beta/"; // TODO: Beta Link

 //NSString *const BackendBaseURL = @"http://goeva.co/goevaapp/stripe_payment_service/"; // TODO: Live Link


// To learn how to obtain an Apple Merchant ID, head to https://stripe.com/docs/mobile/apple-pay
NSString *const AppleMerchantId = nil; // TODO: replace nil with your own value
