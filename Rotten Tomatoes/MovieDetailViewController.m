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

@property (assign) BOOL goingUp;

//- (IBAction)onPan:(id)sender;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSString *url = [self.movie valueForKeyPath:@"posters.thumbnail"];
    NSString* originalUrl = [url stringByReplacingOccurrencesOfString:@"_tmb" withString:@"_ori"];
    [self.posterView setImageWithURL:[NSURL URLWithString:url]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:originalUrl]];
    
    //[self.posterView setImageWithURL:[NSURL URLWithString:originalUrl]];
    
    
    [self.posterView setImageWithURLRequest:request
              placeholderImage:nil
                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                           self.posterView.alpha = 0.0;
                           self.posterView.image = image;
                           [UIView animateWithDuration:0.5
                                            animations:^{
                                                self.posterView.alpha = 1.0;
                                            }];
                           //[UIView commitAnimations];
                       }
                       failure:NULL];
    
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
    self.synopsisLabel.text = [self.movie valueForKeyPath:@"synopsis"];
    
    [self.synopsisLabel sizeToFit];
    CGSize size = self.synopsisLabel.frame.size;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, size.height + 150);
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveViewWithGestureRecognizer:)];
    //[self.view addGestureRecognizer:panGestureRecognizer];
    //[self.posterView addGestureRecognizer:panGestureRecognizer];
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
    self.goingUp = YES;
}

-(void)moveViewWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    CGRect newFrame = self.scrollView.frame;
    
    NSInteger newY = 0;
    if (velocity.y > 0) {
        self.goingUp = NO;
    } else {
        self.goingUp = YES;
    }

    if (panGestureRecognizer.state == 3) {
        if (self.goingUp) {
            newY = 50;
            [self.navigationController setNavigationBarHidden:YES animated:YES];
        } else {
            newY = 460;
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

//    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x + 0,
//                                         newY,
//                                         self.scrollView.frame.size.width + 0,
//                                         self.scrollView.frame.size.height + 0);
//    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)onPan:(id)sender {
//    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x + 0,
//                                         50,
//                                         self.scrollView.frame.size.width + 0,
//                                         self.scrollView.frame.size.height + 0);
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
