//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by Yingming Chen on 2/3/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "CollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailViewController.h"
#import "SVProgressHUD.h"

// Constants
static NSString *const apiKey = @"8jtempshxkbkmd6m8khxk3yy";
static NSString *const boxOfficeUrlString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=8jtempshxkbkmd6m8khxk3yy&limit=50&country=us";
static NSString *const dvdUrlString = @"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=8jtempshxkbkmd6m8khxk3yy&limit=50&country=us";


@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

// Data structures to hold movie data
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;

@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIRefreshControl *collectionRefreshControl;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

@property (nonatomic, weak) NSString *movieUrlString;

@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL tableLayout;

// Helper functions
- (void)fetchMovieData:(BOOL)refresh;
- (NSDictionary *)getSingleMovie:(NSInteger)rowIndex;
- (void)launchDetailView:(NSInteger)rowIndex;
- (void)refreshView;
- (NSInteger)getMovieCount;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initial setup for table view
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tabBar.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    self.tableView.rowHeight = 100;

    // Initial setup for collection view
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    self.collectionView.hidden = YES;
    
    // Initial setup for search bar
    self.searchBar.delegate = (id)self;
    self.searching = NO;
    [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor lightTextColor]];

    // Tab bar setup
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    [self.tabBar setTintColor:[UIColor orangeColor]];
    
    [self.errorLabel setHidden:YES];
    self.title = @"Movies";

    // "pull to refresh" support
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    self.collectionRefreshControl = [[UIRefreshControl alloc] init];
    [self.collectionRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.collectionRefreshControl atIndex:0];
    self.refreshControl = self.tableRefreshControl;
    
    // Pinch gesture setup
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];

    // Load the data
    [self fetchMovieData:NO];

    self.filteredMovies = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helpers

// Helper to load data via API call
- (void)fetchMovieData:(BOOL)refresh {
    [SVProgressHUD show];
    
    // Choose the right URL to use based on the tab bar selection
    NSURL *url = [NSURL URLWithString:boxOfficeUrlString];
    // tag 0 for "Box Office"; tab 1 for "DVD"
    if (self.tabBar.selectedItem.tag == 1) {
        url = [NSURL URLWithString:dvdUrlString];
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError != nil) {
            [self.errorLabel setHidden:NO];
        } else {
            [self.errorLabel setHidden:YES];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];

            // Get the movie data from response
            self.movies = responseDictionary[@"movies"];
            // Refresh table view and collection view
            [self.tableView reloadData];
            [self.collectionView reloadData];
        }
        
        [SVProgressHUD dismiss];
        
        if (refresh) {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (NSDictionary *)getSingleMovie:(NSInteger)rowIndex {
    // Set the movie data for the detail view
    if (self.searching) {
        return self.filteredMovies[rowIndex];
    } else {
        return self.movies[rowIndex];
    }
}

// Helper to launch the movie detail view
- (void)launchDetailView:(NSInteger)rowIndex {
    MovieDetailViewController *mdvc = [[MovieDetailViewController alloc] init];
    
    // Set the movie data for the detail view
    mdvc.movie = [self getSingleMovie:rowIndex];
    
    [self.navigationController pushViewController:mdvc animated:YES];
}

- (void)refreshView {
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (NSInteger)getMovieCount {
    if (self.searching) {
        return self.filteredMovies.count;
    } else {
        return self.movies.count;
    }
}

#pragma mark - gesture control

-(void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    // Switch to collection view when user zoom in
    if (pinchGestureRecognizer.scale > 1) {
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
        self.refreshControl = self.collectionRefreshControl;
    } else {
        // Switch to table view when user zoom out
        self.collectionView.hidden = YES;
        self.tableView.hidden = NO;
        self.refreshControl = self.tableRefreshControl;
    }
}

#pragma mark - tab bar

// Listener to tab bar selection event
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    // Load proper data based on user selection
    [self fetchMovieData:NO];
}

#pragma mark - search bar control

// Search bar event listener
- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.searching = NO;
        [self refreshView];
        return;
    }
 
    self.searching = YES;
    
    [self.filteredMovies removeAllObjects];
    
    for (NSDictionary* movie in self.movies)
    {
        // Search title and synopsis
        NSRange nameRange = [movie[@"title"] rangeOfString:text options:NSCaseInsensitiveSearch];
        NSRange synopsisRange = [movie[@"synopsis"] rangeOfString:text options:NSCaseInsensitiveSearch];
        if(nameRange.location != NSNotFound || synopsisRange.location != NSNotFound)
        {
            [self.filteredMovies addObject:movie];
        }
    }

    [self refreshView];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar sizeToFit];
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

// Reset search bar state after cancel button clicked
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.searching = NO;
    [self refreshView];
    [searchBar sizeToFit];
}

#pragma mark - refresh handling

- (void)onRefresh {
    [self fetchMovieData:YES];
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getMovieCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = [self getSingleMovie:indexPath.row];
    
    cell.titleLabel.text = movie[@"title"];
    NSArray *casts = [movie valueForKey:@"abridged_cast"];
    NSString *castString = @"";
    // Get first two cast names
    for (NSInteger i = 0; i <casts.count && i < 2; i++) {
        if (i > 0) {
            castString = [castString stringByAppendingString:@", "];
        }
        castString = [castString stringByAppendingString:[casts[i] valueForKey:@"name"]];
    }
    cell.castLabel.text = castString;
    cell.synopsisLabel.text = [movie valueForKeyPath:@"synopsis"];
    
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:url]];

    NSString *criticsScoreString = [movie valueForKeyPath:@"ratings.critics_score"];
    NSString *audienceScoreString = [movie valueForKeyPath:@"ratings.audience_score"];
    cell.criticsLabel.text = [NSString stringWithFormat:@"%@%%", criticsScoreString];
    cell.audienceLabel.text = [NSString stringWithFormat:@"%@%%", audienceScoreString];
    
    NSInteger criticsScore = [criticsScoreString integerValue];
    NSInteger audienceScore = [audienceScoreString integerValue];
    if (criticsScore > 50) {
        [cell.criticsIconView setImage:[UIImage imageNamed:@"fresh"]];
    } else {
        [cell.criticsIconView setImage:[UIImage imageNamed:@"rotten"]];
    }
    if (audienceScore > 50) {
        [cell.audienceIconView setImage:[UIImage imageNamed:@"popcorn"]];
    } else {
        [cell.audienceIconView setImage:[UIImage imageNamed:@"popcorn2"]];
    }
    
    // Disable selection highlighting color
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self launchDetailView:indexPath.row];
}

#pragma mark - Collection methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self getMovieCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    
    NSDictionary *movie = [self getSingleMovie:indexPath.row];

    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    NSString* originalUrl = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    [cell.moviePosterView setImageWithURL:[NSURL URLWithString:originalUrl]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self launchDetailView:indexPath.row];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
