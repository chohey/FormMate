//
//  ISMovieCollectionViewController.h
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/09.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ISMovieCollectionCellView.h"

@interface ISMovieCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *photos;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *processingbutton;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
- (IBAction)processingButtonTouched:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *processingBtn;

@property UILabel *navititle;

+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end
