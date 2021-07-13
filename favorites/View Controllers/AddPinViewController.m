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
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = self.location.name;
    self.subtitleLabel.text = self.location.phoneNumber;
    
    self.notesTextView.layer.borderColor = [UIColor.whiteColor CGColor];
    self.notesTextView.layer.borderWidth = 1.0;
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    self.notes = self.notesTextView.text;
}


@end
