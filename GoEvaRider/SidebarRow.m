//
//  SidebarRow.m
//  EditFX
//
//  Created by Kalyan Mohan Paul on 11/10/16.
//  Copyright © 2016 Infologic. All rights reserved.
//

#import "SidebarRow.h"

@implementation SidebarRow

@synthesize menuImage = _menuImage;
@synthesize menuName = _menuName;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
