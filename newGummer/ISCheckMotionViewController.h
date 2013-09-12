//
//  ISCheckMotionViewController.h
//  newGummer
//
//  Created by 閑野 伊織 on 13/09/12.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ISMovieCollectionCellView.h"
#import "ISAVPlayerView.h"
#import "ISAVPlayerSecondView.h"

@interface ISCheckMotionViewController : UIViewController

@property (strong, nonatomic) IBOutlet ISAVPlayerView *videoPlayerView;
@property (strong, nonatomic) IBOutlet ISAVPlayerSecondView *videoPlayerSecondView;
@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) AVPlayerItem* playerSecondItem;
@property (nonatomic, assign) id    playTimeObserver; //! 再生位置の更新タイマー通知ハンドラ
@property (nonatomic, assign) id    playTimeObserver_2;

@property (strong, nonatomic) AVPlayer* videoPlayer;
@property (strong, nonatomic) AVPlayer* videoSecondPlayer;
@property (strong, nonatomic) IBOutlet UISlider *movieSlider;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *playBtn;
@property (nonatomic, assign) BOOL isPlaying;
- (IBAction)pushPlayBtn:(id)sender;

@property (strong, nonatomic) NSArray *playStartPointArr;

@end
