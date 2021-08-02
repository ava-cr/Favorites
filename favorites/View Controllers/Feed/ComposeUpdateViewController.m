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
#import <JVFloatLabeledTextField/JVFloatLabeledTextView.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>

static NSString *segueToGroups = @"showMyGroups";
static NSString *postedUpdateUnwind = @"postedUpdate";

@interface ComposeUpdateViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;
@property (weak, nonatomic) IBOutlet UILabel *sharingWithLabel;
@property (strong, nonatomic) JVFloatLabeledTextView *captionTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *shareWithButton;
@property (strong, nonatomic) VBFPopFlatButton *cancelButton;
@property (strong, nonatomic) VBFPopFlatButton *postButton;

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
    self.sharingWithLabel.text = NSLocalizedString(@"All Friends", @"default sharing label");
    self.locationLabel.text = NSLocalizedString(@"None", @"default location label");
    [self setUpTextView];
    self.addPhotoButton.layer.cornerRadius = 8;
    self.addLocationButton.layer.cornerRadius = 8;
    self.shareWithButton.layer.cornerRadius = 8;
    [self.addPhotoButton setTitle:NSLocalizedString(@"Add Photo", @"title of button to add photo") forState:UIControlStateNormal];
    [self.addLocationButton setTitle:NSLocalizedString(@"Add Location", @"title of button to add location") forState:UIControlStateNormal];
    [self.shareWithButton setTitle:NSLocalizedString(@"Share with", @"title of button to choose who to share post with") forState:UIControlStateNormal];
    [self setUpButtons];
}

-(void)dismissKeyboard {
    [self.captionTextView resignFirstResponder];
}

-(void)setUpButtons {
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
    self.postButton = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 50, 20, 30, 30)
                                                  buttonType:buttonDefaultType
                                                 buttonStyle:buttonRoundedStyle
                                                 animateToInitialState:YES];
    self.postButton.lineThickness = 3;
    self.postButton.tintColor = [UIColor systemPinkColor];
    [self.postButton addTarget:self
                               action:@selector(postButtonPressed)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postButton];
    NSTimeInterval delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.cancelButton animateToType:buttonCloseType];
        [self.postButton animateToType:buttonOkType];
    });
}

-(void) cancelButtonPressed {
    [self.cancelButton animateToType:buttonMinusType];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void) postButtonPressed {
    [self.postButton animateToType:buttonMinusType];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:postedUpdateUnwind sender:nil];
    });
}

-(void)setUpTextView {
    int y = self.locationLabel.frame.origin.y + 30;
    self.captionTextView = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + self.view.frame.size.width/2 - 150, y, 300, 100)];
    [self.captionTextView setPlaceholder:NSLocalizedString(@"Write a caption...", @"placeholder text to prompt user to type a caption")];
    [self.captionTextView setTintColor:UIColor.systemPinkColor];
    [self.captionTextView setScrollEnabled:YES];
    [self.view addSubview:self.captionTextView];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *userLocation = locations[0];
    self.userLocation = userLocation;
}

- (IBAction)addLocationTapped:(id)sender {
    UIAlertController *addLoc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    [addLoc.view setTintColor:UIColor.systemPinkColor];
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
    [addPic.view setTintColor:UIColor.systemPinkColor];
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
    [sharingOptions.view setTintColor:UIColor.systemPinkColor];
    UIAlertAction *private = [UIAlertAction actionWithTitle:NSLocalizedString(@"Private", @"post is private to the user")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        self.sharingWithLabel.text = NSLocalizedString(@"Just Me", @"post is private to the user");
        self.audience = @"private";
    }];
    UIAlertAction *chooseGroup = [UIAlertAction actionWithTitle:NSLocalizedString(@"Share with Group", @"choose a group to share the post with")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        self.audience = @"group";
        [self performSegueWithIdentifier:segueToGroups sender:nil];
    }];
    UIAlertAction *allFriends = [UIAlertAction actionWithTitle:NSLocalizedString(@"All Friends", @"share post with all friends")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        self.sharingWithLabel.text = NSLocalizedString(@"All Friends", @"share post with all friends");
        self.audience = @"everyone";
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
    NSLog(@"keyboard will show %f", keyboardSize.height);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -(keyboardSize.height - 80);
        self.view.frame = f;
    }];
}
-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
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
    self.group = group;
    self.sharingWithLabel.text = group.title;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:postedUpdateUnwind]) {
        self.image = self.picImageView.image;
        self.caption = self.captionTextView.text;
        self.locationTitle = self.locationLabel.text;
    }
}

@end
