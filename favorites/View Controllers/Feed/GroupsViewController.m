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
#import <SCLAlertView_Objective_C/SCLAlertView.h>
#import <VBFPopFlatButton/VBFPopFlatButton.h>
#import <pop/POP.h>

static NSString *cellId = @"GroupCell";
static NSString *segueToFriends = @"showFriends";
static NSString *unwindToCompose = @"groupChosen";

@interface GroupsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) NSString *addedGroupName;
@property (strong, nonatomic) VBFPopFlatButton *addButton;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Groups", @"groups user can choose to share post with");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self getGroups];
    [self setUpButton];
    [self animate];
}

- (void)animate {
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 60)];
    anim.springBounciness = 30;
    anim.springSpeed = 0.7;
    [self.view pop_addAnimation:anim forKey:@"size"];
}

- (void)setUpButton {
    self.addButton = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 140, 40, 40)
                                                  buttonType:buttonDefaultType
                                                 buttonStyle:buttonRoundedStyle
                                                 animateToInitialState:YES];
    self.addButton.lineThickness = 3;
    self.addButton.roundBackgroundColor = [UIColor whiteColor];
    self.addButton.tintColor = [UIColor systemPinkColor];
    [self.addButton addTarget:self
                               action:@selector(addButtonPressed)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addButton];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.addButton animateToType:buttonAddType];
    });
}

- (void)addButtonPressed {
    [self.addButton animateToType:buttonMinusType];
    NSTimeInterval delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        SCLAlertView *addGroup = [[SCLAlertView alloc] init];
        UITextField *textField = [addGroup addTextField:@"Enter a group name"];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        addGroup.customViewColor = [UIColor systemPinkColor];
        addGroup.cornerRadius = 15;
        addGroup.horizontalButtons = YES;
        addGroup.shouldDismissOnTapOutside = YES;
        [addGroup setShowAnimationType:SCLAlertViewShowAnimationSlideInToCenter];
        [addGroup setBackgroundType:SCLAlertViewBackgroundBlur];
        [addGroup alertIsDismissed:^{
            [self.addButton animateToType:buttonAddType];
        }];
        [addGroup addButton:NSLocalizedString(@"Done", @"finished typing name") actionBlock:^(void) {
            NSLog(@"Text value: %@", textField.text);
            self.addedGroupName = textField.text;
            [self performSegueWithIdentifier:segueToFriends sender:nil];
        }];
        [addGroup showEdit:self title:NSLocalizedString(@"Add a Group", @"adding a group alert") subTitle:NSLocalizedString(@"Give your group a name", @"prompting user to name group") closeButtonTitle:NSLocalizedString(@"Cancel", @"close alert") duration:0.0f];
    });
}

- (void)getGroups {
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
    cell.contentView.backgroundColor = [UIColor systemPinkColor];
    if (self.groups) {
        Group *group = self.groups[indexPath.row];
        cell.titleLabel.text = group.title;
        cell.memberStringLabel.text = group.membersString;
        cell.group = group;
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
    [self.addButton animateToType:buttonAddType];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:segueToFriends]) {
        ListFriendsViewController *friendsVC = [segue destinationViewController];
        friendsVC.addToGroup = YES;
        friendsVC.user = [PFUser currentUser];
    }
    else if ([segue.identifier isEqual:unwindToCompose]) {
        GroupCell *tappedCell = sender;
        self.chosenGroup = tappedCell.group;
    }
}

@end
