//
//  ListPinCell.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import <UIKit/UIKit.h>
#import "Pin.h"

NS_ASSUME_NONNULL_BEGIN

@interface ListPinCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *pinTitleLabel;
@property (strong, nonatomic) Pin *pin;

@end

NS_ASSUME_NONNULL_END
