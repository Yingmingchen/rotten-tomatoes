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

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (nonatomic, strong) UIRefreshControl *tableRefreshControl;
@property (nonatomic, strong) UIRefreshControl *collectionRefreshControl;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

@property (nonatomic, assign) BOOL searching;
@property (nonatomic, strong) NSString *boxOfficeUrlString;
@property (nonatomic, strong) NSString *dvdUrlString;
@property (nonatomic, weak) NSString *movieUrlString;
@property (nonatomic, assign) BOOL tableLayout;

- (void)loadData:(BOOL)refresh;
- (void)launchDetailView:(NSInteger)rowIndex;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Use current controller as the delegates for table view and tab bar
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tabBar.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    self.tableView.rowHeight = 100;

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CollectionViewCell"];
    
    self.collectionView.hidden = YES;
    
    [self.errorLabel setHidden:YES];
    self.title = @"Movies";
    
    self.searchBar.delegate = (id)self;
    self.searching = NO;
    
    // Add pull to refresh
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.tableRefreshControl atIndex:0];
    self.collectionRefreshControl = [[UIRefreshControl alloc] init];
    [self.collectionRefreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.collectionRefreshControl atIndex:0];
    self.refreshControl = self.tableRefreshControl;
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];

    // Init the urls
    NSString *apiKey = @"8jtempshxkbkmd6m8khxk3yy";
    self.boxOfficeUrlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=%@&limit=50&country=us", apiKey];
    self.dvdUrlString = [NSString stringWithFormat:@"http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/top_rentals.json?apikey=%@&limit=50&country=us", apiKey];
    
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    [self.tabBar setTintColor:[UIColor orangeColor]];
    [self loadData:NO];
}

#pragma mark - helpers

// Helper to load data
- (void)loadData:(BOOL)refresh {
    [SVProgressHUD show];
    
    NSURL *url = [NSURL URLWithString:self.boxOfficeUrlString];
    if (self.tabBar.selectedItem.tag == 1) {
        url = [NSURL URLWithString:self.dvdUrlString];
    }
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError != nil) {
            [self.errorLabel setHidden:NO];
        } else {
            [self.errorLabel setHidden:YES];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            self.movies = responseDictionary[@"movies"];
            NSLog(@"%ld", self.movies.count);
            [self.tableView reloadData];
            [self.collectionView reloadData];
        }
        [SVProgressHUD dismiss];
        if (refresh) {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)launchDetailView:(NSInteger)rowIndex {
    MovieDetailViewController *mdvc = [[MovieDetailViewController alloc] init];
    
    if (self.searching) {
        mdvc.movie = self.filteredMovies[rowIndex];
    } else {
        mdvc.movie = self.movies[rowIndex];
    }
    mdvc.movie = self.movies[rowIndex];
    
    [self.navigationController pushViewController:mdvc animated:YES];
    
}

#pragma mark - gesture control

-(void)handlePinchGesture:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    NSLog(@"pinch %f",  pinchGestureRecognizer.scale);
    if (pinchGestureRecognizer.scale > 1) {
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
        self.refreshControl = self.collectionRefreshControl;
    } else {
        self.collectionView.hidden = YES;
        self.tableView.hidden = NO;
        self.refreshControl = self.tableRefreshControl;
    }
}

#pragma mark - tab bar

// Listener to tab bar selection event
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [self loadData:NO];
}

#pragma mark - search bar control

// Search bar event listener
- (void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.searching = NO;
        [self.tableView reloadData];
        return;
    }
 
    self.searching = YES;
    self.filteredMovies = [[NSMutableArray alloc] init];
    
    for (NSDictionary* movie in self.movies)
    {
        NSRange nameRange = [movie[@"title"] rangeOfString:text options:NSCaseInsensitiveSearch];
        NSRange synopsisRange = [movie[@"synopsis"] rangeOfString:text options:NSCaseInsensitiveSearch];
        if(nameRange.location != NSNotFound || synopsisRange.location != NSNotFound)
        {
            [self.filteredMovies addObject:movie];
            [self.tableView reloadData];
            [self.collectionView reloadData];            
        }
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar sizeToFit];
    
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.searching = NO;
    [self.tableView reloadData];
    [self.collectionView reloadData];
    [searchBar sizeToFit];
}

- (void)onRefresh {
    [self loadData:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searching) {
        return self.filteredMovies.count;
    } else {
        return self.movies.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie;
    if (self.searching) {
        movie = self.filteredMovies[indexPath.row];
    } else {
        movie = self.movies[indexPath.row];
    }
    cell.titleLabel.text = movie[@"title"];
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    NSArray *casts = [movie valueForKey:@"abridged_cast"];
    NSString *castString = @"";
    for (NSInteger i = 0; i <casts.count && i < 2; i++) {
        if (i > 0) {
            castString = [castString stringByAppendingString:@", "];
        }
        castString = [castString stringByAppendingString:[casts[i] valueForKey:@"name"]];
    }
    cell.synopsisLabel.text = castString;//movie[@"synopsis"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:url]];

    NSString *criticsScoreString = [movie valueForKeyPath:@"ratings.critics_score"];
    NSString *audienceScoreString = [movie valueForKeyPath:@"ratings.audience_score"];
    
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
    
    cell.criticsLabel.text = [NSString stringWithFormat:@"%@%%", criticsScoreString];
    cell.audienceLabel.text = [NSString stringWithFormat:@"%@%%", audienceScoreString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self launchDetailView:indexPath.row];
}

#pragma mark - Collection methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.searching) {
        return self.filteredMovies.count;
    } else {
        return self.movies.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"CollectionViewCell";
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *movie;
    if (self.searching) {
        movie = self.filteredMovies[indexPath.row];
    } else {
        movie = self.movies[indexPath.row];
    }

    NSLog(@"collection row %ld", indexPath.row);
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    NSString* originalUrl = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    // NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:originalUrl]];
    
    [cell.moviePosterView setImageWithURL:[NSURL URLWithString:originalUrl]];
//    [cell.moviePosterView setImageWithURLRequest:request
//                           placeholderImage:nil
//                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                        cell.moviePosterView.alpha = 0.0;
//                                        cell.moviePosterView.image = image;
//                                        [UIView animateWithDuration:0.5
//                                                         animations:^{
//                                                             cell.moviePosterView.alpha = 1.0;
//                                                         }];
//                                        //[UIView commitAnimations];
//                                    }
//                                    failure:NULL];
    
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
