//
//  ProfileHeaderCell.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import "ProfileHeaderCell.h"
#import <Parse/Parse.h>

@implementation ProfileHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)didTapProfileButton:(id)sender {
    [self.delegate profileHeaderCell:self];
}

@end
