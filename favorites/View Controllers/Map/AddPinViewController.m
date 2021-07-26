//
//  AddPinViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "AddPinViewController.h"
#import "WebsiteViewController.h"
#import <MapKit/MapKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "APIManager.h"

static NSString *segueIdToWebsite = @"showWebsite";
static NSString *unwindSegueToMap = @"addPin";

@interface AddPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (strong, nonatomic) APIManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

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
    self.manager = [APIManager new];
    [self businessMatch];
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
    
}

-(void)dismissKeyboard {
    [self.notesTextView resignFirstResponder];
}

-(void) businessMatch {
    [SVProgressHUD show];
    typeof(self) __weak weakSelf = self;
    [self.manager getBusinessMatch:self.pin.placemark.name withAddress:self.pin.placemark.title city:self.pin.placemark.locality state:self.pin.placemark.administrativeArea country:self.pin.placemark.ISOcountryCode lat:self.pin.placemark.coordinate.latitude lng:self.pin.placemark.coordinate.longitude withCompletion:^(NSDictionary *results, NSError * _Nonnull error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else {
                if (results != nil) {
                    strongSelf.yelpID = results[@"id"];
                    [strongSelf businessDetails:strongSelf.yelpID];
                }
                else {
                    [SVProgressHUD dismiss];
                    NSLog(@"no matching businesses found");
                }
            }
        }
    }];
}
-(void) businessDetails: (NSString *)businessId {
    typeof(self) __weak weakSelf = self;
    [self.manager getBusinessDetails:businessId withCompletion:^(NSDictionary * _Nonnull results, NSError * _Nonnull error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
            else {
                NSLog(@"got business details");
                NSLog(@"%@", results);
                strongSelf.imageURL = results[@"image_url"];
                strongSelf.yelpURL = results[@"url"];
                NSURL *url = [NSURL URLWithString:strongSelf.imageURL];
                NSData *urlData = [NSData dataWithContentsOfURL:url];
                strongSelf.headerImageView.image = [[UIImage alloc] initWithData:urlData];
            }
        }
        [SVProgressHUD dismiss];
    }];
}
- (IBAction)callButtonTapped:(id)sender {
    NSString *phoneNumber = [self formatPhoneNumber:self.phone];
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
    NSLog(@"%@", [self.pin.url absoluteString]);
    NSString *subString = [[self.pin.url absoluteString] substringWithRange:NSMakeRange(0, 5)];
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
    if ([segue.identifier isEqual:unwindSegueToMap]) {
        self.notes = self.notesTextView.text;
        self.category = [NSNumber numberWithInteger:self.segmentedControl.selectedSegmentIndex];
    }
    else if ([segue.identifier isEqual:segueIdToWebsite]) {
        WebsiteViewController *webVC = [segue destinationViewController];
        webVC.url = self.pin.url;
    }
}


@end
