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
#import <SVProgressHUD/SVProgressHUD.h>
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "AddPinViewController.h"
#import "PinAnnotation.h"
#import "Pin.h"
#import "PinDetailsViewController.h"


@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray<MKMapItem *> *pins;
@property (strong, nonatomic) NSArray<PinAnnotation *> *annotations;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    if (!self.user) self.user = [PFUser currentUser];
    if ([self.user isEqual:[PFUser currentUser]]) {
        self.title = NSLocalizedString(@"Your Pins", @"the user's saved locations");
        [self.cancelButton setEnabled:FALSE];
        [self.cancelButton setHidden:TRUE];
    }
    else {
        [self.addPinButton setEnabled:FALSE];
        [self.addPinButton setTitle:@""];
        [self.logoutButton setEnabled:FALSE];
        [self.logoutButton setTitle:@""];
        self.title = [self.user.username stringByAppendingString:@"'s Pins"];
    }
    [self getPins];
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
- (IBAction)cancelButtonTapped:(id)sender {
[self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *userLocation = locations[0];
    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01));
    
    [self.mapView setRegion:region animated:TRUE];
    [self.mapView setShowsUserLocation:TRUE];
    [self.locationManager stopUpdatingLocation];
}

- (IBAction)didTapCenterUser:(id)sender {
    [self.locationManager startUpdatingLocation];
}

- (IBAction) updatedPinUnwind:(UIStoryboardSegue*)unwindSegue {
    
    PinDetailsViewController *pdVC = [unwindSegue sourceViewController];
    NSLog(@"new notes = %@", pdVC.annotation.pin.notes);
    
    Pin *pin = pdVC.annotation.pin;
    pin[@"notes"] = pin.notes;
    
    [pin saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"updated pin!");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    [self reloadMapView];
}

- (void) reloadMapView {
    NSLog(@"reloading pins");
    [self.mapView removeAnnotations:self.annotations];
    [self getPins];
}

- (IBAction) addPin:(UIStoryboardSegue*)unwindSegue {
    NSLog(@"unwinding from add pin to map");
    
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"numPins"] = [NSNumber numberWithInt:([currentUser[@"numPins"] intValue] + 1)];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"updated user pin count!");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    AddPinViewController *addPinVC = [unwindSegue sourceViewController];
    MKMapItem *pin = addPinVC.pin;
    NSNumber *lat = [NSNumber numberWithDouble:pin.placemark.location.coordinate.latitude];
    NSNumber *lng = [NSNumber numberWithDouble:pin.placemark.location.coordinate.longitude];
    NSString *urlString = [NSString alloc];
    
    if (pin.url) urlString = pin.url.absoluteString;
    else urlString = @"";
    
    [Pin postUserPin:pin.name withNotes:addPinVC.notes latitude:lat longitude:lng urlString:urlString phone:addPinVC.phone imageURL:addPinVC.imageURL yelpID:addPinVC.yelpID yelpURL:addPinVC.yelpURL address:addPinVC.address withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the pin was posted!");
            [self reloadMapView];
        } else {
            NSLog(@"problem saving pin: %@", error.localizedDescription);
        }
    }];
}

- (IBAction) deletePin:(UIStoryboardSegue*)unwindSegue {
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"numPins"] = [NSNumber numberWithInt:([currentUser[@"numPins"] intValue] - 1)];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"updated user pin count!");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    PinDetailsViewController *sourceVC = [unwindSegue sourceViewController];
    [sourceVC.annotation.pin deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"deleted pin %@", sourceVC.annotation.pin.title);
            [self reloadMapView];
        }
        else {
            NSLog(@"problem deleting pin: %@", error.localizedDescription);
        }
    }];
}

- (void) getPins {
    // construct query
    [SVProgressHUD show];
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:self.user];
    query.limit = 20;
    [self.mapView removeAnnotations:self.annotations];
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            self.pins = pins;
            NSLog(@"got pins");
            [self placePins];
            [SVProgressHUD dismiss];
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
            annotation.titleString = pin.title;
            annotation.notes = pin.notes;
            annotation.pin = pin;
            [annotations addObject:annotation];
        }
        self.annotations = annotations;
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
        annotationView.canShowCallout = true;
        annotationView.largeContentTitle = annotation.title;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([control isKindOfClass:[UIButton class]]) {
        [self performSegueWithIdentifier:@"pinDetails" sender:view.annotation];
    }
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
- (IBAction)refreshButtonTapped:(id)sender {
    [self reloadMapView];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqual:@"pinDetails"]) {
        PinDetailsViewController *pdVC = [segue destinationViewController];
        PinAnnotation *annotation = sender;
        pdVC.title = annotation.titleString;
        pdVC.user = self.user;
        pdVC.annotation = annotation;
    }
}

@end
