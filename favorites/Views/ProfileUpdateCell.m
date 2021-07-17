//
//  ProfileUpdateCell.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import "ProfileUpdateCell.h"

@implementation ProfileUpdateCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *editUpdateButton = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapEditButton:)];
    [self.editUpdateLabel addGestureRecognizer:editUpdateButton];
    [self.editUpdateLabel setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void) didTapEditButton:(UITapGestureRecognizer *)sender{
    [self.delegate didTapEditUpdate:self];
}

@end
