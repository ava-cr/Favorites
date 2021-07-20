//
//  ShowLocationOnMapViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "ShowLocationOnMapViewController.h"
#import "PinDetailsViewController.h"
#import <MapKit/MapKit.h>
#import "PinAnnotation.h"

@interface ShowLocationOnMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) PinAnnotation *annotation;

@end

@implementation ShowLocationOnMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake([self.update.latitude doubleValue], [self.update.longitude doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(0.01, 0.01));
    
    [self.mapView setRegion:region animated:TRUE];
    [self placePin];
}

-(void) placePin {
    self.annotation = [[PinAnnotation alloc] init];
    CLLocationCoordinate2D coordinate =  CLLocationCoordinate2DMake([self.update.latitude doubleValue], [self.update.longitude doubleValue]);
    self.annotation.coordinate = coordinate;
    self.annotation.titleString = self.update.locationTitle;
    NSLog(@"%@", self.annotation.titleString);
    [self.mapView addAnnotation:self.annotation];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
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
        [self performSegueWithIdentifier:@"pinDetails" sender:self.annotation];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier isEqual:@"pinDetails"]) {
        PinDetailsViewController *pdVC = [segue destinationViewController];
        PinAnnotation *annotation = sender;
        pdVC.title = annotation.titleString;
        pdVC.user = self.update.author;
        pdVC.annotation = self.annotation;
    }
}



@end
