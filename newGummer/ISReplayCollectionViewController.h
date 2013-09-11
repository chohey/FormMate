//
//  ISReplayCollectionViewController.h
//  Gummer
//
//  Created by techcamp on 2013/09/10.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ISReplayCollectionViewCell.h"

@interface ISReplayCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>{
    NSArray *processingMovies;
    BOOL processingEnabled;
    NSMutableArray *selectedMovies;
    NSIndexPath *cellindex;
}




@property (nonatomic,strong) NSArray *photos;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelbutton;
- (IBAction)cancelButtonTouched:(id)sender;

+ (ALAssetsLibrary *)defaultAssetsLibrary;



@end
