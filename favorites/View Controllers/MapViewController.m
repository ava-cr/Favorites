//
//  MapViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "MapViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "AddPinViewController.h"
#import "PinAnnotation.h"
#import "Pin.h"


@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray<MKMapItem *> *pins;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getPins];
    
    self.mapView.delegate = self;
    
    if (self.locationManager == nil ) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            [self.locationManager startUpdatingLocation];
    }
    
    if ([self.locationManager authorizationStatus ] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

-(void) viewDidAppear:(BOOL)animated {
    
    if (self.pins) {
        NSMutableArray* annotations = [[NSMutableArray alloc] init];
        
        for (MKMapItem *pin in self.pins) {
            PinAnnotation *annotation = [[PinAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(pin.placemark.location.coordinate.latitude, pin.placemark.coordinate.longitude);
            annotation.coordinate = coordinate;
            [annotations addObject:annotation];
        }
        
        [self.mapView addAnnotations:annotations];
    }
    
    /*
     guard let mapItems = mapItems else { return }
     
     if mapItems.count == 1, let item = mapItems.first {
         title = item.name
     } else {
         title = NSLocalizedString("TITLE_ALL_PLACES", comment: "All Places view controller title")
     }
     
     // Turn the array of MKMapItem objects into an annotation with a title and URL that can be shown on the map.
     let annotations = mapItems.compactMap { (mapItem) -> PlaceAnnotation? in
         guard let coordinate = mapItem.placemark.location?.coordinate else { return nil }
         
         let annotation = PlaceAnnotation(coordinate: coordinate)
         annotation.title = mapItem.name
         annotation.url = mapItem.url
         
         return annotation
     }
     mapView.addAnnotations(annotations)
     */
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *userLocation = locations[0];

    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01));
    
    
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView setShowsUserLocation:TRUE];
    
    [self.locationManager stopUpdatingLocation]; // add a button to recenter on user's location and make it so that whenever the user returns to this tab, it recenters.
    

}
- (IBAction)didTapCenterUser:(id)sender {
    [self.locationManager startUpdatingLocation];
}



/// - TAG: unwind seque
- (IBAction) myUnwindAction:(UIStoryboardSegue*)unwindSegue {
    NSLog(@"unwinding from add pin to search locations");
    
    AddPinViewController *addPinVC = [unwindSegue sourceViewController];
    NSLog(@"pin notes: %@", addPinVC.notes);
    
    MKMapItem *pin = addPinVC.pin;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(addPinVC.pin.placemark.location.coordinate.latitude, addPinVC.pin.placemark.coordinate.longitude);
    
    PinAnnotation *annotation = [[PinAnnotation alloc] init];
    annotation.coordinate = coordinate;
    
    [self.mapView addAnnotation:annotation];
    
    NSNumber *lat = [NSNumber numberWithDouble:pin.placemark.location.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithDouble:pin.placemark.location.coordinate.longitude];
        
    [Pin postUserPin:pin.name withNotes:addPinVC.notes latitude:lat longitude:lng urlString:pin.url.absoluteString withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the pin was posted!");
        } else {
            NSLog(@"problem saving pin: %@", error.localizedDescription);
        }
    }];
    
    
}

- (void) getPins {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude"];
    [query includeKeys:keys];
    // [query orderByDescending:@"createdAt"];
    // query.limit = numberPosts;
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            self.pins = pins;
            NSLog(@"got pins");
            [self placePins];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

-(void) placePins {
    if (self.pins) {
        NSMutableArray* annotations = [[NSMutableArray alloc] init];
        
        for (Pin *pin in self.pins) {
            PinAnnotation *annotation = [[PinAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([pin.latitude doubleValue] , [pin.longitude doubleValue]);
            
            annotation.coordinate = coordinate;
            [annotations addObject:annotation];
        }
        
        [self.mapView addAnnotations:annotations];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        
//        UIImageView *image = [[UIImageView alloc] initWithImage:[self resizeImage:self.image withSize:annotationView.image.size]];
//        image.layer .cornerRadius = image.layer.frame.size.width / 2;
//        image.layer.masksToBounds = YES;
//
//        [annotationView addSubview:image];
        
        
        annotationView.canShowCallout = true;
        
//        UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
//        leftImageView.contentMode = UIViewContentModeScaleAspectFill;
//        leftImageView.clipsToBounds = YES;
//
//        annotationView.leftCalloutAccessoryView = leftImageView;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }

//    UIImageView *imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
//    imageView.image = self.image;

    return annotationView;
}


- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    NSLog(@"authorization is now");
    NSLog(@"%d", self.locationManager.authorizationStatus);
}




- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
    }];
    
    NSLog(@"%s", "logout");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    myDelegate.window.rootViewController = loginViewController;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
