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
#import "SceneDelegate.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "AddPinViewController.h"
#import "PinDetailsViewController.h"
#import "ListPinsViewController.h"
#import "UpdateDetailsViewController.h"
#import "PinAnnotation.h"
#import "UpdateAnnotation.h"
#import "Pin.h"
#import "Update.h"
#import "Friend.h"

static NSString *segueToPinsList = @"showPinsList";
static NSString *segueToUpdateDetails = @"showUpdateDetails";

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray<MKMapItem *> *pins;
@property (strong, nonatomic) NSArray<PinAnnotation *> *annotations;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addPinButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *listPinsButton;
@property (weak, nonatomic) IBOutlet UIButton *friendsButton;
@property (strong, nonatomic) NSArray *updates;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSArray<UpdateAnnotation *> *updateAnnotations;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    if (!self.user) self.user = [PFUser currentUser];
    self.listPinsButton.layer.cornerRadius = 8;
    [self getPins];
    if ([self.user isEqual:[PFUser currentUser]]) {
        self.title = NSLocalizedString(@"Your Pins", @"the user's saved locations");
        [self.cancelButton setEnabled:FALSE];
        [self.cancelButton setHidden:TRUE];
    }
    else {
        [self.friendsButton setEnabled:FALSE];
        [self.friendsButton setHidden:TRUE];
        self.cancelButton.layer.cornerRadius = 8;
        [self.addPinButton setEnabled:FALSE];
        [self.addPinButton setTitle:@""];
        [self.logoutButton setEnabled:FALSE];
        [self.logoutButton setTitle:@""];
        self.title = [self.user.username stringByAppendingString:@"'s Pins"];
    }
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
- (void)viewDidAppear:(BOOL)animated {
     AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     [delegate registerForRemoteNotifications];
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
    NSLog(@"new notes = %@", pdVC.pin.notes);
    
    Pin *pin = pdVC.pin;
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
    if ([self.friendsButton isSelected]) {
        [self.mapView removeAnnotations:self.updateAnnotations];
        [self getFriends];
    }
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
    typeof(self) __weak weakSelf = self;
    [Pin postUserPin:pin.name withNotes:addPinVC.notes latitude:lat longitude:lng urlString:urlString phone:addPinVC.phone imageURL:addPinVC.imageURL yelpID:addPinVC.yelpID yelpURL:addPinVC.yelpURL address:addPinVC.address category:addPinVC.category withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (succeeded) {
                NSLog(@"the pin was posted!");
                [strongSelf reloadMapView];
            } else {
                NSLog(@"problem saving pin: %@", error.localizedDescription);
            }
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
    typeof(self) __weak weakSelf = self;
    [sourceVC.pin deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (succeeded) {
                NSLog(@"deleted pin %@", sourceVC.pin.title);
                [strongSelf reloadMapView];
            }
            else {
                NSLog(@"problem deleting pin: %@", error.localizedDescription);
            }
        }
    }];
}

