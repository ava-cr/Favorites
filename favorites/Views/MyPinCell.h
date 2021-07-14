//
//  MyPinCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Pin.h"

NS_ASSUME_NONNULL_BEGIN

@interface MyPinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) Pin *pin;

@end

NS_ASSUME_NONNULL_END
