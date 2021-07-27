//
//  GroupCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/27/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberStringLabel;

@end

NS_ASSUME_NONNULL_END
