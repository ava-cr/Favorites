//
//  ComposeUpdateViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "ComposeUpdateViewController.h"
#import "MyPinsViewController.h"
#import "Pin.h"
#import "GroupsViewController.h"
#import "Group.h"
#import <CoreLocation/CoreLocation.h>

static NSString *segueToGroups = @"showMyGroups";

@interface ComposeUpdateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property (weak, nonatomic) IBOutlet UILabel *sharingWithLabel;

@end

@implementation ComposeUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.locationManager == nil ) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    }
    if ([self.locationManager authorizationStatus ] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
}

-(void)dismissKeyboard {
    [self.captionTextField resignFirstResponder];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *userLocation = locations[0];
    self.userLocation = userLocation;
}

- (IBAction)addLocationTapped:(id)sender {
    UIAlertController *addLoc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add Location", @"prompt the user to choose a location for their post") message:@""preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *myLocation = [UIAlertAction actionWithTitle:NSLocalizedString(@"Use My Location", @"use the user's current location")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // choosing my location
        NSString *username = [PFUser currentUser].username;
        self.locationLabel.text = [username stringByAppendingString:NSLocalizedString(@"'s location", nil)];
        NSNumber *lat = [NSNumber numberWithDouble:self.userLocation.coordinate.latitude];
        NSNumber *lng = [NSNumber numberWithDouble:self.userLocation.coordinate.longitude];
        self.latitude = lat;
        self.longitude = lng;
        
    }];
    UIAlertAction *chooseLocation = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose From Locations", @"use one of the user's pre-saved locations")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"showMyPins" sender:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"close alert controller")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
    }];
    [addLoc addAction:myLocation];
    [addLoc addAction:chooseLocation];
    [addLoc addAction:cancel];
    [self presentViewController:addLoc animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (IBAction)addPhotoTapped:(id)sender {
    UIAlertController *addPic = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", @"use camera to take photo for post")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto]; // take photo
    }];
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose From Library", @"choose photo from library for post")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self choosePhoto]; // choose photo
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"close alert controller")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [addPic addAction:takePhoto];
    [addPic addAction:choosePhoto];
    [addPic addAction:cancel];
    [self presentViewController:addPic animated:YES completion:nil];
}
- (IBAction)shareWithTapped:(id)sender {
    UIAlertController *sharingOptions = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *private = [UIAlertAction actionWithTitle:NSLocalizedString(@"Private", @"post is private to the user")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        self.sharingWithLabel.text = NSLocalizedString(@"Just Me", @"post is private to the user");
    }];
    UIAlertAction *chooseGroup = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share with Group", @"choose a group to share the post with")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:segueToGroups sender:nil];
    }];
    UIAlertAction *allFriends = [UIAlertAction actionWithTitle:NSLocalizedString(@"All Friends", @"share post with all friends")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        self.sharingWithLabel.text = NSLocalizedString(@"All Friends", @"share post with all friends");
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"close alert controller")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [sharingOptions addAction:private];
    [sharingOptions addAction:chooseGroup];
    [sharingOptions addAction:allFriends];
    [sharingOptions addAction:cancel];
    [self presentViewController:sharingOptions animated:YES completion:nil];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Photo Functions

// image picker delegate function
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // Get the image captured by the UIImagePickerController
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.picImageView.image = [self resizeImage:editedImage withSize:CGSizeMake(1300.0, 1300.0)];
    NSLog(@"%f", self.picImageView.image.size.height);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void) takePhoto {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

-(void) choosePhoto {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

// function to resize images for Parse
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Navigation

- (IBAction) pinForPostChosenUnwind:(UIStoryboardSegue*)unwindSegue {
    MyPinsViewController *pinsVC = [unwindSegue sourceViewController];
    Pin *pin = pinsVC.chosenPin;
    self.locationLabel.text = pin.title;
    self.latitude = pin.latitude;
    self.longitude = pin.longitude;
}

- (IBAction) groupForPostChosenUnwind:(UIStoryboardSegue*)unwindSegue {
    GroupsViewController *groupsVC = [unwindSegue sourceViewController];
    Group *group = groupsVC.chosenGroup;
    self.sharingWithLabel.text = group.title;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"postedUpdate"]) {
        self.image = self.picImageView.image;
        self.caption = self.captionTextField.text;
        self.locationTitle = self.locationLabel.text;
    }
}

@end