- (void) getPins {
    [SVProgressHUD show];
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude", @"category"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:self.user];
    query.limit = 20;
    [self.mapView removeAnnotations:self.annotations];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (pins != nil) {
                strongSelf.pins = pins;
                NSLog(@"got pins");
                [strongSelf placePins];
                [SVProgressHUD dismiss];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
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
    else if ([annotation isKindOfClass:[UpdateAnnotation class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
            annotationView.canShowCallout = true;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        UpdateAnnotation *updateAnnotation = annotation;
        NSURL *url = [NSURL URLWithString:updateAnnotation.update.image.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        UIImage *picImage = [self resizeImage:[[UIImage alloc] initWithData:urlData] withSize:CGSizeMake(50.0, 50.0)];
        annotationView.image = picImage;
        return annotationView;
    }
    else {
        MKMarkerAnnotationView *annotationView = (MKMarkerAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Mark"];
        annotationView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Mark"];
        annotationView.canShowCallout = true;
        annotationView.largeContentTitle = annotation.title;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        PinAnnotation *annotation = annotationView.annotation;
        int category = [annotation.pin.category intValue];
        UIColor *color = [[UIColor alloc] init];
        UIImage *image = [[UIImage alloc] init];
        switch (category) {
            case 0:
                color = UIColor.systemRedColor;
                image = [UIImage imageNamed:@"eat"];
                break;
            case 1:
                color = UIColor.systemOrangeColor;
                image = [UIImage imageNamed:@"cup"];
                break;
            case 2:
                color = UIColor.systemPurpleColor;
                image = [UIImage imageNamed:@"drink"];
                break;
            case 3:
                color = UIColor.systemBlueColor;
                image = [UIImage imageNamed:@"dessert"];
                break;
            case 4:
                color = UIColor.systemGreenColor;
                image = [UIImage imageNamed:@"shop"];
                break;
            case 5:
                color = UIColor.systemPinkColor;
                image = [UIImage imageNamed:@"heart"];
                break;
            case 6:
                color = UIColor.systemYellowColor;
                image = [UIImage imageNamed:@"star"];
                break;
                
            default:
                color = UIColor.systemGrayColor;
                image = [UIImage imageNamed:@"pin"];
                break;
        }
        annotationView.markerTintColor = color;
        annotationView.glyphImage = image;
        return annotationView;
    }
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([control isKindOfClass:[UIButton class]]) {
        if ([view isKindOfClass:[MKMarkerAnnotationView class]]) {
            NSLog(@"do pin details segue");
            PinAnnotation *pinAnnotation = view.annotation;
            [self performSegueWithIdentifier:@"pinDetails" sender:pinAnnotation.pin];
        }
        else {
            UpdateAnnotation *updateAnnotation = view.annotation;
            NSLog(@"perform a segue to update details page");
            [self performSegueWithIdentifier:segueToUpdateDetails sender:updateAnnotation.update];
        }
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
- (IBAction)listPinsButtonTapped:(id)sender {
    [self performSegueWithIdentifier:segueToPinsList sender:nil];
}
#pragma mark - Functions for Seeing Friends' Updates on Map Feature
- (IBAction)friendsButtonTapped:(id)sender {
    if ([self.friendsButton isSelected]) {
        NSLog(@"remove update annotations");
        [self.mapView removeAnnotations:self.updateAnnotations];
        [self.friendsButton setSelected:FALSE];
    }
    else {
        NSLog(@"add update annotations");
        self.friends = [[NSMutableArray alloc] init];
        [SVProgressHUD show];
        [self getFriends];
        [self.friendsButton setSelected:TRUE];
    }
}
- (void) getFriends {
    PFQuery *queryUser1 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser1 whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryUser2 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser2 whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryUser1,queryUser2]];
    NSArray *keys = @[@"user1", @"user2"];
    [query includeKeys:keys];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (friends != nil) {
                NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
                for (Friend *friend in friends) {
                    if ([friend.user1.objectId isEqual:[PFUser currentUser].objectId]) {
                        [strongSelf.friends addObject:friend.user2];
                    }
                    else [strongSelf.friends addObject:friend.user1];
                }
                NSLog(@"%@", strongSelf.friends);
                [strongSelf getUpdates];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
- (void) getUpdates {
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    NSArray *keys = @[@"update", @"author", @"objectId", @"image", @"url"];
    [query includeKeys:keys];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"author" containedIn:self.friends];
    query.limit = 20;
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (updates != nil) {
                strongSelf.updates = updates;
                NSLog(@"got updates");
                [strongSelf placeUpdatePins];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
- (void) placeUpdatePins {
    if (self.updates) {
        NSMutableArray* annotations = [[NSMutableArray alloc] init];
        for (Update *update in self.updates) {
            UpdateAnnotation *annotation = [[UpdateAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([update.latitude doubleValue] , [update.longitude doubleValue]);
            annotation.coordinate = coordinate;
            annotation.titleString = update.author.username;
            annotation.update = update;
            [annotations addObject:annotation];
        }
        self.updateAnnotations = annotations;
        [SVProgressHUD dismiss];
        [self.mapView addAnnotations:annotations];
    }
}
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"pinDetails"]) {
        PinDetailsViewController *pdVC = [segue destinationViewController];
        Pin *pin = sender;
        pdVC.title = pin.title;
        pdVC.user = self.user;
        pdVC.pin = pin;
    }
    else if ([segue.identifier isEqual:segueToPinsList]) {
        ListPinsViewController *listVC = [segue destinationViewController];
        listVC.user = self.user;
    }
    else if ([segue.identifier isEqual:segueToUpdateDetails]) {
        Update *update = sender;
        UpdateDetailsViewController *updateDetailsVC = [segue destinationViewController];
        updateDetailsVC.update = update;
    }
}

@end
