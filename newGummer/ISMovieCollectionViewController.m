//
//  ISMovieCollectionViewController.m
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/09.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISMovieCollectionViewController.h"
#import "ISFullPlayViewController.h"
#import "ISEditMovieViewController.h"
#import "SVProgressHUD.h"
#import <ImageIO/ImageIO.h>


@interface ISMovieCollectionViewController (){
    NSArray *processingMovies;
    BOOL processingEnabled;
    NSMutableArray *selectedMovies;
    NSMutableArray *selectedMoviesIndex;
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
    selectedMoviesIndex = [[NSMutableArray alloc] init];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [SVProgressHUD showWithStatus:@"ロード中..."];
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    self.navititle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.navititle.font = [UIFont boldSystemFontOfSize:17.0];
    self.navititle.textColor = [UIColor colorWithRed:0.8f green:0.2f blue:0.2f alpha:1.0]; // 好きな文字色にする
    self.navititle.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.navititle;
    self.navititle.text = @"再生モード"; //好きな文字を入れる
    [self.navititle sizeToFit];

    
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

- (void)viewDidAppear:(BOOL)animated
{
    [SVProgressHUD dismiss];
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
    ISMovieCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if (!cell) {
        NSLog(@"Not exist");
    }
    
    ALAsset *asset = [self.photos objectAtIndex:indexPath.row];
    if (asset) {
        NSLog(@"at index = %d", indexPath.row);
            
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        NSURL *url = [representation url];
        cell.url = url;
            
        [cell.movieImageView setImage:[UIImage imageWithCGImage:[asset thumbnail]]];
    } else {
        NSLog(@"not found");
        [cell.movieImageView setImage:nil];
    }
    
    NSLog(@"selectedMovieIndex %@", selectedMoviesIndex);
    for (NSIndexPath *ip in selectedMoviesIndex) {
        if ([ip isEqual:indexPath]) {
            NSLog(@"selected indexpath");
            cell.cellBackgroundView.backgroundColor = [UIColor colorWithRed:0.8f green:0.2f blue:0.2f alpha:1.0];
            break;
        }
        else {
             NSLog(@"unselected indexpath");
            cell.cellBackgroundView.backgroundColor = [UIColor whiteColor];
        }
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
    //[self.processingbutton setTitle:@"編集中"];
//    UIColor *color = [UIColor blueColor];
 //   self.navigationItem.rightBarButtonItem.tintColor = color;

    //[self.processingbutton style:UIBarButtonItemStyleDone];
    
    //[self.processingbutton style:UIBarButtonItemStyleDone];
     self.processingbutton.style = UIBarButtonItemStyleDone;
     if (processingEnabled) {
        [self refreshSelectedCell];
   // self.processingbutton.style = UIBarButtonItemStyleDone;
     self.navititle.text = @"再生モード"; //好きな文字を入れる
    }
    
    processingEnabled = !processingEnabled;
    self.collectionView.allowsMultipleSelection = processingEnabled;
   // self.processingbutton.style = UIBarButtonItemStyleDone;
    if (processingEnabled) {
         self.navititle.text = @"編集モード"; //好きな文字を入れる
    }

}
- (void)refreshSelectedCell{
    int count = [[self.collectionView indexPathsForSelectedItems] count];
    for (int i=0; i<count; i++) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:i];
        
        ISMovieCollectionViewCell *cell = (ISMovieCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        cell.selected = NO;
        cell.cellBackgroundView.backgroundColor = [UIColor whiteColor];
        
        NSLog(@"%d", i);
    }
}

#pragma mark - UICollectionViewDelegate


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    NSLog(@"didSelectItemAtIndexPath");
    
    ISMovieCollectionViewCell *cell = (ISMovieCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (!processingEnabled) {

        NSLog(@"cell: %@",cell.url);
    
        ISFullPlayViewController *ifpvc = [self.storyboard instantiateViewControllerWithIdentifier:@"FullPlayView"];
        ifpvc.url = cell.url;
        [self.navigationController pushViewController:ifpvc animated:YES];
    }
    else{
        
        NSLog(@"else");
        cell.selected = YES;
        cell.cellBackgroundView.backgroundColor = [UIColor colorWithRed:0.8f green:0.2f blue:0.2f alpha:1.0];
       // [selectedMoviesIndex addObject:]
        [selectedMovies addObject:cell.url];
        [selectedMoviesIndex addObject:indexPath];
        NSLog(@"indexpathを書かせる%@",indexPath);
        if ([selectedMovies count] >= 2) {
//            ISMovieCollectionCellView *cell = (ISMovieCollectionCellView *)[self.collectionView cellForItemAtIndexPath:indexPath];
//            NSIndexPath *nextPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
//            ISMovieCollectionCellView *nextCell = (ISMovieCollectionCellView *)[self.collectionView cellForItemAtIndexPath:nextPath];
//            NSArray *urlArray = @[cell.url, nextCell.url];
            
        //    [self performSegueWithIdentifier:@"pushToAVPlayerView" sender:selectedMovies];
          selectedMoviesIndex = nil;
           // selectedMovies = nil;
            
            
            
            [self performSegueWithIdentifier:@"pushToEditMovieView" sender:selectedMovies];
            processingEnabled = !processingEnabled;
        }
    }

}



- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"diddeSelectItemAtIndexPath");
    
    ISMovieCollectionViewCell *cell = (ISMovieCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
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
