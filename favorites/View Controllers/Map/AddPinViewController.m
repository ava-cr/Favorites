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
#import <SCLAlertView_Objective_C/SCLAlertView.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextView.h>
#import "APIManager.h"

static NSString *segueIdToWebsite = @"showWebsite";
static NSString *unwindSegueToMap = @"addPin";

@interface AddPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (strong, nonatomic) JVFloatLabeledTextView *notesTextView;
@property (strong, nonatomic) APIManager *manager;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *callLabel;

@end

@implementation AddPinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.pin.name;
    self.title = self.pin.name;
    self.phone = self.pin.phoneNumber;
    self.address = self.pin.placemark.title;
    self.subtitleLabel.text = self.address;
    self.manager = [APIManager new];
    [self businessMatch];
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
    [self setUpTextView];
    self.websiteLabel.text = NSLocalizedString(@"Website", @"label for show website button");
    self.callLabel.text = NSLocalizedString(@"Call", @"label for call button");
    
}

-(void)setUpTextView {
    int height = 100;
    int width = self.segmentedControl.frame.size.width;
    int y = self.segmentedControl.frame.origin.y + self.segmentedControl.frame.size.height + height/2 + 55;
    NSLog(@"y = %d", y);
    self.notesTextView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width/2 - width/2, y, width, height)];
    [self.notesTextView setPlaceholder:NSLocalizedString(@"Write notes on your pin...", @"prompting the user to write notes on their pin")];
    [self.notesTextView setTintColor:UIColor.systemPinkColor];
    [self.notesTextView setScrollEnabled:YES];
    [self.view addSubview:self.notesTextView];
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
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        [alert setShowAnimationType:SCLAlertViewShowAnimationSlideInToCenter];
        [alert setBackgroundType:SCLAlertViewBackgroundBlur];
        alert.shouldDismissOnTapOutside = YES;
        [alert showError:self title:NSLocalizedString(@"Error", @"error message") subTitle:NSLocalizedString(@"Website not secure.",@"alert message that website is unsecure")  closeButtonTitle:NSLocalizedString(@"OK", @"accepting alert message") duration:0.0f];
    }
}
// code to move the view up when the keyboard shows
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -(keyboardSize.height - 80);
        self.view.frame = f;
    }];
}
-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
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
