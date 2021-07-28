//
//  LoginViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <JVFloatLabeledTextField/JVFloatLabeledTextField.h>

static int width = 200;
static int height = 60;

@interface LoginViewController ()

@property (strong, nonatomic) JVFloatLabeledTextField *usernameField;
@property (strong, nonatomic) JVFloatLabeledTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapScreen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tapScreen];
    [self.logInButton setTitle:NSLocalizedString(@"Log In", @"log in button title") forState:UIControlStateNormal];
    [self.signUpButton setTitle:NSLocalizedString(@"Sign Up", @"sign up button title") forState:UIControlStateNormal];
    [self setUpTextFields];
}

-(void)setUpTextFields {
    int y = self.view.bounds.size.height/2 - 175;
    int x = self.view.bounds.origin.x + self.view.bounds.size.width/2 - width/2;
    self.usernameField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(x, y, width, height)];
    [self.usernameField setPlaceholder:NSLocalizedString(@"username", @"username string")];
    [self.usernameField setTintColor:UIColor.systemPinkColor];
    [self.usernameField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.usernameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.usernameField setTextAlignment:NSTextAlignmentCenter];
    CGFloat fontSize = 25.0;
    UIFont *newFont = [self.usernameField.font fontWithSize:fontSize];
    self.usernameField.font = newFont;
    [self.view addSubview:self.usernameField];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(x, y + height, width, 0.75)];
    [line setBackgroundColor:UIColor.whiteColor];
    [self.view addSubview:line];
    self.passwordField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(x, y + height + 10, width, height)];
    [self.passwordField setPlaceholder:NSLocalizedString(@"password", @"password string")];
    [self.passwordField setTintColor:UIColor.systemPinkColor];
    [self.passwordField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.passwordField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.passwordField setTextAlignment:NSTextAlignmentCenter];
    [self.passwordField setSecureTextEntry:YES];
    self.passwordField.font = newFont;
    [self.view addSubview:self.passwordField];
    UIView *passwordLine = [[UIView alloc] initWithFrame:CGRectMake(x, y + 2*height + 10, width, 0.75)];
    [passwordLine setBackgroundColor:UIColor.whiteColor];
    [self.view addSubview:passwordLine];
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
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
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
    [UIView animateWithDuration:0.7 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -30;
        self.view.frame = f;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.7 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

@end
