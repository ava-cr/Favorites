//
//  EditProfileViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import "EditProfileViewController.h"
#import <Parse/Parse.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import "Update.h"

static NSString *unwindToProfile = @"saveProfileEdits";

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (strong, nonatomic) VBFPopFlatButton *cancelButton;
@property (strong, nonatomic) VBFPopFlatButton *saveButton;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profilePicImageView.image = self.profilePicture;
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.layer.bounds.size.height /2;
    [self setUpButtons];
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
}

-(void) cancelButtonPressed {
    [self.cancelButton animateToType:buttonMinusType];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

-(void) saveButtonPressed {
    [self.saveButton animateToType:buttonMinusType];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:unwindToProfile sender:nil];
    });
}

- (IBAction)tappedCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)tappedChangeProfilePic:(id)sender {
    UIAlertController *changeProf = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    [changeProf.view setTintColor:UIColor.systemPinkColor];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", @"use camera to take photo for post")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [self takePhoto];
                                                     }];
    UIAlertAction *choosePhoto = [UIAlertAction actionWithTitle:NSLocalizedString(@"Choose From Library", @"choose photo from library for post")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // choose photo
        [self choosePhoto];
                                                     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"close alert controller")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    // add the actions to the alert controller
    [changeProf addAction:takePhoto];
    [changeProf addAction:choosePhoto];
    [changeProf addAction:cancel];
    [self presentViewController:changeProf animated:YES completion:nil];
}

// image picker delegate function
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    self.profilePicImageView.image = [self resizeImage:editedImage withSize:CGSizeMake(600.0, 600.0)];
    
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
        NSLog(@"Camera ???? available so we will use photo library instead");
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:unwindToProfile]) {
        self.profilePicture = self.profilePicImageView.image;
    }
}

@end
