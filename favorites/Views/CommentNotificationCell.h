//
//  CommentNotificationCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/22/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentNotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;

@end

NS_ASSUME_NONNULL_END
