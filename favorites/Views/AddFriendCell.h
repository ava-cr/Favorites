//
//  AddFriendCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AddFriendCellDelegate;

@interface AddFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *addFriendButton;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic, weak) id<AddFriendCellDelegate> delegate;

@end

@protocol AddFriendCellDelegate
// required methods the delegate needs to implement
- (void)addFriendCell:(AddFriendCell *)addFriendCell pressedAdd:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
