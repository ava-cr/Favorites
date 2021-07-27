//
//  GroupCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/27/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberStringLabel;
@property (strong, nonatomic) Group *group;

@end

NS_ASSUME_NONNULL_END
