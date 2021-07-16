//
//  AddPinViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "AddPinViewController.h"

@interface AddPinViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@end

@implementation AddPinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.pin.name;
    self.subtitleLabel.text = self.pin.phoneNumber;
    self.notesTextView.layer.borderColor = [UIColor.whiteColor CGColor];
    self.notesTextView.layer.borderWidth = 1.0;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.notes = self.notesTextView.text;
}


@end
