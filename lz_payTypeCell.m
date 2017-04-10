//
//  lz_payTypeCell.m
//  videoshow
//
//  Created by gutou on 2017/3/29.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_payTypeCell.h"

@implementation lz_payTypeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected == YES) {
        
        self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessView_selected"]];
        
    }else {
        
        UILabel *accLab = [UILabel new];
        accLab.frame = CGRectMake(0, 0, 15, 15);
        accLab.layer.borderColor = UIColorFromRGB(0x929292).CGColor;
        accLab.layer.borderWidth = 0.5;
        accLab.layer.cornerRadius = 7.5;
        self.accessoryView = accLab;
    }
}

@end
