//
//  ListFriendsViewController.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/16/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListFriendsViewController : UIViewController

@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic, assign) BOOL addToGroup;
@property (strong, nonatomic) NSMutableArray *members;
@property (strong, nonatomic) NSString *membersString;

@end

NS_ASSUME_NONNULL_END
