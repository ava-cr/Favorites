//
//  PinAnnotation.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "PinAnnotation.h"
#import <MapKit/MapKit.h>

@interface PinAnnotation()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation PinAnnotation

- (NSString *)title {
    return [NSString stringWithFormat:@"%f", self.coordinate.latitude];
}

@end
