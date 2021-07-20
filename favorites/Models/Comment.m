//
//  Comment.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/20/21.
//

#import "Comment.h"

@implementation Comment

@dynamic commentID;
@dynamic update;
@dynamic author;
@dynamic text;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void)userCommentOnUpdate:(NSString *)comment onUpdate:(Update *)update withCompletion:(PFBooleanResultBlock)completion {
    Comment *newComment = [Comment new];
    newComment.author = [PFUser currentUser];
    newComment.update = update;
    newComment.text = comment;
    [newComment saveInBackgroundWithBlock: completion];
}

@end
