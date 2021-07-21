//
//  PinDetailsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "PinDetailsViewController.h"
#import "WebsiteViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "Pin.h"

static NSString *segueIdToWebsite = @"showWebsite";
static NSString *unwindSegueToMapSavePin = @"savePin";
static NSString *unwindSegueToMapDeletePin = @"deletePin";

@interface PinDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPinButton;
@property (weak, nonatomic) IBOutlet UIButton *deletePinButton;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *modalSaveButton;

@end

@implementation PinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.pin) self.pin = self.annotation.pin;
    self.titleLabel.text = self.pin.title;
    self.addressLabel.text = self.pin.address;
    self.addPinButton.layer.cornerRadius = 8;
    if (self.pin.imageURL) {
        NSURL *url = [NSURL URLWithString:self.pin.imageURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        self.headerImageView.image = [[UIImage alloc] initWithData:urlData];
    }
    if (self.pin.notes) self.notesTextView.text = self.pin.notes;
    if (![self.user.objectId isEqual:[PFUser currentUser].objectId]) {
        [self.notesTextView setEditable:FALSE];
        [self.deletePinButton setHidden:TRUE];
        [self.deletePinButton setEnabled:FALSE];
        [self.modalSaveButton setHidden:TRUE];
        [self.modalSaveButton setEnabled:FALSE];
    }
    else {
        [self.modalSaveButton setTitle:NSLocalizedString(@"Save", @"save pin") forState:UIControlStateNormal];
        self.modalSaveButton.layer.cornerRadius = 8;
        self.deletePinButton.layer.cornerRadius = 5;
        self.deletePinButton.layer.borderColor = [UIColor.systemRedColor CGColor];
        self.deletePinButton.layer.borderWidth = 0.5;
        [self.addPinButton setHidden:TRUE];
        [self.addPinButton setEnabled:FALSE];
    }
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
}

-(void)dismissKeyboard {
    [self.notesTextView resignFirstResponder];
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
    NSNumber *lat = self.pin.latitude;;
    NSNumber *lng = self.pin.longitude;
    [Pin postUserPin:self.pin.title withNotes:self.pin.notes latitude:lat longitude:lng urlString:self.pin.urlString phone:self.pin.phone imageURL:self.pin.imageURL yelpID:self.pin.yelpID yelpURL:self.pin.yelpURL address:self.pin.address withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the pin was added!");
            UIAlertController *pinAdded = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Pin added to your map!", @"message that pin was successfully added to user's map") message:@""preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:TRUE completion:nil];
                                                             }];
            [pinAdded addAction:ok];
            [self presentViewController:pinAdded animated:YES completion:nil];
        }
        else {
            NSLog(@"problem saving pin: %@", error.localizedDescription);
        }
    }];
}
- (IBAction)deletePinTapped:(id)sender {
    UIAlertController *editUpdate = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"delete pin")
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *deleteUpdate = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", @"message ensuring the user wants to delete their pin") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"delete pin")
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:unwindSegueToMapDeletePin sender:nil];
         }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"don't delete pin")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
        [deleteUpdate addAction:cancel];
        [deleteUpdate addAction:delete];
        [self presentViewController:deleteUpdate animated:YES completion:nil];
                                                     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"don't delete pin")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [editUpdate addAction:delete];
    [editUpdate addAction:cancel];
    [self presentViewController:editUpdate animated:YES completion:nil];
}
- (IBAction)callButtonTapped:(id)sender {
    NSString *phoneNumber = [self formatPhoneNumber:self.pin.phone];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel:" stringByAppendingString:phoneNumber]] options:@{} completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"call successful");
        }
        else {
            NSLog(@"call not successful");
        }
    }];
}

-(NSString *) formatPhoneNumber:(NSString *)number {
    NSString *formattedNumber = [number stringByReplacingOccurrencesOfString:@"(" withString:@""];
    formattedNumber = [formattedNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    formattedNumber = [formattedNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    formattedNumber = [formattedNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return formattedNumber;
}
- (IBAction)showWebsiteTapped:(id)sender {
    NSString *subString = [self.pin.urlString substringWithRange:NSMakeRange(0, 5)];
    NSLog(@"%@", subString);
    if ([subString isEqual:@"https"]) {
        [self performSegueWithIdentifier:segueIdToWebsite sender:nil];
    }
    else {
        UIAlertController *insecureWebsiteWarning = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Website Not Secure", @"alert message that website is unsecure") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"accepting alert message")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        }];
        [insecureWebsiteWarning addAction:ok];
        [self presentViewController:insecureWebsiteWarning animated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:unwindSegueToMapSavePin]) {
        self.pin.notes = self.notesTextView.text;
    }
    else if ([segue.identifier isEqual:segueIdToWebsite]) {
        WebsiteViewController *webVC = [segue destinationViewController];
        webVC.url = [NSURL URLWithString:self.pin.urlString];
    }
}


@end
