//
//  FriendRequestCell.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import "FriendRequestCell.h"

@implementation FriendRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)acceptTapped:(id)sender {
    [self.delegate friendRequestCell:self pressedAccept:self.request];
    [self.acceptButton setEnabled:FALSE];
}

@end
