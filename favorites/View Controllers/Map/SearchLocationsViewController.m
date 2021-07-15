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
#import "AddPinViewController.h"

@interface SearchLocationsViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, MKLocalSearchCompleterDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property UISearchController *searchController;
@property (strong, nonatomic) MKLocalSearchCompleter *searchCompleter;
@property (nonatomic) MKCoordinateRegion searchRegion;
@property (nonatomic) MKCoordinateRegion boundingRegion;
@property (strong, nonatomic) CLPlacemark *currentPlacemark;
@property (strong, nonatomic) NSArray<MKLocalSearchCompletion *> *completerResults;
@property BOOL providingCompletions;

@property (strong, nonatomic) NSArray<MKMapItem *> *places;
@property (strong, nonatomic) MKMapItem *chosenPlace;
@property (strong, nonatomic) MKLocalSearch *localSearch;

@end

@implementation SearchLocationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.places = nil;
    [self.localSearch cancel];
        
    self.searchRegion = MKCoordinateRegionForMapRect(MKMapRectWorld);
    self.boundingRegion = MKCoordinateRegionForMapRect(MKMapRectWorld);

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
    
    if (!self.providingCompletions) [self startProvidingCompletions];
    NSLog(@"SEARCH BAR TEXT IS %@", self.searchController.searchBar.text);
    
    if (self.searchController.searchBar.text) {
        self.searchCompleter.queryFragment = self.searchController.searchBar.text;
        [self.tableView reloadData];
    }
    else  {
        NSLog(@"set search completer frag to empty string");
        self.searchCompleter.queryFragment = @"";
    }
    NSLog(@"in update search results: query frag: %@", self.searchCompleter.queryFragment);
}

- (void)completerDidUpdateResults:(MKLocalSearchCompleter *)completer {
    self.completerResults = completer.results;
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


// search functions
-(void) searchForSuggestedCompletion: (MKLocalSearchCompletion *) suggestedCompletion {
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] initWithCompletion:suggestedCompletion];
    [self searchUsing:searchRequest];
}

-(void) searchForQueryString: (NSString *) queryString {
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = queryString;
    [self searchUsing:searchRequest];
}

-(void) searchUsing: (MKLocalSearchRequest *)searchRequest {
    
    searchRequest.region = self.boundingRegion;
    searchRequest.resultTypes = MKLocalSearchResultTypePointOfInterest;
    
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            self.places = response.mapItems;
            self.chosenPlace = response.mapItems[0];
            
            NSLog(@"%@", self.chosenPlace);
            
            // Used when setting the map's region in `prepareForSegue`.
            MKCoordinateRegion updatedRegion = response.boundingRegion;
            self.boundingRegion = updatedRegion;
            
            [self performSegueWithIdentifier:@"locationChosen" sender:nil];
        }
        else {
            NSLog(@"Error with searchUsing = %@", [error.userInfo description]);
            
        }
        [self.localSearch cancel];
    }];
    
}

// search bar functions
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:TRUE animated:TRUE];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"ends editing");
    [searchBar setShowsCancelButton:FALSE animated:TRUE];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchController.active = FALSE;
}

// when you select a suggestion
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.completerResults) {
        [self stopProvidingCompletions];
        MKLocalSearchCompletion *suggestion = [[MKLocalSearchCompletion alloc] init];
        
        suggestion = self.completerResults[indexPath.row];
        
        NSLog(@"selected row with suggestion = %@", suggestion.title);
        
        self.searchController.active = FALSE;
        self.searchController.searchBar.text = suggestion.title;
        [self searchForSuggestedCompletion:suggestion];
    }
    else {
        NSLog(@"no completer results");
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *header = NSLocalizedString(@"Search Results", @"Standard result text");
    NSString *city = self.currentPlacemark.locality;
    if (city) {
        NSString *templateString = NSLocalizedString(@"Search Results near %@", city);
        header = [city initWithFormat:@"%@", templateString];
    }
    
    return header;
    
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqual:@"locationChosen"]) {
        NSLog(@"location chosen");        
        AddPinViewController *addPinVC = [segue destinationViewController];
        NSLog(@"segue-ing with chosen place = %@", self.chosenPlace.name);
        addPinVC.pin = self.chosenPlace;
    }
}

@end
