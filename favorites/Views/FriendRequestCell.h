//
//  FriendRequestCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;

@end

NS_ASSUME_NONNULL_END
