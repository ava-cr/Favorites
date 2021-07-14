//
//  PinAnnotation.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PinAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *notes;


@end

NS_ASSUME_NONNULL_END
