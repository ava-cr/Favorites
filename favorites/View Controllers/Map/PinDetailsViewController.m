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

@end

@implementation PinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.annotation.titleString;
    self.notesTextView.text = self.annotation.notes;
    if (![self.user isEqual:[PFUser currentUser]]) {
        [self.notesTextView setEditable:FALSE];
    }
    else {
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
    [Pin postUserPin:self.annotation.titleString withNotes:self.annotation.notes latitude:self.annotation.pin.latitude longitude:self.annotation.pin.longitude urlString:self.annotation.pin.urlString withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
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

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"savePin"]) {
        self.annotation.pin.notes = self.notesTextView.text;
    }
}


@end
