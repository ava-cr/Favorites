//
//  ListPinsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import "ListPinsViewController.h"
#import "ListPinCell.h"
#import "Pin.h"

@interface ListPinsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *pins;

@end

@implementation ListPinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (!self.user) self.user = [PFUser currentUser];
    [self getPins];
}

-(void) getPins {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:self.user];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        if (pins != nil) {
            self.pins = pins;
            NSLog(@"got pins");
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.pins) {
        NSLog(@"%lu", (unsigned long)[self.pins count]);
        return [self.pins count];
    }
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListPinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPinCell"];
    Pin *pin = self.pins[indexPath.row];
    if (self.pins) {
        cell.pinTitleLabel.text = pin.title;
        cell.pin = pin;
    }
    return cell;
}

@end
