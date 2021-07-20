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

@interface MyPinsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *pins;

@end

@implementation MyPinsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self getPins];
}

-(void) getPins {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:[PFUser currentUser]];
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
    
    MyPinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyPinCell"];
    Pin *pin = self.pins[indexPath.row];
    
    if (self.pins) {
        cell.titleLabel.text = pin.title;
        cell.pin = pin;
    }
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"locationChosen"]) {
        MyPinCell *tappedCell = sender;
        self.chosenPin = tappedCell.pin;
    }
}


@end
