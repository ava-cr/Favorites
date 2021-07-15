//
//  ShowLocationOnMapViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "ShowLocationOnMapViewController.h"
#import <MapKit/MapKit.h>
#import "PinAnnotation.h"

@interface ShowLocationOnMapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

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
    PinAnnotation *annotation = [[PinAnnotation alloc] init];
    CLLocationCoordinate2D coordinate =  CLLocationCoordinate2DMake([self.update.latitude doubleValue], [self.update.longitude doubleValue]);
    annotation.coordinate = coordinate;
    annotation.titleString = self.update.locationTitle;
    [self.mapView addAnnotation:annotation];
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

@end
