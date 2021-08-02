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
#import <VBFPopFlatButton/VBFPopFlatButton.h>

static NSString *unwindAddGroup = @"unwindToGroups";

@interface ListFriendsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *filteredFriends;
@property (strong, nonatomic) NSMutableArray *groupUsernames;
@property (strong, nonatomic) VBFPopFlatButton *saveButton;

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
        [self setUpButton];
        self.tableView.allowsMultipleSelection = YES;
    }
    else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.title = NSLocalizedString(@"Friends", @"the user's friends");
        self.tableView.allowsMultipleSelection = NO;
    }
}

- (void)setUpButton {
    self.saveButton = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 140, 40, 40)
                                                  buttonType:buttonDefaultType
                                                 buttonStyle:buttonRoundedStyle
                                                 animateToInitialState:YES];
    self.saveButton.lineThickness = 3;
    self.saveButton.roundBackgroundColor = [UIColor whiteColor];
    self.saveButton.tintColor = [UIColor systemPinkColor];
    [self.saveButton addTarget:self
                               action:@selector(saveButtonPressed)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveButton];
    NSTimeInterval delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.saveButton animateToType:buttonOkType];
    });
}

- (void)saveButtonPressed {
    [self.saveButton animateToType:buttonMinusType];
    self.membersString = [[NSString alloc] init];
    for (NSString *username in self.groupUsernames) {
        self.membersString = [self.membersString stringByAppendingString:username];
        self.membersString = [self.membersString stringByAppendingString:@" "];
    }
    NSLog(@"%@", self.membersString);
    NSTimeInterval delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:unwindAddGroup sender:nil];
    });
}

- (void)getFriends {
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
