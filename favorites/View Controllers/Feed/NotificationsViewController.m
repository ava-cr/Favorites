//
//  NotificationsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/15/21.
//

#import "NotificationsViewController.h"
#import "FriendRequestCell.h"
#import "CommentNotificationCell.h"
#import "FriendRequest.h"
#import "Friend.h"
#import "Comment.h"
#import <Parse/Parse.h>

static NSString *commentCellID = @"CommentNotificationCell";

@interface NotificationsViewController () <UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *friendRequests;
@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSArray *updates;

@end

@implementation NotificationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self getFriendRequests];
    [self getUpdates];
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
            //[self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)friendRequestCell:(FriendRequestCell *)friendRequestCell pressedAccept:(FriendRequest *)request {
    // delete friend request object & create a friend object
    [request deleteInBackground];
    [Friend createFriends:request.requester withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the current user and %@ are now friends!", request.requester.username);
            [self sendFriendAcceptedPush:request.requester];
        }
        else {
            NSLog(@"problem saving friend: %@", error.localizedDescription);
        }
    }];
}
- (void) getUpdates {
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    //NSArray *keys = @[@"author", @"image"];
    [query includeKey:@"author"];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        if (updates != nil) {
            self.updates = updates;
            [self getComments];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (void) getComments {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"update" containedIn:self.updates];
    NSArray *keys = @[@"author", @"text", @"update", @"image"];
    [query includeKeys:keys];
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments != nil) {
            self.comments = comments;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        if (self.friendRequests) {
            return [self.friendRequests count];
        }
        else return 0;
    }
    else {
        if (self.comments) {
            return [self.comments count];
        }
        else return 0;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendRequestCell" forIndexPath:indexPath];
        if (self.friendRequests) {
            FriendRequest *request = self.friendRequests[indexPath.row];
            cell.request = request;
            cell.delegate = self;
            cell.usernameLabel.text = request.requester.username;
            cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        }
        return cell;
    }
    else {
        CommentNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellID forIndexPath:indexPath];
        Comment *comment = self.comments[indexPath.row - [self.friendRequests count]];
        cell.usernameLabel.text = comment.author.username;
        cell.commentLabel.text = comment.text;
        PFFileObject *pfFile = [comment.author objectForKey:@"profilePic"];
        NSURL *profURL = [NSURL URLWithString:pfFile.url];
        NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
        cell.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        NSURL *url = [NSURL URLWithString:comment.update.image.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        cell.picImageView.image = [[UIImage alloc] initWithData:urlData];
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @" Friend Requests";
    }
    else return @" Comments";
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (void)sendFriendAcceptedPush:(PFUser *)user {
    NSString *message = [[PFUser currentUser].username stringByAppendingString:@" accepted your friend request!"];
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

@end
