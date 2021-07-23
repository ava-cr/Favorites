//
//  FeedViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "FeedViewController.h"
#import "Update.h"
#import "ComposeUpdateViewController.h"
#import "UpdateCell.h"
#import "ShowLocationOnMapViewController.h"
#import "ProfileViewController.h"
#import "CommentsViewController.h"
#import "LikesViewController.h"
#import "Friend.h"
#import "Like.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <DateTools/DateTools.h>

static NSString *segueToComments = @"showComments";
static NSString *segueToLikes = @"showLikes";

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UpdateCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *updates;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *isLikedByUser;
@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setContainerView:self.view];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.friends = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser], nil];
    //[self getFriends];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self getFriends];
    [refreshControl endRefreshing];
}

- (void) getUpdates {
    // activity monitor
    [SVProgressHUD show];
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    NSArray *keys = @[@"update", @"author", @"objectId"];
    [query includeKeys:keys];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"author" containedIn:self.friends];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        if (updates != nil) {
            self.updates = updates;
            NSLog(@"got updates");
            self.isLikedByUser = [[NSMutableDictionary alloc] init];
            for (Update *update in self.updates) { // set all updates to unliked initially
                [self.isLikedByUser setValue:@"0" forKey:update.objectId];
                NSLog(@"%@", self.isLikedByUser[update.objectId]);
            }
            [self getLikes];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (void) getLikes {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    NSArray *keys = @[@"update", @"objectId", @"like"];
    [query includeKeys:keys];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        if (likes != nil) {
            NSLog(@"got likes");
            for (Like *like in likes) {
                [self.isLikedByUser setValue:@"1" forKey:like.update.objectId];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [SVProgressHUD dismiss];
    }];
}
- (void) getFriends {
    // construct query
    PFQuery *queryUser1 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser1 whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryUser2 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser2 whereKey:@"user2" equalTo:[PFUser currentUser]];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryUser1,queryUser2]];
    NSArray *keys = @[@"user1", @"user2"];
    [query includeKeys:keys];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
            for (Friend *friend in friends) {
                if ([friend.user1.objectId isEqual:[PFUser currentUser].objectId]) {
                    [self.friends addObject:friend.user2];
                }
                else [self.friends addObject:friend.user1];
            }
            NSLog(@"%@", self.friends);
            [self getUpdates];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.updates) {
        NSLog(@"%lu", (unsigned long)[self.updates count]);
        return [self.updates count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateCell" forIndexPath:indexPath];
    Update *update = self.updates[indexPath.row];
    
    if (self.updates) {
        cell.update = update;
        cell.delegate = self;
        cell.usernameLabel.text = update.author.username;
        cell.bottomUsernameLabel.text = update.author.username;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        PFFileObject *pfFile = [update.author objectForKey:@"profilePic"];
        NSURL *profURL = [NSURL URLWithString:pfFile.url];
        NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
        cell.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
        cell.captionTextField.text = update.caption;
        int likeCount = [cell.update[@"likeCount"] intValue];
        NSString *singularLikedLabel = NSLocalizedString(@" other", @"post liked by 1 other");
        NSString *pluralLikedLabel = NSLocalizedString(@" others", @"post liked by others");
        if ([self.isLikedByUser[cell.update.objectId] isEqual:@"1"]) {
            NSString *labelText = [NSLocalizedString(@"liked by you and ", @"post liked by user") stringByAppendingString:[NSString stringWithFormat:@"%d", likeCount - 1]];
            if (likeCount == 2) cell.likedLabel.text = [labelText stringByAppendingString:singularLikedLabel];
            else cell.likedLabel.text = [labelText stringByAppendingString:pluralLikedLabel];
            cell.likedLabel.text = [@"💗" stringByAppendingString:cell.likedLabel.text];
            cell.likedLabel.textColor = UIColor.systemPinkColor;
        }
        else if (likeCount != 0) {
            NSString *labelText = [NSLocalizedString(@"liked by ", @"post not liked by user") stringByAppendingString:[NSString stringWithFormat:@"%d", likeCount]];
            if (likeCount == 1) cell.likedLabel.text = [labelText stringByAppendingString:singularLikedLabel];
            else cell.likedLabel.text = [labelText stringByAppendingString:pluralLikedLabel];
            cell.likedLabel.textColor = UIColor.labelColor;
        }
        else {
            cell.likedLabel.text = @"";
        }
        if ([update.locationTitle isEqual:[update.author.username stringByAppendingString:NSLocalizedString(@"'s location", nil)]] || [update.locationTitle isEqual:@""]) {
            cell.isAtLabel.text = @"";
        }
        else {
            cell.isAtLabel.text = NSLocalizedString(@"is at ", @"formulating location string");
        }
        [cell.locationButton setTitle:update.locationTitle forState:UIControlStateNormal];
        NSURL *url = [NSURL URLWithString:update.image.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        cell.picImageView.image = [[UIImage alloc] initWithData:urlData];
        NSDate *createdAt = update.createdAt;
        NSString *createdAtString = createdAt.shortTimeAgoSinceNow;
        cell.timestampLabel.text = [createdAtString stringByAppendingString:@" ago"];
    }
    return cell;
}

# pragma mark - Update Cell Delegate Methods
- (void)updateCell:(UpdateCell *)updateCell pressedLocation:(Update *)update {
    [self performSegueWithIdentifier:@"showLocationOnMap" sender:update];
}
- (void)updateCell:(UpdateCell *)updateCell didTapUser:(PFUser *)user {
    [self performSegueWithIdentifier:@"showProfile" sender:user];
}
- (void)updateCell:(UpdateCell *)updateCell likedUpdate:(Update *)update {
    NSLog(@"%@", self.isLikedByUser[update.objectId]);
    if ([self.isLikedByUser[update.objectId] isEqual:@"0"]) {
        // create a like object, increment like count
        update[@"likeCount"] = [NSNumber numberWithInt:([update[@"likeCount"] intValue] + 1)];
        [update saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"updated update like count! %@", update[@"likeCount"]);
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        [self.isLikedByUser setValue:@"1" forKey:update.objectId];
        [Like createLike:[PFUser currentUser] onUpdate:update withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"created new like!");
                [self sendLikePush:update];
                [self getUpdates];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }
    else {
        // delete a like object, decrememt like count
        [self.isLikedByUser setValue:@"0" forKey:update.objectId];
        update[@"likeCount"] = [NSNumber numberWithInt:([update[@"likeCount"] intValue] - 1)];
        [update saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"updated update like count! %@", update[@"likeCount"]);
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        [self deleteLike:update];
    }
}
-(void) deleteLike:(Update *)update {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"update" equalTo:update];
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        if (likes != nil) {
            Like *like = likes[0];
            [like deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(succeeded) {
                    NSLog(@"deleted like");
                    [self getUpdates];
                }
                else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (void)pressedComments:(UpdateCell *)updateCell {
    [self performSegueWithIdentifier:segueToComments sender:updateCell.update];
}
- (void)pressedLikeLabel:(UpdateCell *)updateCell {
    [self performSegueWithIdentifier:segueToLikes sender:updateCell.update];
}
- (void)sendLikePush:(Update *)update {
    NSString *message = [[PFUser currentUser].username stringByAppendingString:@" liked your post"];
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{@"message": message, @"userid": update.author.objectId}
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

- (IBAction) postedUpdateUnwind:(UIStoryboardSegue*)unwindSegue {
    
    ComposeUpdateViewController *composeVC = [unwindSegue sourceViewController];
    
    PFUser *currentUser = [PFUser currentUser];
    currentUser[@"numPosts"] = [NSNumber numberWithInt:([currentUser[@"numPosts"] intValue] + 1)];
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"updated user post count!");
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    [Update postUserUpdate:composeVC.image withCaption:composeVC.caption locationTitle:composeVC.locationTitle lat:composeVC.latitude lng:composeVC.longitude withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the update was posted!");
            [self getUpdates];
        } else {
            NSLog(@"problem saving update: %@", error.localizedDescription);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"showLocationOnMap"]) {
        ShowLocationOnMapViewController *showLocationVC = [segue destinationViewController];
        Update *update = sender;
        showLocationVC.update = update;
        showLocationVC.title = update.locationTitle;
        if ([update.locationTitle isEqual:[update.author.username stringByAppendingString:NSLocalizedString(@"'s location", nil)]]) {
            showLocationVC.isPin = FALSE;
        }
        else showLocationVC.isPin = TRUE;
    }
    else if ([segue.identifier isEqual:@"showProfile"]) {
        ProfileViewController *vc = [segue destinationViewController];
        PFUser *user = sender;
        vc.user = user;
    }
    else if ([segue.identifier isEqual:segueToComments]) {
        Update *update = sender;
        CommentsViewController *commentsVC = [segue destinationViewController];
        commentsVC.update = update;
    }
    else if ([segue.identifier isEqual:segueToLikes]) {
        Update *update = sender;
        LikesViewController *likesVC = [segue destinationViewController];
        likesVC.update = update;
    }
}

@end
