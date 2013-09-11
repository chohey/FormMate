//
//  ISEditMovieViewController.h
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/11.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ISAVPlayerView.h"
#import "ISAVPlayerSecondView.h"

@interface ISEditMovieViewController : UIViewController

@property (strong,nonatomic) NSURL *url;
@property (strong,nonatomic) NSURL *urlSecond;

@property (strong, nonatomic) IBOutlet ISAVPlayerView *videoPlayerView;
@property (strong, nonatomic) IBOutlet ISAVPlayerSecondView *videoPlayerSecondView;

@property (strong, nonatomic) AVPlayerItem* playerItem;
@property (strong, nonatomic) AVPlayerItem* playerSecondItem;

@property (strong, nonatomic) AVPlayer*     videoPlayer;
@property (strong, nonatomic) AVPlayer*     videoSecondPlayer;
@property (nonatomic, assign) id    playTimeObserver; //! 再生位置の更新タイマー通知ハンドラ
@property (nonatomic, assign) id    playTimeObserver_2;
@property (strong, nonatomic) IBOutlet UISlider *movieSlider_1;
@property (strong, nonatomic) IBOutlet UISlider *movieSlider_2;

- (IBAction)changeSlider_1:(id)sender;
- (IBAction)changeSlider_2:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel_1;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel_2;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel_1;
@property (strong, nonatomic) IBOutlet UILabel *currentTimeLabel_2;
@end
