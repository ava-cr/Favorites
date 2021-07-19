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

@property (strong, nonatomic) MKMapItem *pin;
@property (strong, nonatomic) NSString *notes;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *yelpID;
@property (strong, nonatomic) NSString *yelpURL;
@property (strong, nonatomic) NSString *address;


@end

NS_ASSUME_NONNULL_END
