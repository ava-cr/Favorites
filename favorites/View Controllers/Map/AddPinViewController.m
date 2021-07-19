//
//  AddPinViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "AddPinViewController.h"
#import <MapKit/MapKit.h>
#import "APIManager.h"

@interface AddPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) APIManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@end

@implementation AddPinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.pin.name;
    self.title = self.pin.name;
    self.phone = self.pin.phoneNumber;
    self.address = self.pin.placemark.title;
    self.subtitleLabel.text = self.address;
    self.notesTextView.layer.borderColor = [UIColor.labelColor CGColor];
    self.notesTextView.layer.borderWidth = 1.0;
    self.notesTextView.layer.cornerRadius = self.notesTextView.bounds.size.height / 6;
    self.notesTextView.textContainer.lineFragmentPadding = 20;
    NSLog(@"name, %@", self.pin.name);
    NSLog(@"address1, %@", self.pin.placemark.title);
    NSLog(@"city, %@", self.pin.placemark.locality);
    NSLog(@"state code, %@", self.pin.placemark.administrativeArea);
    NSLog(@"country code, %@", self.pin.placemark.ISOcountryCode);
    NSLog(@"latitude, %f", self.pin.placemark.coordinate.latitude);
    NSLog(@"longitude, %f", self.pin.placemark.coordinate.longitude);
    
    self.manager = [APIManager new];
    [self businessMatch];
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
}

-(void)dismissKeyboard {
    [self.notesTextView resignFirstResponder];
}

-(void) businessMatch {
    [self.manager getBusinessMatch:self.pin.placemark.name withAddress:self.pin.placemark.title city:self.pin.placemark.locality state:self.pin.placemark.administrativeArea country:self.pin.placemark.ISOcountryCode lat:self.pin.placemark.coordinate.latitude lng:self.pin.placemark.coordinate.longitude withCompletion:^(NSDictionary *results, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            if (results != nil) {
                self.yelpID = results[@"id"];
                [self businessDetails:self.yelpID];
            }
            else {
                NSLog(@"no matching businesses found");
            }
        }
    }];
}
-(void) businessDetails: (NSString *)businessId {
    [self.manager getBusinessDetails:businessId withCompletion:^(NSDictionary * _Nonnull results, NSError * _Nonnull error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSLog(@"got business details");
            NSLog(@"%@", results);
            //self.phone = results[@"phone"];
            self.imageURL = results[@"image_url"];
            self.yelpURL = results[@"url"];
            NSURL *url = [NSURL URLWithString:self.imageURL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            self.headerImageView.image = [[UIImage alloc] initWithData:urlData];
        }
    }];
}
- (IBAction)callButtonTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:self.phone]] options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"call successful");
        }
        else {
            NSLog(@"call not successful");
        }
    }];
}
- (IBAction)websiteButtonTapped:(id)sender {
    NSLog(@"open a web view with the website!");
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.notes = self.notesTextView.text;
}


@end
