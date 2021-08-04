//
//  ProfileUpdateCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "Update.h"
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ProfileUpdateCellDelegate;

@interface ProfileUpdateCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *isAtLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomUsernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *editUpdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *likedLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (strong, nonatomic) Update *update;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic, weak) id<ProfileUpdateCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *sharingWithLabel;

@end

@protocol ProfileUpdateCellDelegate

- (void)didTapEditUpdate:(ProfileUpdateCell *)updateCell;
- (void)updateCell:(ProfileUpdateCell *)updateCell likedUpdate:(Update *)update;
- (void)pressedComments:(ProfileUpdateCell *)updateCell;
- (void)pressedLikeLabel:(ProfileUpdateCell *)updateCell;
- (void)pressedLocation:(ProfileUpdateCell *)updateCell;

@end

NS_ASSUME_NONNULL_END
