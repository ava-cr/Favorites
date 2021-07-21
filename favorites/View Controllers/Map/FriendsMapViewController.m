//
//  FriendsMapViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/20/21.
//

#import "FriendsMapViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "Update.h"
#import "Friend.h"
#import "PinAnnotation.h" // will use another annotation late (user's prof pic?)

@interface FriendsMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSArray *updates;
@property (strong, nonatomic) NSMutableArray *friends;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation FriendsMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.closeButton setTitle:NSLocalizedString(@"Close", @"close friends map view") forState:UIControlStateNormal];
    self.closeButton.layer.cornerRadius = 8;
    self.mapView.delegate = self;
    self.friends = [[NSMutableArray alloc] init];
    [self getFriends];
}
- (void) getFriends {
    // construct query
    PFQuery *queryUser1 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser1 whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryUser2 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser2 whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryUser1,queryUser2]];
    NSArray *keys = @[@"user1", @"user2"];
    [query includeKeys:keys];
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
            for (Friend *friend in friends) {
                if ([friend.user1.objectId isEqual:[PFUser currentUser].objectId]) {
                    [self.friends addObject:friend.user2];
                }
                else [self.friends addObject:friend.user1];
            }
            NSLog(@"%@", self.friends);
            [self getUpdates];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (void) getUpdates {
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    NSArray *keys = @[@"update", @"author", @"objectId"];
    [query includeKeys:keys];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"author" containedIn:self.friends];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        if (updates != nil) {
            self.updates = updates;
            NSLog(@"got updates");
            [self placePins];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (void) placePins {
    if (self.updates) {
        NSMutableArray* annotations = [[NSMutableArray alloc] init];
        for (Update *update in self.updates) {
            PinAnnotation *annotation = [[PinAnnotation alloc] init];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([update.latitude doubleValue] , [update.longitude doubleValue]);
            annotation.coordinate = coordinate;
            annotation.titleString = update.author.username;
            annotation.notes = update.caption;
            [annotations addObject:annotation];
        }
        // self.annotations = annotations;
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
        //annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    return annotationView;
}
- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

@end
