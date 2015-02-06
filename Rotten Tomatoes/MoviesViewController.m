//
//  MoviesViewController.m
//  Rotten Tomatoes
//
//  Created by Yingming Chen on 2/3/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailViewController.h"
#import "SVProgressHUD.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSMutableArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) BOOL searching;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.errorLabel setHidden:YES];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MovieCell" bundle:nil] forCellReuseIdentifier:@"MovieCell"];
    
    self.tableView.rowHeight = 100;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [SVProgressHUD show];
    
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=8jtempshxkbkmd6m8khxk3yy&limit=50&country=us"];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError != nil) {
            NSLog(@"error");
            [self.errorLabel setHidden:NO];
        } else {
            [self.errorLabel setHidden:YES];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            self.movies = responseDictionary[@"movies"];
            [self.tableView reloadData];
        }
        [SVProgressHUD dismiss];
    }];
    
    self.title = @"Movies";
    self.searchBar.delegate = (id)self;
    self.searching = NO;
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    NSLog(@"search %@", text);
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
        }
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar sizeToFit];
    
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [searchBar resignFirstResponder];
//    [searchBar sizeToFit];
//    return YES;
//}
//
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    self.searchBar.text = @"";
    self.searching = NO;
    [self.tableView reloadData];
    [searchBar sizeToFit];
}

- (void)onRefresh {
    NSURL *url = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=8jtempshxkbkmd6m8khxk3yy&limit=50&country=us"];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError != nil) {
            [self.errorLabel setHidden:NO];
            self.errorLabel.text = @"Failed to load";
        } else {
            [self.errorLabel setHidden:YES];
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            self.movies = responseDictionary[@"movies"];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
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
    cell.synopsisLabel.text = movie[@"synopsis"];
    NSString *url = [movie valueForKeyPath:@"posters.thumbnail"];
    [cell.posterView setImageWithURL:[NSURL URLWithString:url]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MovieDetailViewController *mdvc = [[MovieDetailViewController alloc] init];
    mdvc.movie = self.movies[indexPath.row];
    [self.navigationController pushViewController:mdvc animated:YES];
    
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
