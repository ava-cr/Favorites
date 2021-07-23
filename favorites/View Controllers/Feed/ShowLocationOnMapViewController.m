//
//  ShowLocationOnMapViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "ShowLocationOnMapViewController.h"
#import "PinDetailsViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "PinAnnotation.h"
#import "Pin.h"

@interface ShowLocationOnMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) PinAnnotation *annotation;
@property (strong, nonatomic) Pin *pin;

@end

@implementation ShowLocationOnMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake([self.update.latitude doubleValue], [self.update.longitude doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01));
    [self.mapView setRegion:region animated:TRUE];
    if (!self.isPin) [self placeUserLocation];
    else [self getPin];
}

- (void)getPin {
    [SVProgressHUD show];
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude", @"category"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:self.update.author];
    [query whereKey:@"latitude" equalTo:self.update.latitude];
    [query whereKey:@"longitude" equalTo:self.update.longitude];
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            self.pin = pins[0];
            NSLog(@"got pin");
            [SVProgressHUD dismiss];
            [self placePin];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)placePin {
    PinAnnotation *annotation = [[PinAnnotation alloc] init];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.pin.latitude doubleValue] , [self.pin.longitude doubleValue]);
    annotation.coordinate = coordinate;
    annotation.titleString = self.pin.title;
    annotation.notes = self.pin.notes;
    annotation.pin = self.pin;
    [self.mapView addAnnotation:annotation];
}

- (void)placeUserLocation {
    self.annotation = [[PinAnnotation alloc] init];
    CLLocationCoordinate2D coordinate =  CLLocationCoordinate2DMake([self.update.latitude doubleValue], [self.update.longitude doubleValue]);
    self.annotation.coordinate = coordinate;
    self.annotation.titleString = self.update.locationTitle;
    NSLog(@"%@", self.annotation.titleString);
    [self.mapView addAnnotation:self.annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKMarkerAnnotationView *annotationView = (MKMarkerAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Mark"];
    if (annotationView == nil) {
        annotationView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Mark"];
        annotationView.canShowCallout = true;
        annotationView.largeContentTitle = annotation.title;
        if (self.isPin) {
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            int category = [self.pin.category intValue];
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
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([control isKindOfClass:[UIButton class]]) {
        [self performSegueWithIdentifier:@"pinDetails" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"pinDetails"]) {
        PinDetailsViewController *pdVC = [segue destinationViewController];
        pdVC.title = self.pin.title;
        pdVC.user = self.update.author;
        pdVC.pin = self.pin;
    }
}



@end
