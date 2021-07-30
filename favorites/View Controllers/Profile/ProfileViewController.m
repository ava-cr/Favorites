//
//  ProfileViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "ProfileViewController.h"
#import "EditProfileViewController.h"
#import "ListFriendsViewController.h"
#import "MapViewController.h"
#import "CommentsViewController.h"
#import "LikesViewController.h"
#import "ProfileHeaderCell.h"
#import "ProfileUpdateCell.h"
#import <Parse/Parse.h>
#import <DateTools/DateTools.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <MaterialComponents/MaterialFlexibleHeader.h>
#import "Update.h"
#import "Friend.h"
#import "Like.h"
#import "Comment.h"

static NSString *segueToComments = @"showComments";
static NSString *segueToLikes = @"showLikes";

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, ProfileHeaderCellDelegate, ProfileUpdateCellDelegate, UIScrollViewDelegate, MDCFlexibleHeaderViewLayoutDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *updates;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableDictionary<NSString *, NSString *> *isLikedByUser;
@property(nonatomic) MDCFlexibleHeaderViewController *headerViewController;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (nonatomic, assign) BOOL isTabBar;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (!self.user) {
        self.isTabBar = YES;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.user = [PFUser currentUser];
        [self setUpFlexibleHeader];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.title = self.user.username;
    }
    self.updates = [[NSMutableArray alloc] init];
    [self getFriends];
    [self getUpdates];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self getFriends];
    [self getUpdates];
    [refreshControl endRefreshing];
}

#pragma mark - Flexible Header

- (void)setUpFlexibleHeader {
    self.headerViewController = [[MDCFlexibleHeaderViewController alloc] init];
    self.headerViewController.layoutDelegate = self;
    self.headerViewController.headerView.backgroundColor = UIColor.systemPinkColor;
    //self.headerViewController.headerView.minimumHeight = 120;
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.text = self.user.username;
    self.headerViewController.headerView.shiftBehavior = MDCFlexibleHeaderShiftBehaviorEnabled;
    PFFileObject *pfFile = [self.user objectForKey:@"profilePic"];
    NSURL *profURL = [NSURL URLWithString:pfFile.url];
    NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
    UIImage *img = [[UIImage alloc] initWithData:profURLData];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
    [imageView setAlpha:0.8];
    imageView.frame = self.headerViewController.headerView.bounds;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.headerViewController.headerView insertSubview:imageView atIndex:0];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    self.headerViewController.headerView.trackingScrollView = self.tableView;
    [self addChildViewController:self.headerViewController];
    [self.view addSubview:_headerViewController.view];
    self.title = self.user.username;
}

- (void)flexibleHeaderViewController:(MDCFlexibleHeaderViewController *)flexibleHeaderViewController
    flexibleHeaderViewFrameDidChange:(MDCFlexibleHeaderView *)flexibleHeaderView {
    int width = self.view.bounds.size.width;
    [self.usernameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.usernameLabel setFrame:CGRectMake(10, 20, width-10, flexibleHeaderView.scrollPhasePercentage * flexibleHeaderView.minimumHeight - 10)];
    CGFloat fontSize = flexibleHeaderView.scrollPhasePercentage * 40;
    [self.usernameLabel setFont:[UIFont systemFontOfSize:fontSize]];
    [self.headerViewController.headerView addSubview:self.usernameLabel];
    if (flexibleHeaderView.shiftedOffscreen) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

# pragma mark - Query Code

- (void) getUpdates {
    // construct query
    [SVProgressHUD show];
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    NSArray *keys = @[@"author", @"objectId", @"audience", @"group"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (updates != nil) {
                self.isLikedByUser = [[NSMutableDictionary alloc] init];
                for (Update *update in updates) {
                    // set all posts to unliked at first
                    [self.isLikedByUser setValue:@"0" forKey:update.objectId];
                    // if audience is everyone, or the current user is in the group, show the post
                    // show no private posts unless this is the current user's prof
                    if ([update.audience isEqual:@"everyone"] || [self.user isEqual:[PFUser currentUser]]) {
                        [strongSelf.updates addObject:update];
                    }
                    else {
                        for (NSString *objectID in update.group.members) {
                            if ([objectID isEqual:[PFUser currentUser].objectId]) {
                                [strongSelf.updates addObject:update];
                                break;
                            }
                        }
                    }
                }
                NSLog(@"got updates = %lu", [strongSelf.updates count]);
                [self getLikes];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}

- (void) getFriends {
    // construct query
    PFQuery *queryUser1 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser1 whereKey:@"user1" equalTo:self.user];
    PFQuery *queryUser2 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser2 whereKey:@"user2" equalTo:self.user];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryUser1,queryUser2]];
    NSArray *keys = @[@"user1", @"user2"];
    [query includeKeys:keys];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (friends != nil) {
                strongSelf.friends = [[NSMutableArray alloc] init];
                NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
                for (Friend *friend in friends) {
                    if ([friend.user1.objectId isEqual:strongSelf.user.objectId]) {
                        [strongSelf.friends addObject:friend.user2];
                    }
                    else [strongSelf.friends addObject:friend.user1];
                }
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}

