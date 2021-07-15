//
//  AddFriendCell.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "AddFriendCell.h"

@implementation AddFriendCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
- (IBAction)didTapAddFriend:(id)sender {
    [self.delegate addFriendCell:self pressedAdd:self.user];
    //NSLog(@"add friend: %@", self.user.username);
}

@end
