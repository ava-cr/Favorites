//
//  MyPinsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/14/21.
//

#import "MyPinsViewController.h"
#import "MyPinCell.h"
#import <Parse/Parse.h>
#import "Pin.h"

@interface MyPinsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *pins;
@property (strong, nonatomic) NSMutableArray *filteredPins;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation MyPinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBar.delegate = self;
    [self getPins];
}

-(void) getPins {
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
    query.limit = 20;
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (pins != nil) {
                strongSelf.pins = pins;
                NSLog(@"got pins");
                strongSelf.filteredPins = [NSMutableArray arrayWithArray:strongSelf.pins];
                [strongSelf.tableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.filteredPins) return [self.filteredPins count];
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyPinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyPinCell" forIndexPath:indexPath];
    if (self.filteredPins) {
        Pin *pin = self.filteredPins[indexPath.row];
        cell.titleLabel.text = pin.title;
        cell.pin = pin;
    }
    return cell;
}
# pragma mark - Search Bar Functions

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length != 0) {
        NSArray *filteredPins = [self.pins filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(title contains[c] %@)", searchText]];
        self.filteredPins = [NSMutableArray arrayWithArray:filteredPins];
    }
    else {
        self.filteredPins = [NSMutableArray arrayWithArray:self.pins];
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
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"locationChosen"]) {
        MyPinCell *tappedCell = sender;
        self.chosenPin = tappedCell.pin;
    }
}

@end
