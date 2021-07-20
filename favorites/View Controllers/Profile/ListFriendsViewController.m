//
//  ListFriendsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/16/21.
//

#import "ListFriendsViewController.h"
#import "ProfileViewController.h"
#import "ListFriendCell.h"

@interface ListFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *filteredFriends;

@end

@implementation ListFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    self.filteredFriends = [NSMutableArray arrayWithArray:self.friends];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.filteredFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListFriendCell"];
    PFUser *friend = self.filteredFriends[indexPath.row];
    cell.usernameLabel.text = friend.username;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showFriendProfile" sender:self.filteredFriends[indexPath.row]];
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