- (void) getLikes {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    NSArray *keys = @[@"update", @"objectId", @"like"];
    [query includeKeys:keys];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    query.limit = 20;
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (likes != nil) {
                NSLog(@"got likes");
                for (Like *like in likes) {
                    [strongSelf.isLikedByUser setValue:@"1" forKey:like.update.objectId];
                }
                [strongSelf.tableView reloadData];
                [SVProgressHUD dismiss];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
#pragma mark - Cell Delegate Functions

- (void)tappedProfileButton:(ProfileHeaderCell *)cell {
    if ([self.user isEqual:[PFUser currentUser]]) {
        [self performSegueWithIdentifier:@"editProfile" sender:nil];
    }
    else {
        NSLog(@"show pins");
        [self performSegueWithIdentifier:@"showUserPins" sender:nil];
    }
}

- (void)tappedFriends:(ProfileHeaderCell *)cell {
    NSLog(@"tapped friends");
    [self performSegueWithIdentifier:@"listFriends" sender:nil];
}

- (void)didTapEditUpdate:(ProfileUpdateCell *)updateCell {
    UIAlertController *editUpdate = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"delete post")
                                                       style:UIAlertActionStyleDestructive
                                                     handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *deleteUpdate = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Are you sure?", @"message ensuring the user wants to delete their post") message:nil preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *delete = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"delete post")
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
            PFUser *currentUser = [PFUser currentUser];
            currentUser[@"numPosts"] = [NSNumber numberWithInt:([currentUser[@"numPosts"] intValue] - 1)];
            [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"updated user post count!");
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
            }];
            [self deleteUpdate:updateCell.update];
         }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"don't delete post")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
        [deleteUpdate addAction:cancel];
        [deleteUpdate addAction:delete];
        [self presentViewController:deleteUpdate animated:YES completion:nil];
                                                     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"don't delete post")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [editUpdate addAction:delete];
    [editUpdate addAction:cancel];
    [self presentViewController:editUpdate animated:YES completion:nil];
}
- (void) deleteUpdate:(Update *)update {
    typeof(self) __weak weakSelf = self;
    [update deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (succeeded) {
                NSLog(@"deleted post %@", update.caption);
                [self deleteLikes:update]; // delete all likes and comments
            }
            else {
                NSLog(@"problem deleting post: %@", error.localizedDescription);
            }
        }
    }];
}
-(void) deleteLikes:(Update *)update {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query whereKey:@"update" equalTo:update];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *likes, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (likes != nil) {
                [Like deleteAllInBackground:likes block:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"deleted likes");
                        [strongSelf deleteComments:update];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
-(void) deleteComments:(Update *)update {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"update" equalTo:update];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (comments != nil) {
                [Comment deleteAllInBackground:comments block:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        NSLog(@"deleted comments");
                        [strongSelf getUpdates];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
- (void)updateCell:(ProfileUpdateCell *)updateCell likedUpdate:(Update *)update {
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
        typeof(self) __weak weakSelf = self;
        [Like createLike:[PFUser currentUser] onUpdate:update withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
            typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                if (succeeded) {
                    NSLog(@"created new like!");
                    [strongSelf sendLikePush:update];
                    [strongSelf getUpdates];
                } else {
                    NSLog(@"%@", error.localizedDescription);
                }
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
        [self deleteUserLike:update];
    }
}
-(void) deleteUserLike:(Update *)update {
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
                    if (succeeded) {
                        NSLog(@"deleted like");
                        [strongSelf getUpdates];
                    } else {
                        NSLog(@"%@", error.localizedDescription);
                    }
                }];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
- (void)pressedComments:(ProfileUpdateCell *)updateCell {
    [self performSegueWithIdentifier:segueToComments sender:updateCell.update];
}
- (void)pressedLikeLabel:(ProfileUpdateCell *)updateCell {
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

#pragma mark - Table View Functions

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.updates count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.user) self.user = [PFUser currentUser];
    if (indexPath.row == 0) {
        ProfileHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.contentView.backgroundColor = [UIColor colorWithRed:1.0 green:45/255.0 blue:85/255.0 alpha:0.65];
        // number of posts/pins/friends labels
        if ([[self.user objectForKey:@"numPosts"] isEqual:[NSNumber numberWithInt:1]]) {
            cell.numPostsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPosts"]] stringByAppendingString:NSLocalizedString(@" Post", @"user's post singular")];
        }
        else cell.numPostsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPosts"]] stringByAppendingString:NSLocalizedString(@" Posts", @"user's posts plural")];
        
        if ([[self.user objectForKey:@"numPins"] isEqual:[NSNumber numberWithInt:1]]) {
            cell.numPinsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPins"]] stringByAppendingString:NSLocalizedString(@" Pin", @"user's pin singular")];
        }
        else cell.numPinsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPins"]] stringByAppendingString:NSLocalizedString(@" Pins", @"user's pins plural")];
        if ((int)[self.friends count] == 1) {
            cell.numFriendsLabel.text = [[NSString stringWithFormat:@"%d", (int)[self.friends count]] stringByAppendingString:NSLocalizedString(@" Friend", @"user's friend singular")];
        }
        else cell.numFriendsLabel.text = [[NSString stringWithFormat:@"%d", (int)[self.friends count]] stringByAppendingString:NSLocalizedString(@" Friends", @"user's friends plural")];
        // edit profile / see pins button
        if (![self.user isEqual:[PFUser currentUser]]) [cell.editProfileButton setTitle:NSLocalizedString(@"See Pins", @"show user's pins") forState:UIControlStateNormal];
        else [cell.editProfileButton setTitle:NSLocalizedString(@"Edit Profile", @"edit the profile photo") forState:UIControlStateNormal];
        cell.editProfileButton.layer.cornerRadius = 5;
        cell.editProfileButton.layer.borderColor = [UIColor.systemPinkColor CGColor];
        cell.editProfileButton.layer.borderWidth = 0.5;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        // profile picture
        PFFileObject *pfFile = [self.user objectForKey:@"profilePic"];
        NSURL *url = [NSURL URLWithString:pfFile.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        cell.profilePicImageView.image = [[UIImage alloc] initWithData:urlData];
        return cell;
    }
    else {
        ProfileUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileUpdateCell" forIndexPath:indexPath];
        Update *update = self.updates[indexPath.row - 1];
        if([self.user isEqual:[PFUser currentUser]]) {
            [cell.editUpdateLabel setEnabled:TRUE];
            [cell.editUpdateLabel setHidden:FALSE];
        }
        else {
            [cell.editUpdateLabel setEnabled:FALSE];
            [cell.editUpdateLabel setHidden:TRUE];
        }
        cell.delegate = self;
        cell.update = update;
        cell.user = self.user;
         if (self.updates) {
             cell.usernameLabel.text = update.author.username;
             cell.bottomUsernameLabel.text = update.author.username;
             cell.captionTextField.text = update.caption;
             if ([update.locationTitle isEqual:[update.author.username stringByAppendingString:NSLocalizedString(@"'s location", @"adding the word location to the user's username")]]) {
                 cell.isAtLabel.text = @"";
             }
             else cell.isAtLabel.text = @"is at ";
             [cell.locationButton setTitle:update.locationTitle forState:UIControlStateNormal];
             NSURL *url = [NSURL URLWithString:update.image.url];
             NSData *urlData = [NSData dataWithContentsOfURL:url];
             cell.picImageView.image = [[UIImage alloc] initWithData:urlData];
             cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
             PFFileObject *pfFile = [self.user objectForKey:@"profilePic"];
             NSURL *profURL = [NSURL URLWithString:pfFile.url];
             NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
             cell.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
             NSDate *createdAt = update.createdAt;
             NSString *createdAtString = createdAt.shortTimeAgoSinceNow;
             cell.timestampLabel.text = [createdAtString stringByAppendingString:@" ago"];
             // like label code
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
         }
        return cell;
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if (scrollView == self.headerViewController.headerView.trackingScrollView) {
    [self.headerViewController.headerView trackingScrollViewDidScroll];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (scrollView == self.headerViewController.headerView.trackingScrollView) {
    [self.headerViewController.headerView trackingScrollViewDidEndDecelerating];
  }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (scrollView == self.headerViewController.headerView.trackingScrollView) {
    [self.headerViewController.headerView trackingScrollViewDidEndDraggingWillDecelerate:decelerate];
  }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
  if (scrollView == self.headerViewController.headerView.trackingScrollView) {
    [self.headerViewController.headerView trackingScrollViewWillEndDraggingWithVelocity:velocity
                                                                           targetContentOffset:targetContentOffset];
  }
}

# pragma mark - Navigation

- (IBAction) unwindToProfile:(UIStoryboardSegue *)unwindSegue {
    EditProfileViewController *sourceVC = [unwindSegue sourceViewController];
    PFUser *user = [PFUser currentUser];
    PFFileObject *pfFile = [Update getPFFileFromImage:sourceVC.profilePicture];
    user[@"profilePic"] = pfFile;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      if (succeeded) {
          NSLog(@"updated profile picture!");
          [self.tableView reloadData];
      } else {
          NSLog(@"%@", error.localizedDescription);
      }
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if ([segue.identifier isEqual:@"showUserPins"]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.user = self.user;
    }
    else if ([segue.identifier isEqual:@"listFriends"]) {
        ListFriendsViewController *friendsVC = [segue destinationViewController];
        friendsVC.friends = self.friends;
        friendsVC.user = self.user;
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
