//
//  PinAnnotation.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Pin.h"

NS_ASSUME_NONNULL_BEGIN

@interface PinAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *notes;
@property (strong, nonatomic) Pin *pin;


@end

NS_ASSUME_NONNULL_END
