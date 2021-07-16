//
//  PinDetailsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/13/21.
//

#import "PinDetailsViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface PinDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

@end

@implementation PinDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.annotation.titleString;
    self.notesTextView.text = self.annotation.notes;
    if (![self.user isEqual:[PFUser currentUser]]) {
        [self.notesTextView setEditable:FALSE];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqual:@"savePin"]) {
        self.annotation.pin.notes = self.notesTextView.text;
    }
}


@end
