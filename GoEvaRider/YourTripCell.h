//
//  YourTripCell.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/15/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YourTripCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblBookingDateTime;
@property (strong, nonatomic) IBOutlet UILabel *lblCarTypeBookingNo;
@property (strong, nonatomic) IBOutlet UILabel *lblFare;
@property (strong, nonatomic) IBOutlet UILabel *lblPickupLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblDropLocation;
@property (strong, nonatomic) IBOutlet UIImageView *imgCarImage;
@property (strong, nonatomic) IBOutlet UIImageView *imgDriverImage;
@property (strong, nonatomic) IBOutlet UIImageView *imgCancel;
@property (strong, nonatomic) IBOutlet UIView *viewCar, *viewProfile;
@end
