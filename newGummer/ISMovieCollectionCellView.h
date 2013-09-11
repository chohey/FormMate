//
//  ISMovieCollectionCellView.h
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/09.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISMovieCollectionCellView : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *cellBackgroundView;

@property (strong, nonatomic) IBOutlet UIImageView *movieImageView;
@property (strong, nonatomic) IBOutlet UILabel *movieNameLabel;
@property (strong, nonatomic) NSURL *url;
@end
