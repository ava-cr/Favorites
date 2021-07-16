//
//  ListFriendCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/16/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListFriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) PFUser *user;

@end

NS_ASSUME_NONNULL_END
