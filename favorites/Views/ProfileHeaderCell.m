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
    
    UITapGestureRecognizer *friendsLabelTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapFriends:)];
    [self.numFriendsLabel addGestureRecognizer:friendsLabelTap];
    [self.numFriendsLabel setUserInteractionEnabled:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)didTapProfileButton:(id)sender {
    [self.delegate tappedProfileButton:self];
}

- (void) didTapFriends:(UITapGestureRecognizer *)sender{
    [self.delegate tappedFriends:self];
}

@end
