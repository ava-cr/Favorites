//
//  LikesViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/22/21.
//

#import "LikesViewController.h"
#import "ProfileViewController.h"
#import "LikeCell.h"
#import "Like.h"
#import <Parse/Parse.h>

static NSString *likeCellID = @"LikeCell";
static NSString *segueToUserProfile = @"showProfile";

@interface LikesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *likes;

@end

@implementation LikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self getLikes];
}
- (void) getLikes {
    PFQuery *query = [PFQuery queryWithClassName:@"Like"];
    [query includeKey:@"user"];
    [query whereKey:@"update" equalTo:self.update];
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable likes, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (likes != nil) {
                strongSelf.likes = likes;
                [strongSelf.tableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.likes) {
        return [self.likes count];
    }
    else return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LikeCell *cell = [tableView dequeueReusableCellWithIdentifier:likeCellID forIndexPath:indexPath];
    if (self.likes) {
        Like *like = self.likes[indexPath.row];
        cell.usernameLabel.text = like.user.username;
        if ([like.user objectForKey:@"profilePic"]) {
            PFFileObject *pfFile = [like.user objectForKey:@"profilePic"];
            NSURL *profURL = [NSURL URLWithString:pfFile.url];
            NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
            cell.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
        }
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Like *like = self.likes[indexPath.row];
    [self performSegueWithIdentifier:segueToUserProfile sender:like.user];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:segueToUserProfile]) {
        ProfileViewController *profVC = [segue destinationViewController];
        PFUser *user = sender;
        profVC.user = user;
    }
}

@end
