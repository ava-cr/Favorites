//
//  Group.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/27/21.
//

#import "Group.h"

@implementation Group

@dynamic groupID;
@dynamic title;
@dynamic user;
@dynamic members;
@dynamic membersString;

+ (nonnull NSString *)parseClassName {
    return @"Group";
}

+ (void) createGroup:(NSString * _Nullable)title byUser:(PFUser * _Nullable)user withMembers:(NSArray * _Nullable)members andMembersString:(NSString * _Nullable)membersString withCompletion:(PFBooleanResultBlock  _Nullable)completion {
    Group *newGroup = [Group new];
    newGroup.user = [PFUser currentUser];
    newGroup.members = members;
    newGroup.title = title;
    newGroup.membersString = membersString;
    [newGroup saveInBackgroundWithBlock: completion];
}

@end
