//
//  CardCell.m
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/15/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import "CardCell.h"

@implementation CardCell

@synthesize lblCardHolderName = _lblCardHolderName;
@synthesize lblLast4Digit=_lblLast4Digit;
@synthesize imgCheck=_imgCheck;
@synthesize imgCard=_imgCard;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
