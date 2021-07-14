//
//  ComposeUpdateViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "ComposeUpdateViewController.h"
#import "MyPinsViewController.h"
#import "Pin.h"
#import <CoreLocation/CoreLocation.h>

@interface ComposeUpdateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;

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
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *userLocation = locations[0];
    self.userLocation = userLocation;
}

- (IBAction)addLocationTapped:(id)sender {
    UIAlertController *addLoc = [UIAlertController alertControllerWithTitle:@"Add Location" message:@""preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *myLocation = [UIAlertAction actionWithTitle:@"Use My Location"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // self.locationLabel.text = [NSString stringWithFormat:@"%f", self.userLocation.coordinate.latitude];
        self.locationLabel.text = @"My Current Location";
        
    }];
    UIAlertAction *chooseLocation = [UIAlertAction actionWithTitle:@"Choose From Locations"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self performSegueWithIdentifier:@"showMyPins" sender:nil];
    }];
    [addLoc addAction:myLocation];
    [addLoc addAction:chooseLocation];
    [self presentViewController:addLoc animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
    
    
}
- (IBAction)addPhotoTapped:(id)sender {
    UIAlertController *addPic = [UIAlertController alertControllerWithTitle:@"Add Photo" message:@""preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto]; // take photo
    }];
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:@"Choose From Library"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self choosePhoto]; // choose photo
    }];
    [addPic addAction:takePhoto];
    [addPic addAction:choosePhoto];
    [self presentViewController:addPic animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}
- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Photo Functions

// image picker delegate function
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    //UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    self.picImageView.image = [self resizeImage:editedImage withSize:CGSizeMake(700.0, 700.0)];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
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
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"postedUpdate"]) {
        self.image = self.picImageView.image;
        self.caption = self.captionTextField.text;
    }
    
}

@end
