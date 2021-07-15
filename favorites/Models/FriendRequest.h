//
//  FriendRequest.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequest : PFObject<PFSubclassing>

@property (strong, nonatomic) NSString *friendRequestId;
@property (strong, nonatomic) PFUser *requester;
@property (strong, nonatomic) PFUser *requestee;

+ (void) createFriendRequest:(PFUser * _Nullable)requestee withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
