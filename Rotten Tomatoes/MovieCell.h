//
//  MovieCell.h
//  Rotten Tomatoes
//
//  Created by Yingming Chen on 2/3/15.
//  Copyright (c) 2015 Yingming Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MovieCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIImageView *criticsIconView;
@property (weak, nonatomic) IBOutlet UILabel *criticsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audienceIconView;
@property (weak, nonatomic) IBOutlet UILabel *audienceLabel;
@property (weak, nonatomic) IBOutlet UILabel *castLabel;

@end
