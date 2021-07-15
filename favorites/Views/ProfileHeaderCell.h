//
//  ProfileHeaderCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *numPinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numPostsLabel;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;

@end

NS_ASSUME_NONNULL_END
