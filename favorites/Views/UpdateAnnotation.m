//
//  UpdateAnnotation.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/21/21.
//

#import "UpdateAnnotation.h"

@interface UpdateAnnotation()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation UpdateAnnotation

- (NSString *)title {
    return [NSString stringWithFormat:@"%@", self.titleString];
}

@end
