//
//  CardPaymentNow.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/2/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ExampleViewControllerDelegate;

@interface CardPaymentNow : UIViewController

@property (nonatomic, weak) id<ExampleViewControllerDelegate> delegate;

@end
