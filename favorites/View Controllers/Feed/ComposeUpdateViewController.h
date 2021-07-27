//
//  ComposeUpdateViewController.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface ComposeUpdateViewController : UIViewController

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) NSString *locationTitle;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSString *audience;
@property (strong, nonatomic) Group *group;

@end

NS_ASSUME_NONNULL_END
