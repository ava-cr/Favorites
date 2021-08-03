//
//  ListPinsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/19/21.
//

#import "ListPinsViewController.h"
#import "ListPinCell.h"
#import "Pin.h"
#import "PinDetailsViewController.h"
#import <pop/POP.h>

static NSString *segueToPinDetails = @"pinDetails";

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
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 60)];
    anim.springBounciness = 30;
    anim.springSpeed = 0.7;
    [self.view pop_addAnimation:anim forKey:@"size"];
}

-(void) getPins {
    PFQuery *query = [PFQuery queryWithClassName:@"Pin"];
    NSArray *keys = @[@"author", @"title", @"notes", @"url", @"latitude", @"longitude"];
    [query includeKeys:keys];
    [query whereKey:@"author" equalTo:self.user];
    query.limit = 20;
    typeof(self) __weak weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *pins, NSError *error) {
        typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            if (pins != nil) {
                strongSelf.pins = pins;
                NSLog(@"got pins");
                [strongSelf.tableView reloadData];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
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
    ListPinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListPinCell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor systemPinkColor];
    Pin *pin = self.pins[indexPath.row];
    if (self.pins) {
        cell.pinTitleLabel.text = pin.title;
        cell.pin = pin;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:segueToPinDetails sender:self.pins[indexPath.row]];
}

# pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:segueToPinDetails]) {
        Pin *chosenPin = sender;
        PinDetailsViewController *detailsVC = [segue destinationViewController];
        detailsVC.pin = chosenPin;
        detailsVC.user = self.user;
    }
}

@end
