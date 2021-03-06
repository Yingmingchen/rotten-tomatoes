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
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *criticsIconView;
@property (weak, nonatomic) IBOutlet UILabel *criticsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audienceIconView;
@property (weak, nonatomic) IBOutlet UILabel *audienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *runtimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *theaterReleaseDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *dvdReleaseDateLabel;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *url = [self.movie valueForKeyPath:@"posters.thumbnail"];
    NSString* originalUrl = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    [self.posterView setImageWithURL:[NSURL URLWithString:url]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:originalUrl]];
    [self.posterView setImageWithURLRequest:request
              placeholderImage:nil
               success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                   self.posterView.alpha = 0.0;
                   self.posterView.image = image;
                   [UIView animateWithDuration:0.5
                                    animations:^{
                                        self.posterView.alpha = 1.0;
                                    }];
               }
               failure:NULL
     ];
    
    self.title = [self.movie valueForKeyPath:@"title"];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ (%@)", [self.movie valueForKeyPath:@"title"], [self.movie valueForKeyPath:@"year"]];

    NSString *criticsScoreString = [self.movie valueForKeyPath:@"ratings.critics_score"];
    NSString *audienceScoreString = [self.movie valueForKeyPath:@"ratings.audience_score"];
    NSInteger criticsScore = [criticsScoreString integerValue];
    NSInteger audienceScore = [audienceScoreString integerValue];
    
    if (criticsScore > 50) {
        [self.criticsIconView setImage:[UIImage imageNamed:@"fresh"]];
    } else {
        [self.criticsIconView setImage:[UIImage imageNamed:@"rotten"]];
    }
    
    if (audienceScore > 50) {
        [self.audienceIconView setImage:[UIImage imageNamed:@"popcorn"]];
    } else {
        [self.audienceIconView setImage:[UIImage imageNamed:@"popcorn2"]];
    }
    
    self.criticsLabel.text = [NSString stringWithFormat:@"%@%%", criticsScoreString];
    self.audienceLabel.text = [NSString stringWithFormat:@"%@%%", audienceScoreString];
    self.ratingLabel.text = [self.movie valueForKeyPath:@"mpaa_rating"];
    self.runtimeLabel.text = [NSString stringWithFormat:@"%@ minutes", [self.movie valueForKeyPath:@"runtime"]];
    self.theaterReleaseDateLabel.text = [self.movie valueForKeyPath:@"release_dates.theater"];
    self.dvdReleaseDateLabel.text = [self.movie valueForKeyPath:@"release_dates.dvd"];
    
    self.synopsisLabel.text = [self.movie valueForKeyPath:@"synopsis"];
    [self.synopsisLabel sizeToFit];
    CGSize size = self.synopsisLabel.frame.size;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, size.height + 140);
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    CGRect newFrame = self.scrollView.frame;
    BOOL goingUp = YES;
    
    NSInteger newY = 0;
    if (velocity.y > 0) {
        goingUp = NO;
    }

    // When gesture is done, apply annimation
    if (panGestureRecognizer.state == 3) {
        if (goingUp) {
            newY = 0;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        } else {
            newY = 415;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
        newFrame.origin.y = newY;
        
        [UIView animateWithDuration:1.5
                              delay:0
             usingSpringWithDamping:0.5
              initialSpringVelocity:1.0
                            options:0
                         animations:^{
                             self.scrollView.frame = newFrame;
                             
                         }
                         completion:^(BOOL finished){
                         }
         ];
    }
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
