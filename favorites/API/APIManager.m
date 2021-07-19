//
//  APIManager.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import "APIManager.h"

static NSString *apikey = @"8finKi1Dn672HckmQcXEwns2gezMsYQTYNWNmV7P9QJIJ56-E0jDttkQaA4K3iWI_NI5x6UOBCHk2W8X7EYsY6HoDDNExJW108H1qRo7OGjsV9Mg2mzr5a2yO6f1YHYx";

@implementation APIManager

- (id)init {
    self = [super init];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    return self;
}

- (void)getBusinessDetails:(NSString *)businessId withCompletion:(void(^)(NSDictionary *results, NSError *error))completion {
    NSString *urlString = [@"https://api.yelp.com/v3/businesses/" stringByAppendingString:businessId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [request setValue:[@"Bearer " stringByAppendingString:apikey] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            completion(dataDictionary, nil);
        }
    }];
    [task resume];
}

- (void)getBusinessMatch:(NSString *)name withAddress:(NSString *)address city:(NSString *)city state:(NSString *)state country:(NSString *)countryCode lat:(double)latitude lng:(double)longitude withCompletion:(void(^)(NSDictionary *results, NSError *error))completion {
    
    NSString *nameAddressString = [[@"name=" stringByAppendingString:name] stringByAppendingString:[@"&address1=" stringByAppendingString:address]];
    NSString *cityStateCountryString = [[[@"&city=" stringByAppendingString:city] stringByAppendingString:[@"&state=" stringByAppendingString:state]] stringByAppendingString:[@"&country=" stringByAppendingString:countryCode]];
    NSString *params = [[nameAddressString stringByAppendingString:cityStateCountryString] stringByAppendingString:@"&match_threshold=none"];
    NSString *fullString = [@"https://api.yelp.com/v3/businesses/matches?" stringByAppendingString:params];
    NSString* encodedUrl =
    [fullString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:encodedUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    [request setValue:[@"Bearer " stringByAppendingString:apikey] forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSLog(@"%@", dataDictionary);
            if ([dataDictionary[@"businesses"] count] != 0) {
                NSDictionary *businessData = dataDictionary[@"businesses"][0];
                completion(businessData, nil);
            }
            else {
                completion(nil, nil);
            }
        }
    }];
    [task resume];
}

@end
