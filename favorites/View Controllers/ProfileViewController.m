//
//  ProfileViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "ProfileViewController.h"
#import "EditProfileViewController.h"
#import "MapViewController.h"
#import "ProfileHeaderCell.h"
#import "ProfileUpdateCell.h"
#import <Parse/Parse.h>
#import "Update.h"

static int numFriends;

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, ProfileHeaderCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *updates;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (!self.user) self.user = [PFUser currentUser];
    self.title = self.user.username;
    [self getFriends];
    [self getUpdates];
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

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
            numFriends = (int)[friends count];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)profileHeaderCell:(ProfileHeaderCell *)profileHeaderCell {
    if ([self.user isEqual:[PFUser currentUser]]) {
        [self performSegueWithIdentifier:@"showProfile" sender:nil];
    }
    else {
        NSLog(@"show pins");
        [self performSegueWithIdentifier:@"showUserPins" sender:nil];
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.updates count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (!self.user) self.user = [PFUser currentUser];
        ProfileHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell"];
        cell.delegate = self;
        if (![self.user isEqual:[PFUser currentUser]]) {
            [cell.editProfileButton setTitle:@"See Pins" forState:UIControlStateNormal];
        }
        cell.numPostsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPosts"]] stringByAppendingString:@" Posts"];
        cell.numPinsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPins"]] stringByAppendingString:@" Pins"];
        cell.numFriendsLabel.text = [[NSString stringWithFormat:@"%d", numFriends] stringByAppendingString:@" Friends"];
        cell.editProfileButton.layer.cornerRadius = 5;
        cell.editProfileButton.layer.borderColor = [UIColor.systemBlueColor CGColor];
        cell.editProfileButton.layer.borderWidth = 0.5;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        PFFileObject *pfFile = [self.user objectForKey:@"profilePic"];
        NSURL *url = [NSURL URLWithString:pfFile.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        cell.profilePicImageView.image = [[UIImage alloc] initWithData:urlData];
        return cell;
    }
    else {
        ProfileUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileUpdateCell"];
         Update *update = self.updates[indexPath.row - 1];
         if (self.updates) {
             cell.usernameLabel.text = update.author.username;
             cell.bottomUsernameLabel.text = update.author.username;
             cell.captionTextField.text = update.caption;
             if ([update.locationTitle isEqual:[update.author.username stringByAppendingString:@"'s location"]]) {
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
}

@end
