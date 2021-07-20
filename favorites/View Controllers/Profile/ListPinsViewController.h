//
//  ListPinsViewController.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListPinsViewController : UIViewController

@property (strong, nonatomic) PFUser *user;

@end

NS_ASSUME_NONNULL_END
