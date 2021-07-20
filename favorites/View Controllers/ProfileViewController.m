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
#import "ProfileHeaderCell.h"
#import "ProfileUpdateCell.h"
#import <Parse/Parse.h>
#import "Update.h"
#import "Friend.h"

// static int numFriends;

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, ProfileHeaderCellDelegate, ProfileUpdateCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *updates;
@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(beginRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:refreshControl atIndex:0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (!self.user) self.user = [PFUser currentUser];
    self.title = self.user.username;
    [self getFriends];
    [self getUpdates];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self getFriends];
    [self getUpdates];
    [refreshControl endRefreshing];
}

- (void) getUpdates {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:self.user];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        if (updates != nil) {
            self.updates = updates;
            [self.tableView reloadData];
            NSLog(@"got updates");
            for (Update *update in self.updates) {
                NSLog(@"%@", update.caption);
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
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

    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            self.friends = [[NSMutableArray alloc] init];
            NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
            for (Friend *friend in friends) {
                if ([friend.user1.objectId isEqual:self.user.objectId]) {
                    [self.friends addObject:friend.user2];
                }
                else [self.friends addObject:friend.user1];
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

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
            [updateCell.update deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    NSLog(@"deleted post %@", updateCell.update.caption);
                    [self getUpdates];
                }
                else {
                    NSLog(@"problem deleting post: %@", error.localizedDescription);
                }
            }];
         }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"don't delete post")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {}];
        [deleteUpdate addAction:cancel];
        [deleteUpdate addAction:delete];
        [self presentViewController:deleteUpdate animated:YES completion:nil];
                                                     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", @"don't delete post")
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {}];
    [editUpdate addAction:delete];
    [editUpdate addAction:cancel];
    [self presentViewController:editUpdate animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.updates count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.user) self.user = [PFUser currentUser];
    if (indexPath.row == 0) {
        ProfileHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell"];
        cell.delegate = self;
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
        cell.editProfileButton.layer.cornerRadius = 5;
        cell.editProfileButton.layer.borderColor = [UIColor.systemBlueColor CGColor];
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
        ProfileUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileUpdateCell"];
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
        NSLog(@"%@", cell.user.username);
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
         }
        return cell;
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
    if ([segue.identifier isEqual:@"showUserPins"]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.user = self.user;
    }
    else if ([segue.identifier isEqual:@"listFriends"]) {
        ListFriendsViewController *friendsVC = [segue destinationViewController];
        friendsVC.friends = self.friends;
    }
}

@end
