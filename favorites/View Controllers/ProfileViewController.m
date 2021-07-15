//
//  ProfileViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "ProfileViewController.h"
#import "ProfileHeaderCell.h"
#import "ProfileUpdateCell.h"
#import <Parse/Parse.h>
#import "Update.h"

static int numFriends;

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource>

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
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
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
    [queryUser1 whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryUser2 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser2 whereKey:@"user2" equalTo:[PFUser currentUser]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.updates count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (!self.user) self.user = [PFUser currentUser];
        ProfileHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileHeaderCell"];
        cell.numPostsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPosts"]] stringByAppendingString:@" Posts"];
        cell.numPinsLabel.text = [[NSString stringWithFormat:@"%@",[self.user objectForKey:@"numPins"]] stringByAppendingString:@" Pins"];
        cell.numFriendsLabel.text = [[NSString stringWithFormat:@"%d", numFriends] stringByAppendingString:@" Friends"];
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        cell.editProfileButton.layer.cornerRadius = 5;
        cell.editProfileButton.layer.borderColor = [UIColor.systemBlueColor CGColor];
        cell.editProfileButton.layer.borderWidth = 0.5;
        return cell;
    }
    else {
        ProfileUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileUpdateCell"];
         Update *update = self.updates[indexPath.row - 1];
         if (self.updates) {
             cell.usernameLabel.text = update.author.username;
             cell.bottomUsernameLabel.text = update.author.username;
             cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
             cell.captionTextField.text = update.caption;
             if ([update.locationTitle isEqual:[update.author.username stringByAppendingString:@"'s location"]]) {
                 cell.isAtLabel.text = @"";
             }
             else cell.isAtLabel.text = @"is at ";
             [cell.locationButton setTitle:update.locationTitle forState:UIControlStateNormal];
             NSURL *url = [NSURL URLWithString:update.image.url];
             NSData *urlData = [NSData dataWithContentsOfURL:url];
             cell.picImageView.image = [[UIImage alloc] initWithData:urlData];
         }
         
        return cell;
    }
}

@end
