//
//  Like.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/20/21.
//

#import <Parse/Parse.h>
#import "Update.h"

NS_ASSUME_NONNULL_BEGIN

@interface Like : PFObject <PFSubclassing>

@property (strong, nonatomic) NSString *likeId;
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) Update *update;

+ (void) createLike:(PFUser *)user onUpdate:(Update *)update withCompletion:(PFBooleanResultBlock)completion;

@end

NS_ASSUME_NONNULL_END
