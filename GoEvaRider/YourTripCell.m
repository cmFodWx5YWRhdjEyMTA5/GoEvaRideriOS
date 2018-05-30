//
//  YourTripCell.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 9/15/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "YourTripCell.h"

@implementation YourTripCell
@synthesize lblBookingDateTime = _lblBookingDateTime;
@synthesize lblCarTypeBookingNo=_lblCarTypeBookingNo;
@synthesize lblFare=_lblFare;
@synthesize lblPickupLocation=_lblPickupLocation;
@synthesize lblDropLocation=_lblDropLocation;
@synthesize imgCarImage = _imgCarImage;
@synthesize imgDriverImage = _imgDriverImage;
@synthesize imgCancel = _imgCancel;
@synthesize viewCar = _viewCar;
- (void)awakeFromNib {
    [super awakeFromNib];
    _viewCar.layer.cornerRadius = _viewCar.frame.size.width / 2;
    _viewCar.clipsToBounds = YES;
    _viewProfile.layer.cornerRadius = _viewCar.frame.size.width / 2;
    _viewProfile.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
