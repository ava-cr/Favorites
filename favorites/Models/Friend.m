//
//  Friend.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import "Friend.h"

@implementation Friend

@dynamic friendId;
@dynamic user1;
@dynamic user2;

+ (nonnull NSString *)parseClassName {
    return @"Friend";
}

+ (void)createFriends:(PFUser *)user withCompletion:(PFBooleanResultBlock)completion {
    
    Friend *newFriend = [Friend new];
    newFriend.user1 = [PFUser currentUser];
    newFriend.user2 = user;
    [newFriend saveInBackgroundWithBlock: completion];
}

@end
