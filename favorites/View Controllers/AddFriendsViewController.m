//
//  AddFriendsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "AddFriendsViewController.h"
#import "AddFriendCell.h"
#import <Parse/Parse.h>

@interface AddFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, AddFriendCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSMutableArray *filteredUsers;

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    
    [self getUsers];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.filteredUsers) {
        return [self.filteredUsers count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddFriendCell"];
    if (self.filteredUsers) {
        PFUser *user = self.filteredUsers[indexPath.row];
        cell.user = user;
        cell.delegate = self;
        cell.usernameLabel.text = user.username;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
    }
    return cell;
}

- (void) getUsers {
    // construct query
    PFQuery *query = [PFUser query];
    [query includeKey:@"username"];
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    //query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (users != nil) {
            self.users = users;
            self.filteredUsers = [NSMutableArray arrayWithArray:self.users];
            [self.tableView reloadData];
            NSLog(@"got users");
            NSLog(@"%lu", (unsigned long)[self.users count]);
            for (PFUser *user in self.users) {
                NSLog(@"%@", user.username);
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)addFriendCell:(AddFriendCell *)addFriendCell pressedAdd:(PFUser *)user {
    NSLog(@"add friend: %@", user.username);
    
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
