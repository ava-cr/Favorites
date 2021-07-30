//
//  UpdateDetailsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/21/21.
//

#import "UpdateDetailsViewController.h"
#import "CommentsViewController.h"
#import "LikesViewController.h"
#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import <DateTools/DateTools.h>
#import "Like.h"

static NSString *segueToComments = @"showComments";
static NSString *segueToLikes = @"showLikes";
static NSString *segueToProfile = @"showProfile";

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
@property (weak, nonatomic) IBOutlet UILabel *sharingWithLabel;

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
    UITapGestureRecognizer *doubleTapToLike = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didLikeUpdate:)];
    [self.picImageView addGestureRecognizer:doubleTapToLike];
    [doubleTapToLike setNumberOfTapsRequired:2];
    [self.picImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapLikeLabel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapLikeLabel:)];
    [self.likedLabel addGestureRecognizer:tapLikeLabel];
    [self.likedLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer *profileTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profilePicImageView addGestureRecognizer:profileTapGestureRecognizer];
    [self.profilePicImageView setUserInteractionEnabled:YES];
    if ([self.update.audience isEqual:@"group"] && self.update.group) {
        self.sharingWithLabel.text = [NSLocalizedString(@"shared with ", @"the post is shared with this group") stringByAppendingString:self.update.group.title];
    }
    else if ([self.update.audience isEqual:@"private"]) {
        self.sharingWithLabel.text = NSLocalizedString(@"shared with just me", @"the post is private");
    }
    else self.sharingWithLabel.text = NSLocalizedString(@"shared with everyone", @"the post is shared with everyone");
}
- (void)didTapUserProfile:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:segueToProfile sender:self.update.author];
}
- (void)didTapLikeLabel:(UITapGestureRecognizer *)sender {
    [self performSegueWithIdentifier:segueToLikes sender:nil];
}
- (void)didLikeUpdate:(UITapGestureRecognizer *)sender {
    if (!self.isLikedByUser) { // create a like object, increment like count
        self.update[@"likeCount"] = [NSNumber numberWithInt:([self.update[@"likeCount"] intValue] + 1)];
        [self.update saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"updated update like count! %@", self.update[@"likeCount"]);
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        self.isLikedByUser = TRUE;
        typeof(self) __weak weakSelf = self;
        [Like createLike:[PFUser currentUser] onUpdate:self.update withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (succeeded) {
                    NSLog(@"created new like!");
                    [strongSelf sendLikePush];
                    [strongSelf getLiked];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }
        }];
    }
    else {
        // delete a like object, decrememt like count
        self.isLikedByUser = FALSE;
        self.update[@"likeCount"] = [NSNumber numberWithInt:([self.update[@"likeCount"] intValue] - 1)];
        [self.update saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"updated update like count!");
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        [self deleteLike:self.update];
    }
}
-(void) deleteLike:(Update *)update {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"update" equalTo:update];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (likes != nil) {
                Like *like = likes[0];
                [like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded) {
                        NSLog(@"deleted like");
                        [strongSelf getLiked];
                    }
                    else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
- (void) getLiked {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"update" equalTo:self.update];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable likes, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (likes != nil) {
                if ([likes count] != 0) strongSelf.isLikedByUser = TRUE;
                else strongSelf.isLikedByUser = FALSE;
                [strongSelf setLikedLabelText];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
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
- (void)sendLikePush {
    NSString *message = [[PFUser currentUser].username stringByAppendingString:@" liked your post"];
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{@"message": message, @"userid": self.update.author.objectId}
                                block:^(id object, NSError *error) {
                                    if (!error) {
                                        NSLog(@"PUSH SENT");
                                    } else {
                                        [self displayMessageToUser:error.debugDescription];
                                    }
    }];
}
// push notification error message display function
- (void)displayMessageToUser:(NSString*)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Message"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
    popPresenter.sourceView = self.view;
    UIAlertAction *Okbutton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

    }];
    [alert addAction:Okbutton];
    popPresenter.sourceRect = self.view.frame;
    alert.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:segueToComments]) {
        CommentsViewController *commentsVC = [segue destinationViewController];
        commentsVC.update = self.update;
    }
    else if ([segue.identifier isEqual:segueToLikes]) {
        LikesViewController *likesVC = [segue destinationViewController];
        likesVC.update = self.update;
    }
    else if ([segue.identifier isEqual:segueToProfile]) {
        ProfileViewController *profVC = [segue destinationViewController];
        PFUser *user = sender;
        profVC.user = user;
    }
}

@end
