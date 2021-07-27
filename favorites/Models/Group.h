//
//  Group.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/27/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Group : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *membersString;

+ (void) createGroup:(NSString * _Nullable)title byUser:(PFUser * _Nullable)user withMembers:(NSArray * _Nullable)members andMembersString:(NSString * _Nullable)membersString withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
