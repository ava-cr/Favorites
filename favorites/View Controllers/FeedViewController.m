//
//  FeedViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "FeedViewController.h"
#import "Update.h"
#import "ComposeUpdateViewController.h"
#import "UpdateCell.h"
#import "ShowLocationOnMapViewController.h"

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UpdateCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *updates;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self getUpdates];
}

- (void) getUpdates {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Update"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *updates, NSError *error) {
        if (updates != nil) {
            self.updates = updates;
            [self.tableView reloadData];
            NSLog(@"got updates");
            for (Update *update in self.updates) {
                NSLog(@"%@", update.caption);
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.updates) {
        NSLog(@"%lu", (unsigned long)[self.updates count]);
        return [self.updates count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UpdateCell"];
    Update *update = self.updates[indexPath.row];
    
    if (self.updates) {
        cell.update = update;
        cell.delegate = self;
        cell.usernameLabel.text = update.author.username;
        cell.bottomUsernameLabel.text = update.author.username;
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
        cell.captionTextField.text = update.caption;
        
        if ([update.locationTitle isEqual:[update.author.username stringByAppendingString:@"'s location"]]) {
            cell.isAtLabel.text = @"";
        }
        else {
            cell.isAtLabel.text = @"is at ";
        }
        [cell.locationButton setTitle:update.locationTitle forState:UIControlStateNormal];
        NSURL *url = [NSURL URLWithString:update.image.url];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        cell.picImageView.image = [[UIImage alloc] initWithData:urlData];
    }
    return cell;
}

- (void)updateCell:(UpdateCell *)updateCell pressedLocation:(Update *)update {
    [self performSegueWithIdentifier:@"showLocationOnMap" sender:update];
}

#pragma mark - Navigation

- (IBAction) postedUpdateUnwind:(UIStoryboardSegue*)unwindSegue {
    ComposeUpdateViewController *composeVC = [unwindSegue sourceViewController];
    
    [Update postUserUpdate:composeVC.image withCaption:composeVC.caption locationTitle:composeVC.locationTitle lat:composeVC.latitude lng:composeVC.longitude withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the update was posted!");
            [self getUpdates];
        } else {
            NSLog(@"problem saving update: %@", error.localizedDescription);
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"showLocationOnMap"]) {
        ShowLocationOnMapViewController *vc = [segue destinationViewController];
        Update *update = sender;
        vc.update = update;
        vc.title = update.locationTitle;
    }
}

@end
