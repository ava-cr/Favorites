//
//  SearchLocationsViewController.m
//  favorites
//
//  Created by Ava Crnkovic-Rubsamen on 7/12/21.
//

#import "SearchLocationsViewController.h"
#import "LocationCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SearchLocationsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, MKLocalSearchCompleterDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property UISearchController *searchController;
@property (strong, nonatomic) MKLocalSearchCompleter *searchCompleter;
@property (nonatomic) MKCoordinateRegion searchRegion;
@property (strong, nonatomic) CLPlacemark *currentPlacemark;
@property (strong, nonatomic) NSArray<MKLocalSearchCompletion *> *completerResults;
@property BOOL providingCompletions;

@end

@implementation SearchLocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchRegion = MKCoordinateRegionForMapRect(MKMapRectWorld);

    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    // Place the search bar in the navigation bar.
    self.navigationItem.searchController = self.searchController;
    // Keep the search bar visible at all times.
    self.navigationItem.hidesSearchBarWhenScrolling = false;
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;

    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search here...";
    [self.searchController.searchBar sizeToFit];

    self.searchController.delegate = self;
    
}

-(void) viewWillAppear {
    [super viewWillAppear:TRUE];
    NSLog(@"view will appear");
    [self startProvidingCompletions];
}

-(void) viewDidDisappear {
    [super viewDidDisappear:TRUE];
    [self stopProvidingCompletions];
}

-(void) startProvidingCompletions {
    NSLog(@"starting providing completions");
    self.providingCompletions = TRUE;
    self.searchCompleter = [[MKLocalSearchCompleter alloc] init];
    self.searchCompleter.delegate = self;
    self.searchCompleter.resultTypes = MKLocalSearchCompleterResultTypePointOfInterest;
    self.searchCompleter.region = self.searchRegion;
}

-(void) stopProvidingCompletions {
    self.providingCompletions = FALSE;
    self.searchCompleter = nil;
}

-(void) updatePlacemark: (CLPlacemark *)placemark withRegion: (MKCoordinateRegion *)boundingRegion {
    self.currentPlacemark = placemark;
    self.searchCompleter.region = self.searchRegion;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LocationCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"LocationCell"];
    
    if (self.completerResults) {
        MKLocalSearchCompletion *suggestion = self.completerResults[indexPath.row];
        
        cell.titleLabel.text = suggestion.title;
        cell.subtitleLabel.text = suggestion.subtitle;
    }
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.completerResults) {
        return [self.completerResults count];
    }
    else return 0;
}


- (void)updateSearchResultsForSearchController:(nonnull UISearchController *)searchController {
    // Ask `MKLocalSearchCompleter` for new completion suggestions based on the change in the text entered in `UISearchBar`.
    
    if (self.searchController.searchBar.text) {
        self.searchCompleter.queryFragment = self.searchController.searchBar.text;
        NSLog(@"%@", self.searchController.searchBar.text);
    }
    else self.searchCompleter.queryFragment = @"";
    if (!self.providingCompletions) [self startProvidingCompletions];
    //[self.tableView reloadData];
}

- (void)completerDidUpdateResults:(MKLocalSearchCompleter *)completer {
    self.completerResults = completer.results;
    NSLog(@"did update");
    [self.tableView reloadData];
}

- (void)completer:(MKLocalSearchCompleter *)completer didFailWithError:(NSError *)error {
    NSLog(@"MKLocalSearchCompleter encountered an error = %@", error.localizedDescription);
    NSLog(@"The query fragment is: %@", completer.queryFragment);
}



- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    return parentSize;
}


- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
    return true;
}

@end
