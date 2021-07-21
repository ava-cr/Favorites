//
//  ShowLocationOnMapViewController.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import <UIKit/UIKit.h>
#import "Update.h"

NS_ASSUME_NONNULL_BEGIN

@interface ShowLocationOnMapViewController : UIViewController

@property (strong, nonatomic) Update *update;
@property (nonatomic, assign) BOOL isPin;

@end

NS_ASSUME_NONNULL_END
