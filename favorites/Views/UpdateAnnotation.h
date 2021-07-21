//
//  UpdateAnnotation.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/21/21.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Update.h"

NS_ASSUME_NONNULL_BEGIN

@interface UpdateAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) Update *update;

@end

NS_ASSUME_NONNULL_END
