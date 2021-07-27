//
//  Update.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "Update.h"

@implementation Update

@dynamic updateID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic image;
@dynamic likeCount;
@dynamic commentCount;
@dynamic locationTitle;
@dynamic latitude;
@dynamic longitude;
@dynamic audience;
@dynamic group;

+ (nonnull NSString *)parseClassName {
    return @"Update";
}

+ (void) postUserUpdate:( UIImage * _Nullable )image withCaption:( NSString * _Nullable )caption locationTitle:( NSString * _Nullable )locationTitle lat:( NSNumber * _Nullable )lat lng:( NSNumber * _Nullable )lng withAudience:( NSString * _Nullable )audience withGroup:( Group * )group withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Update *newUpdate = [Update new];
    newUpdate.image = [self getPFFileFromImage:image];
    newUpdate.author = [PFUser currentUser];
    newUpdate.caption = caption;
    newUpdate.likeCount = @(0);
    newUpdate.commentCount = @(0);
    newUpdate.latitude = lat;
    newUpdate.longitude = lng;
    newUpdate.locationTitle = locationTitle;
    newUpdate.audience = audience;
    newUpdate.group = group;
    
    [newUpdate saveInBackgroundWithBlock: completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
     if (!image) return nil;
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) return nil;
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

@end
