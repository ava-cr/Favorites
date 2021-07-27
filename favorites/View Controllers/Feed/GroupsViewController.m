//
//  GroupsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/27/21.
//

#import "GroupsViewController.h"
#import "ListFriendsViewController.h"
#import "Group.h"
#import "GroupCell.h"
#import <Parse/Parse.h>

static NSString *cellId = @"GroupCell";
static NSString *segueToFriends = @"showFriends";

@interface GroupsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) NSString *addedGroupName;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Groups", @"groups user can choose to share post with");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self getGroups];
}
- (IBAction)addButtonTapped:(id)sender {
    UIAlertController *addGroup = [UIAlertController alertControllerWithTitle:@"Add a Group"
                                                                   message:@"Give your group a name"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *addTitle = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
        NSLog(@"%@", addGroup.textFields[0].text);
        self.addedGroupName = addGroup.textFields[0].text;
        [self performSegueWithIdentifier:segueToFriends sender:nil];
    }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"close add group alert")
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {}];
    [addGroup addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.delegate = self;
    }];
    [addGroup addAction:addTitle];
    [addGroup addAction:cancel];
    [self presentViewController:addGroup animated:YES completion:^{
    }];
}

-(void) getGroups {
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    NSArray *keys = @[@"title", @"membersString", @"members", @"user"];
    [query includeKeys:keys];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    query.limit = 20;
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (groups != nil) {
                strongSelf.groups = groups;
                NSLog(@"got groups");
                // strongSelf.filteredPins = [NSMutableArray arrayWithArray:strongSelf.pins];
                [strongSelf.tableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.groups) {
        return [self.groups count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (self.groups) {
        Group *group = self.groups[indexPath.row];
        cell.titleLabel.text = group.title;
        cell.memberStringLabel.text = group.membersString;
    }
    return cell;
}

#pragma mark - Navigation

- (IBAction) addGroupUnwind:(UIStoryboardSegue*)unwindSegue {
    ListFriendsViewController *friendsVC = [unwindSegue sourceViewController];
    NSArray *members = friendsVC.members;
    NSString *membersString = friendsVC.membersString;
    [Group createGroup:self.addedGroupName byUser:[PFUser currentUser] withMembers:members andMembersString:membersString withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self getGroups];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:segueToFriends]) {
        ListFriendsViewController *friendsVC = [segue destinationViewController];
        friendsVC.addToGroup = YES;
        friendsVC.user = [PFUser currentUser];
    }
}

@end
