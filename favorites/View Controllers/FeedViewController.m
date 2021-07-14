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

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSArray *updates;

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
    //query.limit = numberPosts;
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
            //if ([self.updates count] < numberPosts) self.loadedAllData = true;
            
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
    NSLog(@"%@", update.caption);
    if (self.updates) {
        //cell.post = post;
        //cell.delegate = self; // for tap gesture recognizer
        cell.usernameLabel.text = @"hello";
//        cell.bottomUsernameLabel.text = update.author.username;
//        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
//        cell.captionTextField.text = update.caption;
//
//        NSURL *url = [NSURL URLWithString:update.image.url];
//        NSData *urlData = [NSData dataWithContentsOfURL:url];
//        cell.picImageView.image = [[UIImage alloc] initWithData:urlData];
        
//        NSDate *createdAt = post.createdAt;
//        NSString *createdAtString = createdAt.shortTimeAgoSinceNow;
//        cell.timestampLabel.text = [createdAtString stringByAppendingString:@" ago"];
//
//        PFFileObject *pfFile = [post.author objectForKey:@"profilePic"];
        
//        NSURL *profURL = [NSURL URLWithString:pfFile.url];
//        NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
//        cell.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
        
        // num likes label
//        if (cell.post.likeCount.intValue == 1) {
//            cell.numLikesLabel.text = [cell.post.likeCount.stringValue stringByAppendingString:@" like"];
//        }
//        else cell.numLikesLabel.text = [cell.post.likeCount.stringValue stringByAppendingString:@" likes"];
    }
    else {
        NSLog(@"no updates");
    }
    
    return cell;
}


#pragma mark - Navigation

- (IBAction) postedUpdateUnwind:(UIStoryboardSegue*)unwindSegue {
    ComposeUpdateViewController *composeVC = [unwindSegue sourceViewController];
    
    [Update postUserUpdate:composeVC.image withCaption:composeVC.caption withCompletion:^(BOOL succeeded, NSError * error) {
        if (succeeded) {
            NSLog(@"the update was posted!");
            [self getUpdates];
        } else {
            NSLog(@"problem saving update: %@", error.localizedDescription);
        }
    }];
}


/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
