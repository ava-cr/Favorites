//
//  Friend.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Friend : PFObject<PFSubclassing>

@property (strong, nonatomic) NSString *friendId;
@property (strong, nonatomic) PFUser *user1;
@property (strong, nonatomic) PFUser *user2;

+ (void) createFriends:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
