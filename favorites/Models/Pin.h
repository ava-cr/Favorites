//
//  Pin.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Pin : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *pinID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *notes;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

+ (void) postUserPin: ( NSString * _Nullable )title withNotes: ( NSString * _Nullable )notes latitude:( NSNumber * _Nullable )lat longitude:( NSNumber * _Nullable )lng urlString:( NSString * _Nullable )url withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
