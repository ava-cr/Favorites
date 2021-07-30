//
//  ListFriendsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/16/21.
//

#import "ListFriendsViewController.h"
#import "ProfileViewController.h"
#import "ListFriendCell.h"
#import "Friend.h"
#import <Parse/Parse.h>

static NSString *unwindAddGroup = @"unwindToGroups";

@interface ListFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredFriends;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) NSMutableArray *groupUsernames;

@end

@implementation ListFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    [self.searchBar setTintColor:UIColor.systemPinkColor];
    self.groupUsernames = [[NSMutableArray alloc] init];
    self.members = [[NSMutableArray alloc] init];
    if (!self.friends) [self getFriends];
    else self.filteredFriends = [NSMutableArray arrayWithArray:self.friends];
    if (self.addToGroup) {
        self.title = NSLocalizedString(@"Choose Friends for your Group", @"add friends to group");
        self.tableView.allowsMultipleSelection = YES;
        [self.doneButton setEnabled:YES];
        [self.doneButton setTitle:NSLocalizedString(@"Done", @"finished selecting friends for group")];
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.title = NSLocalizedString(@"Friends", @"the user's friends");
        [self.doneButton setEnabled:NO];
        [self.doneButton setTitle:NSLocalizedString(@"", nil)];
        self.tableView.allowsMultipleSelection = NO;
    }
}

- (void) getFriends {
    // construct query
    PFQuery *queryUser1 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser1 whereKey:@"user1" equalTo:self.user];
    PFQuery *queryUser2 = [PFQuery queryWithClassName:@"Friend"];
    [queryUser2 whereKey:@"user2" equalTo:self.user];
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[queryUser1,queryUser2]];
    NSArray *keys = @[@"user1", @"user2", @"username"];
    [query includeKeys:keys];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *friends, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (friends != nil) {
                strongSelf.friends = [[NSArray alloc] init];
                strongSelf.filteredFriends = [[NSMutableArray alloc] init];
                NSLog(@"# of friends: %lu", (unsigned long)[friends count]);
                for (Friend *friend in friends) {
                    if ([friend.user1.objectId isEqual:strongSelf.user.objectId]) {
                        [strongSelf.filteredFriends addObject:friend.user2];
                    }
                    else [strongSelf.filteredFriends addObject:friend.user1];
                }
                strongSelf.friends = [NSArray arrayWithArray:strongSelf.filteredFriends];
                [self.tableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListFriendCell" forIndexPath:indexPath];
    PFUser *friend = self.filteredFriends[indexPath.row];
    cell.usernameLabel.text = friend.username;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.addToGroup) {
        PFUser *user = self.filteredFriends[indexPath.row];
        [self.groupUsernames addObject:user.username];
        [self.members addObject:user.objectId];
        NSLog(@"%@", user.username);
        NSLog(@"%@", user.objectId);
    }
    else [self performSegueWithIdentifier:@"showFriendProfile" sender:self.filteredFriends[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.addToGroup) {
        PFUser *user = self.filteredFriends[indexPath.row];
        [self.groupUsernames removeObject:user.username];
        [self.members removeObject:user.objectId];
    }
}
- (IBAction)doneButtonTapped:(id)sender {
    self.membersString = [[NSString alloc] init];
    for (NSString *username in self.groupUsernames) {
        self.membersString = [self.membersString stringByAppendingString:username];
        self.membersString = [self.membersString stringByAppendingString:@" "];
    }
    NSLog(@"%@", self.membersString);
    [self performSegueWithIdentifier:unwindAddGroup sender:nil];
}

# pragma mark - Search Bar Functions

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSLog(@"%@", searchText);
        NSArray *filtered = [self.friends filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(username contains[c] %@)", searchText]];
        self.filteredFriends = [NSMutableArray arrayWithArray:filtered];
    }
    else {
        self.filteredFriends = [NSMutableArray arrayWithArray:self.friends];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"showFriendProfile"]) {
        ProfileViewController *profVC = [segue destinationViewController];
        PFUser *friend = sender;
        profVC.user = friend;
    }
}



@end
