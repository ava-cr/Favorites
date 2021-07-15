//
//  Update.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Update : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *updateID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *locationTitle;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) NSNumber *likeCount;
@property (nonatomic, strong) NSNumber *commentCount;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

+ (void) postUserUpdate: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption locationTitle: ( NSString * _Nullable )locationTitle lat:( NSNumber * _Nullable )lat lng:( NSNumber * _Nullable )lng withCompletion: (PFBooleanResultBlock  _Nullable)completion;

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
