//
//  ProfileUpdateCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProfileUpdateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *isAtLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomUsernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;

@end

NS_ASSUME_NONNULL_END
