//
//  CardCell.h
//  GoEvaRider
//
//  Created by Kalyan Mohan Paul on 11/15/17.
//  Copyright © 2017 Kalyan Paul. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *lblLast4Digit;
@property (strong, nonatomic) IBOutlet UILabel *lblCardHolderName;
@property (strong, nonatomic) IBOutlet UIImageView *imgCard;
@property (strong, nonatomic) IBOutlet UIImageView *imgCheck;

@end
