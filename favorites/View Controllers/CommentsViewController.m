//
//  CommentsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/20/21.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "Comment.h"
#import <Parse/Parse.h>

@interface CommentsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *comments;

@end

static NSString *commentCellID = @"CommentCell";

@implementation CommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Comments", @"users' comments on the update");
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.commentTextView.layer.borderColor = [UIColor.labelColor CGColor];
    self.commentTextView.layer.borderWidth = 0.75;
    self.commentTextView.layer.cornerRadius = 8;
    self.commentTextView.textContainer.lineFragmentPadding = 10;
    [self getComments];
}
- (IBAction)didTapPost:(id)sender {
    [Comment userCommentOnUpdate:self.commentTextView.text onUpdate:self.update withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"the comment was posted!");
            [self getComments];
            [self sendPush:self.commentTextView.text];
            self.commentTextView.text = @"";
            [self.view endEditing:YES];
        } else {
            NSLog(@"problem saving comment: %@", error.localizedDescription);
        }
    }];
}
- (void)sendPush:(NSString *)comment {
    NSString *message = [[PFUser currentUser].username stringByAppendingString:@" commented '"];
    message = [[message stringByAppendingString:comment] stringByAppendingString:@"'on your post."];
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{@"message": message, @"userid": self.update.author.objectId}
                                block:^(id object, NSError *error) {
                                    if (!error) {
                                        NSLog(@"PUSH SENT");
                                    }else{
                                        //[self displayMessageToUser:error.debugDescription];
                                    }
                                }];
}
- (void) getComments {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    NSArray *keys = @[@"author", @"update"];
    [query includeKeys:keys];
    [query whereKey:@"update" equalTo:self.update];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments != nil) {
            self.comments = [NSMutableArray arrayWithArray:comments];
            NSLog(@"got comments");
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.comments) {
        return [self.comments count];
    }
    else return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellID forIndexPath:indexPath];
    if (self.comments) {
        Comment *comment = self.comments[indexPath.row];
        cell.commentLabel.text = comment.text;
        cell.usernameLabel.text = comment.author.username;
        PFFileObject *pfFile = [comment.author objectForKey:@"profilePic"];
        NSURL *profURL = [NSURL URLWithString:pfFile.url];
        NSData *profURLData = [NSData dataWithContentsOfURL:profURL];
        cell.profilePicImageView.image = [[UIImage alloc] initWithData:profURLData];
        cell.profilePicImageView.layer.cornerRadius = cell.profilePicImageView.layer.bounds.size.height / 2;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld", (long)indexPath.row);
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Comment *comment = self.comments[indexPath.row];
        [comment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                NSLog(@"deleted comment");
            }
            else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
        [self.comments removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }
    else {
        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // can only delete a comment if it is your post or your comment
    Comment *comment = self.comments[indexPath.row];
    if ([comment.author.objectId isEqual:[PFUser currentUser].objectId] || [comment.update.author.objectId isEqual:[PFUser currentUser].objectId]) {
        return TRUE;
    }
    else return FALSE;
}

// code to move the view up when the keyboard shows
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSLog(@"keyboard will show %f", keyboardSize.height);
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = -(keyboardSize.height - 80);
        self.view.frame = f;
    }];
}
-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

@end
