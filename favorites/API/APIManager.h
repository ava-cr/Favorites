//
//  APIManager.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

@property (nonatomic, strong) NSURLSession *session;

- (void)getBusinessMatch:(NSString *)name withAddress:(NSString *)address city:(NSString *)city state:(NSString *)state country:(NSString *)countryCode lat:(double)latitude lng:(double)longitude withCompletion:(void(^)(NSDictionary *results, NSError *error))completion;

- (void)getBusinessDetails:(NSString *)businessId withCompletion:(void(^)(NSDictionary *results, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
