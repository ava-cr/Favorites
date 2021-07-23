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
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *yelpID;
@property (strong, nonatomic) NSString *yelpURL;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSNumber *category;

+ (void) postUserPin: ( NSString * _Nullable )title withNotes: ( NSString * _Nullable )notes latitude:( NSNumber * _Nullable )lat longitude:( NSNumber * _Nullable )lng urlString:( NSString * _Nullable )url phone:(NSString *)phone imageURL:(NSString *)imageURL yelpID:(NSString *)yelpID yelpURL:(NSString *)yelpURL address:(NSString *)address category:(NSNumber *)category withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
