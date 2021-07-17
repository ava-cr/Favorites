//
//  ProfileHeaderCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ProfileHeaderCellDelegate;

@interface ProfileHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *numPinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPostsLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (nonatomic, weak) id<ProfileHeaderCellDelegate> delegate;
//@property (strong, nonatomic) PFUser *user;

@end

@protocol ProfileHeaderCellDelegate

- (void)tappedProfileButton:(ProfileHeaderCell *)cell;
- (void)tappedFriends:(ProfileHeaderCell *)cell;

@end

NS_ASSUME_NONNULL_END
