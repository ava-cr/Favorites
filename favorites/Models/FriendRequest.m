//
//  FriendRequest.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "FriendRequest.h"

@implementation FriendRequest

@dynamic friendRequestId;
@dynamic requester;
@dynamic requestee;

+ (nonnull NSString *)parseClassName {
    return @"FriendRequest";
}

+ (void) createFriendRequest:(PFUser * _Nullable)requestee withCompletion:(PFBooleanResultBlock  _Nullable)completion {
    
    FriendRequest *newFR = [FriendRequest new];
    newFR.requester = [PFUser currentUser];
    newFR.requestee = requestee;
    [newFR saveInBackgroundWithBlock: completion];
}

@end
