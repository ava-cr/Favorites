//
//  UpdateCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Update.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UpdateCellDelegate;

@interface UpdateCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomUsernameLabel;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (strong, nonatomic) Update *update;
@property (nonatomic, weak) id<UpdateCellDelegate> delegate;

@end

@protocol UpdateCellDelegate
// TODO: Add required methods the delegate needs to implement
- (void)updateCell:(UpdateCell *) updateCell pressedLocation: (Update *)update;
@end

NS_ASSUME_NONNULL_END
