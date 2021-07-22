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
    // gesture recognizers: tap user's profile photo to get to their profile & double tap to like an update
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePicImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePicImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *doubleTapToLike = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didLikeUpdate:)];
    [self.picImageView addGestureRecognizer:doubleTapToLike];
    [doubleTapToLike setNumberOfTapsRequired:2];
    [self.picImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapLikeLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapLikeLabel:)];
    [self.likedLabel addGestureRecognizer:tapLikeLabel];
    [self.likedLabel setUserInteractionEnabled:YES];
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
- (void) didLikeUpdate:(UITapGestureRecognizer *)sender{
    NSLog(@"like image!");
    [self.delegate updateCell:self likedUpdate:self.update];
}
- (IBAction)didTapComments:(id)sender {
    [self.delegate pressedComments:self];
}
- (void)didTapLikeLabel:(UITapGestureRecognizer *)sender {
    [self.delegate pressedLikeLabel:self];
}

@end
