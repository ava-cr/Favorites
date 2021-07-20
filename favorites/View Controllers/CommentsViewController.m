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
@property (strong, nonatomic) NSArray *comments;

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
            [self.tableView reloadData];
            self.commentTextView.text = @"";
            [self.view endEditing:YES];
        } else {
            NSLog(@"problem saving comment: %@", error.localizedDescription);
        }
    }];
}
- (void) getComments {
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query includeKey:@"author"];
    [query whereKey:@"update" equalTo:self.update];
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:^(NSArray *comments, NSError *error) {
        if (comments != nil) {
            self.comments = comments;
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
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellID];
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
