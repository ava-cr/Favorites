//
//  PinDetailsViewController.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PinAnnotation.h"

NS_ASSUME_NONNULL_BEGIN

@interface PinDetailsViewController : UIViewController

@property (strong, nonatomic) PinAnnotation *annotation;
@property (strong, nonatomic) PFUser *user;

@end

NS_ASSUME_NONNULL_END
