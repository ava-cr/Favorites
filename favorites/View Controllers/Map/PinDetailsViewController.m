//
//  PinDetailsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "PinDetailsViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "Pin.h"

@interface PinDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPinButton;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (weak, nonatomic) IBOutlet UIButton *deletePinButton;

@end

@implementation PinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.annotation.titleString;
    if (self.annotation.notes) {
        self.notesTextView.text = self.annotation.notes;
    }
    else {
        self.notesLabel.text = @"";
    }
    if (![self.user isEqual:[PFUser currentUser]]) {
        [self.notesTextView setEditable:FALSE];
        [self.deletePinButton setHidden:TRUE];
        [self.deletePinButton setEnabled:FALSE];
    }
    else {
        self.deletePinButton.layer.cornerRadius = 5;
        self.deletePinButton.layer.borderColor = [UIColor.systemRedColor CGColor];
        self.deletePinButton.layer.borderWidth = 0.5;
        [self.addPinButton setHidden:TRUE];
        [self.addPinButton setEnabled:FALSE];
    }
}
- (IBAction)addPinTapped:(id)sender {
    // update pin count & post pin to user's map
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"numPins"] = [NSNumber numberWithInt:([currentUser[@"numPins"] intValue] + 1)];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"updated user pin count!");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    NSNumber *lat;
    NSNumber *lng;
    if (self.annotation.pin.latitude) {
        lat = self.annotation.pin.latitude;
        lng = self.annotation.pin.longitude;
    }
    else {
        lat = [NSNumber numberWithDouble:self.annotation.coordinate.latitude];
        lng = [NSNumber numberWithDouble:self.annotation.coordinate.longitude];
    }
    [Pin postUserPin:self.annotation.titleString withNotes:self.annotation.notes latitude:lat longitude:lng urlString:self.annotation.pin.urlString phone:self.annotation.pin.phone imageURL:self.annotation.pin.imageURL yelpID:self.annotation.pin.yelpID yelpURL:self.annotation.pin.yelpURL withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the pin was added!");
            UIAlertController *pinAdded = [UIAlertController alertControllerWithTitle:@"Pin added to your map!" message:@""preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:TRUE completion:nil];
                                                             }];
            [pinAdded addAction:ok];
            [self presentViewController:pinAdded animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];
        } else {
            NSLog(@"problem saving pin: %@", error.localizedDescription);
        }
    }];
}
- (IBAction)deletePinTapped:(id)sender {
    UIAlertController *editUpdate = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete"
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *deleteUpdate = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"deletePin" sender:nil];
         }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
        [deleteUpdate addAction:cancel];
        [deleteUpdate addAction:delete];
        [self presentViewController:deleteUpdate animated:YES completion:nil];
                                                     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [editUpdate addAction:delete];
    [editUpdate addAction:cancel];
    [self presentViewController:editUpdate animated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"savePin"]) {
        self.annotation.pin.notes = self.notesTextView.text;
    }
}


@end
