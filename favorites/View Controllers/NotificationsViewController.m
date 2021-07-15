//
//  NotificationsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import "NotificationsViewController.h"
#import "FriendRequestCell.h"
#import "FriendRequest.h"
#import <Parse/Parse.h>

@interface NotificationsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friendRequests;

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self getFriendRequests];
}

- (void) getFriendRequests {
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query includeKey:@"requester"];
    [query whereKey:@"requestee" equalTo:[PFUser currentUser]];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests != nil) {
            NSLog(@"%lu", (unsigned long)[requests count]);
            self.friendRequests = requests;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.friendRequests) {
        return [self.friendRequests count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCell"];
    if (self.friendRequests) {
        FriendRequest *request = self.friendRequests[indexPath.row];
        cell.usernameLabel.text = request.requester.username;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Friend Requests";
    }
    else return @"";
}

@end
