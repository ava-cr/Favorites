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
    UITapGestureRecognizer *doubleTapToLike = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didLikeUpdate:)];
    [self.picImageView addGestureRecognizer:doubleTapToLike];
    [doubleTapToLike setNumberOfTapsRequired:2];
    [self.picImageView setUserInteractionEnabled:YES];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void) didTapEditButton:(UITapGestureRecognizer *)sender{
    [self.delegate didTapEditUpdate:self];
}
- (void) didLikeUpdate:(UITapGestureRecognizer *)sender{
    NSLog(@"like image!");
    [self.delegate updateCell:self likedUpdate:self.update];
}
- (IBAction)didTapComments:(id)sender {
    [self.delegate pressedComments:self];
}

@end
