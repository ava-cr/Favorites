//
//  UpdateDetailsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/21/21.
//

#import "UpdateDetailsViewController.h"
#import "CommentsViewController.h"
#import <Parse/Parse.h>
#import <DateTools/DateTools.h>
#import "Like.h"

static NSString *segueToComments = @"showComments";

@interface UpdateDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *picImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *isAtLabel;
@property (weak, nonatomic) IBOutlet UITextField *captionTextField;
@property (weak, nonatomic) IBOutlet UILabel *likedLabel;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (nonatomic, assign) BOOL isLikedByUser;

@end

@implementation UpdateDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getLiked];
    self.usernameLabel.text = self.update.author.username;
    self.bottomUsernameLabel.text = self.update.author.username;
    self.profilePicImageView.layer.cornerRadius = self.profilePicImageView.layer.bounds.size.height / 2;
    PFFileObject *pfFile = [self.update.author objectForKey:@"profilePic"];
    NSURL *profURL = [NSURL URLWithString:pfFile.url];
    NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
    self.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
    self.captionTextField.text = self.update.caption;
    if ([self.update.locationTitle isEqual:[self.update.author.username stringByAppendingString:NSLocalizedString(@"'s location", nil)]] || [self.update.locationTitle isEqual:@""]) {
         self.isAtLabel.text = @"";
     }
     else {
         self.isAtLabel.text = NSLocalizedString(@"is at ", @"formulating location string");
     }
     [self.locationButton setTitle:self.update.locationTitle forState:UIControlStateNormal];
     NSURL *url = [NSURL URLWithString:self.update.image.url];
     NSData *urlData = [NSData dataWithContentsOfURL:url];
     self.picImageView.image = [[UIImage alloc] initWithData:urlData];
     NSDate *createdAt = self.update.createdAt;
     NSString *createdAtString = createdAt.shortTimeAgoSinceNow;
     self.timestampLabel.text = [createdAtString stringByAppendingString:@" ago"];
}

- (void) getLiked {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"update" equalTo:self.update];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable likes, NSError * _Nullable error) {
        if (likes != nil) {
            if ([likes count] != 0) self.isLikedByUser = TRUE;
            else self.isLikedByUser = FALSE;
            [self setLikedLabelText];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) setLikedLabelText {
    int likeCount = [self.update[@"likeCount"] intValue];
    NSString *singularLikedLabel = NSLocalizedString(@" other", @"post liked by 1 other");
    NSString *pluralLikedLabel = NSLocalizedString(@" others", @"post liked by others");
    if (self.isLikedByUser) {
        NSString *labelText = [NSLocalizedString(@"liked by you and ", @"post liked by user") stringByAppendingString:[NSString stringWithFormat:@"%d", likeCount - 1]];
        if (likeCount == 2) self.likedLabel.text = [labelText stringByAppendingString:singularLikedLabel];
        else self.likedLabel.text = [labelText stringByAppendingString:pluralLikedLabel];
        self.likedLabel.text = [@"💗" stringByAppendingString:self.likedLabel.text];
        self.likedLabel.textColor = UIColor.systemPinkColor;
    }
    else if (likeCount != 0) {
        NSString *labelText = [NSLocalizedString(@"liked by ", @"post not liked by user") stringByAppendingString:[NSString stringWithFormat:@"%d", likeCount]];
        if (likeCount == 1) self.likedLabel.text = [labelText stringByAppendingString:singularLikedLabel];
        else self.likedLabel.text = [labelText stringByAppendingString:pluralLikedLabel];
        self.likedLabel.textColor = UIColor.labelColor;
    }
    else {
        self.likedLabel.text = @"";
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:segueToComments]) {
        CommentsViewController *commentsVC = [segue destinationViewController];
        commentsVC.update = self.update;
    }
}

@end
