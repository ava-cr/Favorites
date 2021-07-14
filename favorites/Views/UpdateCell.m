//
//  UpdateCell.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "UpdateCell.h"

@implementation UpdateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)didTapLocation:(id)sender {
    NSLog(@"tapped location!");
    [self.delegate updateCell:self pressedLocation:self.update];
}

@end
