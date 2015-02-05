//
//  MovieDetailViewController.m
//  Rotten Tomatoes
//
//  Created by Yingming Chen on 2/3/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;


@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *url = [self.movie valueForKeyPath:@"posters.thumbnail"];
    NSString* originalUrl = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    [self.posterView setImageWithURL:[NSURL URLWithString:url]];
    [self.posterView setImageWithURL:[NSURL URLWithString:originalUrl]];
    self.title = [self.movie valueForKeyPath:@"title"];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", [self.movie valueForKeyPath:@"title"], [self.movie valueForKeyPath:@"year"]];
    self.scoreLabel.text = [NSString stringWithFormat:@"Critics score: %@%%, audience score: %@%%", [self.movie valueForKeyPath:@"ratings.critics_score"], [self.movie valueForKeyPath:@"ratings.audience_score"]];
    self.ratingLabel.text = [self.movie valueForKeyPath:@"mpaa_rating"];
    self.synopsisLabel.text = [self.movie valueForKeyPath:@"synopsis"];
    
    [self.synopsisLabel sizeToFit];
    CGSize size = self.synopsisLabel.frame.size;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, size.height + 150);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
