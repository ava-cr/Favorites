//
//  Like.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/20/21.
//

#import "Like.h"

@implementation Like

@dynamic likeId;
@dynamic user;
@dynamic update;

+ (nonnull NSString *)parseClassName {
    return @"Like";
}

+ (void)createLike:(PFUser *)user onUpdate:(Update *)update withCompletion:(PFBooleanResultBlock)completion {
    Like *newLike = [Like new];
    newLike.user = [PFUser currentUser];
    newLike.update = update;
    [newLike saveInBackgroundWithBlock: completion];
}

@end
