//
//  AddFriendsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "AddFriendsViewController.h"
#import "AddFriendCell.h"
#import "Friend.h"
#import "FriendRequest.h"
#import <Parse/Parse.h>

@interface AddFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AddFriendCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSMutableArray *filteredUsers;
@property (strong, nonatomic) NSMutableArray *requestedUsers;
@property (strong, nonatomic) NSMutableArray *friends;

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    [self getFriendRequests];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.filteredUsers) {
        return [self.filteredUsers count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendCell" forIndexPath:indexPath];
    if (self.filteredUsers) {
        PFUser *user = self.filteredUsers[indexPath.row];
        cell.user = user;
        cell.delegate = self;
        cell.usernameLabel.text = user.username;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        if ([self.requestedUsers containsObject:user]) {
            [cell.addFriendButton setHidden:TRUE];
            [cell.addFriendButton setTitle:@"Requested" forState:UIControlStateNormal];
            NSLog(@"here");
        }
    }
    return cell;
}

- (void) getUsers {
    // construct query
    PFQuery *query = [PFUser query];
    [query includeKey:@"username"];
    NSArray *offLimits = [self.requestedUsers arrayByAddingObjectsFromArray:self.friends];
    [query whereKey:@"objectId" notContainedIn:offLimits];
    //[query whereKey:@"objectId" notContainedIn:self.friends];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.users = users;
            self.filteredUsers = [NSMutableArray arrayWithArray:self.users];
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) getFriendRequests {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query includeKey:@"requestee"];
    [query includeKey:@"objectId"];
    [query whereKey:@"requester" equalTo:[PFUser currentUser]];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *requests, NSError *error) {
        if (requests != nil) {
            // self.requests = [NSMutableArray arrayWithArray:requests];
            NSLog(@"# of requests: %lu", (unsigned long)[requests count]);
            self.requestedUsers = [[NSMutableArray alloc] init];
            for (FriendRequest *request in requests) {
                [self.requestedUsers addObject:request.requestee.objectId];
            }
            NSLog(@"%@", self.requestedUsers);
            [self getFriends];
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
    NSArray *keys = @[@"user1", @"user2", @"objectId"];
    [query includeKeys:keys];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        if (friends != nil) {
            NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
            self.friends = [[NSMutableArray alloc] init];
            for (Friend *friend in friends) {
                if ([friend.user1.objectId isEqual:[PFUser currentUser].objectId]) {
                    [self.friends addObject:friend.user2.objectId];
                }
                else [self.friends addObject:friend.user1.objectId];
            }
            [self getUsers];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)addFriendCell:(AddFriendCell *)addFriendCell pressedAdd:(PFUser *)user {
    NSLog(@"add friend: %@", user.username);
    [FriendRequest createFriendRequest:user withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"friend requested %@", user.username);
            [self sendFriendRequestPush:user];
        } else {
            NSLog(@"problem saving friend request: %@", error.localizedDescription);
        }
    }];
}
- (void)sendFriendRequestPush:(PFUser *)user {
    NSString *message = [[PFUser currentUser].username stringByAppendingString:@" wants to be friends!"];
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{@"message": message, @"userid": user.objectId}
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

# pragma mark - Search Bar Functions

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSLog(@"%@", searchText);
        NSArray *filteredUsers = [self.users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(username contains[c] %@)", searchText]];
        self.filteredUsers = [NSMutableArray arrayWithArray:filteredUsers];
    }
    else {
        self.filteredUsers = [NSMutableArray arrayWithArray:self.users];
    }
    [self.tableView reloadData];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}

@end
