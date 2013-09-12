//
//  ISMovieCollectionViewController.m
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/09.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISMovieCollectionViewController.h"
#import "ISFullPlayViewController.h"
//#import "ISAVPlayerViewController.h"
#import "ISEditMovieViewController.h"


@interface ISMovieCollectionViewController (){
    NSArray *processingMovies;
    BOOL processingEnabled;
    NSMutableArray *selectedMovies;
}


@end


@implementation ISMovieCollectionViewController


@synthesize photos = _photos;

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.collectionView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_white.png"]]];
    
    //これは複数選択をするためのもの
    selectedMovies = [[NSMutableArray alloc] init];
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [selectedMovies removeAllObjects];
    [self refreshSelectedCell];
    // collect the photos
    NSMutableArray *collector = [[NSMutableArray alloc] initWithCapacity:0];
    ALAssetsLibrary *al = [ISMovieCollectionViewController defaultAssetsLibrary];
    
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                      usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                          [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                              if (asset) {
                                  // 動画のみ追加
                                  NSString* type = [asset valueForProperty:ALAssetPropertyType];
                                  if( [type isEqualToString:ALAssetTypeVideo] ){
                                      [collector addObject:asset];
                                  }
                              }
                          }];
                          
                          self.photos = collector;
                          [self.collectionView reloadData];
                          NSLog(@"photo count = %d",self.photos.count);
                          NSLog(@"photo = %@",self.photos);
                      }
                    failureBlock:^(NSError *error) { NSLog(@"ERROR!!!");}
     ];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
     //self.collectionView.allowsMultipleSelection = YES;
    NSString* identifier = @"movieCell";
    ISMovieCollectionCellView *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        NSLog(@"Not exist");
    }
    
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    if (asset) {
        NSLog(@"at index = %d", indexPath.row);
            
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *url = [representation url];
        cell.url = url;
        NSLog(@"url: %@", [url absoluteString]);
            
        [cell.movieImageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    } else {
        NSLog(@"not found");
        [cell.movieImageView setImage:nil];
    }
    
    cell.movieNameLabel.text = @"　";
    return cell;
}

//これも複数選択のためのメソッド
/*- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath");
    
    if (!processingEnabled) {
        // Determine the selected items by using the indexPath
        NSString *stringselectedMovies = [processingMovies[indexPath.section] objectAtIndex:indexPath.row];
        // Add the selected item into the array
        
        [selectedMovies addObject:stringselectedMovies];
     //   collectionView.cellBackgroundView.backgroundColor = [UIColor orangeColor];
    }
}*/


- (IBAction)processingButtonTouched:(id)sender{
    //画像のバックグラウンドをかえる
    if (processingEnabled) {
        [self refreshSelectedCell];
    }
    
    processingEnabled = !processingEnabled;
    self.collectionView.allowsMultipleSelection = processingEnabled;
    
    if (!processingEnabled) {
        
    }

}
- (void)refreshSelectedCell{
    int count = [[self.collectionView indexPathsForSelectedItems] count];
    for (int i=0; i<count; i++) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:i];
        
        ISMovieCollectionCellView *cell = (ISMovieCollectionCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        cell.selected = NO;
        cell.cellBackgroundView.backgroundColor = [UIColor whiteColor];
        
        NSLog(@"%d", i);
    }
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"didSelectItemAtIndexPath");
    
    ISMovieCollectionCellView *cell = (ISMovieCollectionCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!processingEnabled) {

        NSLog(@"cell: %@",cell.url);
    
        ISFullPlayViewController *ifpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FullPlayView"];
        ifpvc.url = cell.url;
        [self.navigationController pushViewController:ifpvc animated:YES];
    }
    else{
        
        NSLog(@"else");
        cell.selected = YES;
        cell.cellBackgroundView.backgroundColor = [UIColor orangeColor];
        [selectedMovies addObject:cell.url];
        if ([selectedMovies count] >= 2) {
//            ISMovieCollectionCellView *cell = (ISMovieCollectionCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
//            NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
//            ISMovieCollectionCellView *nextCell = (ISMovieCollectionCellView *)[self.collectionView cellForItemAtIndexPath:nextPath];
//            NSArray *urlArray = @[cell.url, nextCell.url];
            
        //    [self performSegueWithIdentifier:@"pushToAVPlayerView" sender:selectedMovies];
            [self performSegueWithIdentifier:@"pushToEditMovieView" sender:selectedMovies];
            
        }
    }
}



- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"diddeSelectItemAtIndexPath");
    
    ISMovieCollectionCellView *cell = (ISMovieCollectionCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!processingEnabled) {
        
        NSLog(@"decell: %@",cell.url);
        
        ISFullPlayViewController *ifpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FullPlayView"];
        ifpvc.url = cell.url;
        [self.navigationController pushViewController:ifpvc animated:YES];
    }
    else{
        
        NSLog(@"deelse");
        cell.selected = NO;
        cell.cellBackgroundView.backgroundColor = [UIColor whiteColor];
    }

    
    // TODO: Deselect item
}
/*
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}
*/
//#pragma mark

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if([segue.identifier isEqualToString:@"pushToFullPlayView"]) {
//        
//        ISFullPlayViewController *fv = (ISFullPlayViewController *)[segue destinationViewController];
//        fv.url = sender;
//        NSLog(@"################\nurl:%@",sender);
//    }
//    if([segue.identifier isEqualToString:@"pushToAVPlayerView"]) {
//        ISAVPlayerViewController *av = (ISAVPlayerViewController *)[segue destinationViewController];
//        NSURL *url = [sender objectAtIndex:0];
//        av.url = url;
//        url = [sender objectAtIndex:1];
//        av.urlSecond = url;
//    }
    if([segue.identifier isEqualToString:@"pushToEditMovieView"]) {
        ISEditMovieViewController *ev = (ISEditMovieViewController *)[segue destinationViewController];
        NSURL *url = [sender objectAtIndex:0];
        ev.url = url;
        url = [sender objectAtIndex:1];
        ev.urlSecond = url;
    }
}


- (void)viewDidUnload {
    [self setProcessingBtn:nil];
    [super viewDidUnload];
}
@end
