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
#import <SCLAlertView_Objective_C/SCLAlertView.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextView.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import <SCLAlertView_Objective_C/SCLAlertView.h>
#import "Pin.h"

static NSString *segueIdToWebsite = @"showWebsite";
static NSString *unwindSegueToMapSavePin = @"savePin";
static NSString *unwindSegueToMapDeletePin = @"deletePin";

@interface PinDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) JVFloatLabeledTextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIButton *deletePinButton;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *callLabel;
@property (weak, nonatomic) IBOutlet UILabel *emojiLabel;
@property (strong, nonatomic) VBFPopFlatButton *saveButton;
@property (strong, nonatomic) VBFPopFlatButton *cancelButton;
@property (strong, nonatomic) VBFPopFlatButton *addButton;

@end

@implementation PinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.pin) self.pin = self.annotation.pin;
    self.titleLabel.text = self.pin.title;
    self.addressLabel.text = self.pin.address;
    if (self.pin.imageURL) {
        NSURL *url = [NSURL URLWithString:self.pin.imageURL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        self.headerImageView.image = [[UIImage alloc] initWithData:urlData];
    }
    [self setUpTextView];
    [self setUpByUser];
    if (self.pin.notes) self.notesTextView.text = self.pin.notes;
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
    [self setCategoryImage];
    self.websiteLabel.text = NSLocalizedString(@"Website", @"label for show website button");
    self.callLabel.text = NSLocalizedString(@"Call", @"label for call button");
}

- (void)setUpByUser {
    self.cancelButton = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(20, 20, 30, 30)
                                                  buttonType:buttonDefaultType
                                                 buttonStyle:buttonRoundedStyle
                                                 animateToInitialState:YES];
    self.cancelButton.lineThickness = 3;
    self.cancelButton.tintColor = [UIColor systemPinkColor];
    [self.cancelButton addTarget:self
                               action:@selector(cancelButtonPressed)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    if (![self.user.objectId isEqual:[PFUser currentUser].objectId]) {
        [self.notesTextView setEditable:FALSE];
        [self.deletePinButton setHidden:TRUE];
        [self.deletePinButton setEnabled:FALSE];
        self.addButton = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, 20, 30, 30)
                                                      buttonType:buttonDefaultType
                                                     buttonStyle:buttonRoundedStyle
                                                     animateToInitialState:YES];
        self.addButton.lineThickness = 3;
        self.addButton.tintColor = [UIColor systemPinkColor];
        self.addButton.roundBackgroundColor = [UIColor whiteColor];
        [self.addButton addTarget:self
                                   action:@selector(addButtonPressed)
                         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.addButton];
        NSTimeInterval delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.cancelButton animateToType:buttonCloseType];
            [self.addButton animateToType:buttonAddType];
        });
    }
    else {
        self.saveButton = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, 20, 30, 30)
                                                      buttonType:buttonDefaultType
                                                     buttonStyle:buttonRoundedStyle
                                                     animateToInitialState:YES];
        self.saveButton.lineThickness = 3;
        self.saveButton.tintColor = [UIColor systemPinkColor];
        [self.saveButton addTarget:self
                                   action:@selector(saveButtonPressed)
                         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.saveButton];
        NSTimeInterval delayInSeconds = 0.3;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.cancelButton animateToType:buttonCloseType];
            [self.saveButton animateToType:buttonOkType];
        });
        [self.deletePinButton setTitle:NSLocalizedString(@"Delete", @"delete pin") forState:UIControlStateNormal];
        self.deletePinButton.layer.cornerRadius = 5;
        self.deletePinButton.layer.borderColor = [UIColor.systemRedColor CGColor];
        self.deletePinButton.layer.borderWidth = 0.5;
    }
}

- (void)addButtonPressed {
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
    typeof(self) __weak weakSelf = self;
    [Pin postUserPin:self.pin.title withNotes:self.pin.notes latitude:lat longitude:lng urlString:self.pin.urlString phone:self.pin.phone imageURL:self.pin.imageURL yelpID:self.pin.yelpID yelpURL:self.pin.yelpURL address:self.pin.address category:self.pin.category withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (succeeded) {
                NSLog(@"the pin was added!");
                SCLAlertView *success = [[SCLAlertView alloc] init];
                success.customViewColor = [UIColor systemPinkColor];
                success.cornerRadius = 15;
                success.shouldDismissOnTapOutside = YES;
                [success setShowAnimationType:SCLAlertViewShowAnimationSlideInToCenter];
                [success setBackgroundType:SCLAlertViewBackgroundBlur];
                [success alertIsDismissed:^{
                    [strongSelf dismissViewControllerAnimated:TRUE completion:nil];
                }];
                [success showSuccess:self title:NSLocalizedString(@"Success!", @"success message") subTitle:NSLocalizedString(@"Pin added to your map.", @"pin successfully added to user's map message") closeButtonTitle:NSLocalizedString(@"OK", @"close alert") duration:0.0f];
            }
            else {
                NSLog(@"problem saving pin: %@", error.localizedDescription);
            }
        }
    }];
}

-(void) cancelButtonPressed {
    [self.cancelButton animateToType:buttonMinusType];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)saveButtonPressed {
    [self.cancelButton animateToType:buttonMinusType];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:unwindSegueToMapSavePin sender:nil];
    });
}

- (void)setUpTextView {
    int height = 100;
    int width = self.view.frame.size.width - 40;
    int y = self.addressLabel.frame.origin.y + self.addressLabel.frame.size.height + 20;
    NSLog(@"y = %d", y);
    self.notesTextView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width/2 - width/2, y, width, height)];
    [self.notesTextView setPlaceholder:NSLocalizedString(@"Pin notes", @"notes the user has written on their pin")];
    [self.notesTextView setTintColor:UIColor.systemPinkColor];
    [self.notesTextView setScrollEnabled:YES];
    [self.view addSubview:self.notesTextView];
}

-(void)dismissKeyboard {
    [self.notesTextView resignFirstResponder];
}

- (void)setCategoryImage {
    int category = [self.pin.category intValue];
    self.categoryImageView.tintColor = UIColor.whiteColor;
    UIColor *color = [[UIColor alloc] init];
    UIImage *image = [[UIImage alloc] init];
    NSString *emoji = [[NSString alloc] init];
    switch (category) {
        case 0:
            color = UIColor.systemRedColor;
            emoji = @"🍽";
            break;
        case 1:
            color = UIColor.systemOrangeColor;
            emoji = @"☕️";
            break;
        case 2:
            color = UIColor.systemPurpleColor;
            emoji = @"🍸";
            break;
        case 3:
            color = UIColor.systemBlueColor;
            emoji = @"🍦";
            image = [UIImage imageNamed:@"dessert"];
            break;
        case 4:
            color = UIColor.systemGreenColor;
            emoji = @"🛒";
            break;
        case 5:
            color = UIColor.systemPinkColor;
            emoji = @"❤️";
            break;
        case 6:
            color = UIColor.systemYellowColor;
            emoji = @"⭐️";
            break;
    }
    self.categoryImageView.backgroundColor = color;
    self.emojiLabel.text = emoji;
    self.categoryImageView.layer.cornerRadius = 8;
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

- (NSString *)formatPhoneNumber:(NSString *)number {
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
        f.origin.y = -(keyboardSize.height - 100);
        self.view.frame = f;
    }];
}
- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
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
