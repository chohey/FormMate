//
//  ISReplayCollectionViewCell.h
//  Gummer
//
//  Created by techcamp on 2013/09/11.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ISReplayCollectionViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>




@interface ISReplayCollectionViewCell : UICollectionViewCell



@property (strong, nonatomic) IBOutlet UIImageView *replayImageView;

@property (strong, nonatomic) IBOutlet UILabel *label;

@property (weak, nonatomic) IBOutlet UIView *cellBackgroundView;


@property (strong, nonatomic) NSURL *url;
@end
