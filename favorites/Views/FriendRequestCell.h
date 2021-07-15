//
//  FriendRequestCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "FriendRequest.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FriendRequestCellDelegate;

@interface FriendRequestCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (strong, nonatomic) FriendRequest *request;
@property (nonatomic, weak) id<FriendRequestCellDelegate> delegate;

@end

@protocol FriendRequestCellDelegate
- (void)friendRequestCell:(FriendRequestCell *)friendRequestCell pressedAccept:(FriendRequest *)request;

@end

NS_ASSUME_NONNULL_END
