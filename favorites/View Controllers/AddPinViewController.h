//
//  AddPinViewController.h
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddPinViewController : UIViewController

@property (strong, nonatomic) MKMapItem *location;
@property (strong, nonatomic) NSString *notes;

@end

NS_ASSUME_NONNULL_END
