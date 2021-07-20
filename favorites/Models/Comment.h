//
//  Comment.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/20/21.
//

#import <Parse/Parse.h>
#import "Update.h"

NS_ASSUME_NONNULL_BEGIN

@interface Comment : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) Update *update;
@property (nonatomic, strong) NSString *text;

+ (void) userCommentOnUpdate:(NSString * _Nullable)comment onUpdate:(Update * _Nullable)update withCompletion:(PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
