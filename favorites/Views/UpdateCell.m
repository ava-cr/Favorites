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
    // tap user's profile photo to get to their profile
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePicImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePicImageView setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)didTapLocation:(id)sender {
    [self.delegate updateCell:self pressedLocation:self.update];
}
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    [self.delegate updateCell:self didTapUser:self.update.author];
}

@end
