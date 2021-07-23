//
//  Pin.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "Pin.h"

@implementation Pin

@dynamic pinID;
@dynamic userID;
@dynamic author;
@dynamic notes;
@dynamic title;
@dynamic latitude;
@dynamic longitude;
@dynamic urlString;
@dynamic phone;
@dynamic imageURL;
@dynamic yelpID;
@dynamic yelpURL;
@dynamic address;
@dynamic category;

+ (nonnull NSString *)parseClassName {
    return @"Pin";
}

+ (void) postUserPin: ( NSString * _Nullable )title withNotes: ( NSString * _Nullable )notes latitude:( NSNumber * _Nullable )lat longitude:( NSNumber * _Nullable )lng urlString:( NSString * _Nullable )url phone:(NSString *)phone imageURL:(NSString *)imageURL yelpID:(NSString *)yelpID yelpURL:(NSString *)yelpURL address:(NSString *)address category:(NSNumber *)category withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Pin *newPin = [Pin new];
    newPin.title = title;
    newPin.author = [PFUser currentUser];
    newPin.notes = notes;
    newPin.latitude = lat;
    newPin.longitude = lng;
    newPin.urlString = url;
    newPin.phone = phone;
    newPin.imageURL = imageURL;
    newPin.yelpID = yelpID;
    newPin.yelpURL = yelpURL;
    newPin.address = address;
    newPin.category = category;
        
    [newPin saveInBackgroundWithBlock: completion];
}

@end
