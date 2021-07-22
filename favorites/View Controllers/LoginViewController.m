//
//  LoginViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
}
- (void)viewDidAppear:(BOOL)animated {
 [self askToSendPushnotifications];
}
- (void)askToSendPushnotifications {
 UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Send a push to the news channel"
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleAlert];
 UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
 popPresenter.sourceView = self.view;
 UIAlertAction *Okbutton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
     [self sendPushNotifications];
 }];
 [alert addAction:Okbutton];
 UIAlertAction *cancelbutton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

 }];
 [alert addAction:cancelbutton];
 popPresenter.sourceRect = self.view.frame;
 alert.modalPresentationStyle = UIModalPresentationPopover;
 [self presentViewController:alert animated:YES completion:nil];
}
       - (void)sendPushNotifications {
 [PFCloud callFunctionInBackground:@"pushsample"
                    withParameters:@{}
                             block:^(id object, NSError *error) {
                                 if (!error) {
                                     NSLog(@"PUSH SENT");
                                 }else{
                                     NSLog(@"ERROR SENDING PUSH: %@",error.localizedDescription);
                                 }
                             }];
}

-(void)dismissKeyboard {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (IBAction)didTapLogIn:(id)sender {
    NSString *username = self.usernameField.text;
        NSString *password = self.passwordField.text;
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
            if (error != nil) {
                NSLog(@"User log in failed: %@", error.localizedDescription);
            } else {
                NSLog(@"User logged in successfully");
                
                [self performSegueWithIdentifier:@"loginSegue" sender:nil];
            }
        }];
}
- (IBAction)didTapSignUp:(id)sender {
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

@end
