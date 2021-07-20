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
#import "Friend.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UpdateCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *updates;
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
    [self getFriends];
}

- (void)beginRefresh:(UIRefreshControl *)refreshControl {
    [self getFriends];
    [refreshControl endRefreshing];
}

- (void) getUpdates {
    // activity monitor
    [SVProgressHUD show];
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"author" containedIn:self.friends];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        if (updates != nil) {
            self.updates = updates;
            [self.tableView reloadData];
            NSLog(@"got updates");
            [SVProgressHUD dismiss];
            for (Update *update in self.updates) {
                NSLog(@"%@", update.caption);
            }
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
    
    UpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateCell"];
    Update *update = self.updates[indexPath.row];
    
    if (self.updates) {
        cell.update = update;
        cell.delegate = self;
        cell.usernameLabel.text = update.author.username;
        cell.bottomUsernameLabel.text = update.author.username;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        PFFileObject *pfFile = [update.author objectForKey:@"profilePic"];
        NSURL *profURL = [NSURL URLWithString:pfFile.url];
        NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
        cell.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
        cell.captionTextField.text = update.caption;
        
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
    }
    return cell;
}

- (void)updateCell:(UpdateCell *)updateCell pressedLocation:(Update *)update {
    [self performSegueWithIdentifier:@"showLocationOnMap" sender:update];
}

- (void)updateCell:(UpdateCell *)updateCell didTapUser:(PFUser *)user {
    [self performSegueWithIdentifier:@"showProfile" sender:user];
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
        ShowLocationOnMapViewController *vc = [segue destinationViewController];
        Update *update = sender;
        vc.update = update;
        vc.title = update.locationTitle;
    }
    else if ([segue.identifier isEqual:@"showProfile"]) {
        ProfileViewController *vc = [segue destinationViewController];
        PFUser *user = sender;
        vc.user = user;
    }
}

@end
