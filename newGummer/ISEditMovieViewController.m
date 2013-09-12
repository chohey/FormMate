//
//  ISEditMovieViewController.m
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/11.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISEditMovieViewController.h"

NSString* const kStatusKey = @"status";
static void* AVPlayerViewControllerStatusObservationContext = &AVPlayerViewControllerStatusObservationContext;

@interface ISEditMovieViewController ()

@end

@implementation ISEditMovieViewController

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
    self.view.backgroundColor = [UIColor blackColor];
    
    // デバッグ
    UIColor *color = [UIColor blackColor];
    UIColor *alphaColor = [color colorWithAlphaComponent:0.0];
    self.videoPlayerView.backgroundColor = alphaColor;
    self.videoPlayerSecondView.backgroundColor = alphaColor;
    
    
    NSArray *arr = @[@"並べて再生", @"重ねて再生"];
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:arr];
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(changeSeg:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    
    
    NSLog(@"===================\n%@",self.url);
    self.playerItem = [[AVPlayerItem alloc] initWithURL:self.url];
    [self.playerItem addObserver:self
                      forKeyPath:kStatusKey
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerViewControllerStatusObservationContext];
    
    // 終了通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    self.videoPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    
    AVPlayerLayer* layer = ( AVPlayerLayer* )self.videoPlayerView.layer;
    
    layer.player       = self.videoPlayer;
    
    
    //----------------------------- SecondPlayer
    NSLog(@"===================\n%@",self.url);
    self.playerSecondItem = [[AVPlayerItem alloc] initWithURL:self.urlSecond];
    [self.playerSecondItem addObserver:self
                            forKeyPath:kStatusKey
                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                               context:AVPlayerViewControllerStatusObservationContext];
    
    // 終了通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidPlayToEndTime_2:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerSecondItem];
    
    self.videoSecondPlayer = [[AVPlayer alloc] initWithPlayerItem:self.playerSecondItem];
    
    AVPlayerLayer* layerSecond = ( AVPlayerLayer* )self.videoPlayerSecondView.layer;
    
    layerSecond.player       = self.videoSecondPlayer;
    
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layerSecond.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)viewWillAppear:(BOOL)animated
{
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    [self setupSeekBar];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( context == AVPlayerViewControllerStatusObservationContext )
    {
        
    }
}

#pragma mark - Private

/**
 * 再生・一時停止ボタンが押された時に発生します。
 *
 * @param sender イベント送信元。
 */
- (void)play:(id)sender
{
    
}

/**
 * 動画再生が完了した時に発生します。
 *
 * @param notification 通知情報。
 */
- (void)playerDidPlayToEndTime:(NSNotification *)notification
{
	[self.videoPlayer seekToTime:kCMTimeZero];
    NSLog(@"ファースト停止");
    
    // リピートする場合は再生を実行する
    //[self.videoPlayer play];
}
- (void)playerDidPlayToEndTime_2:(NSNotification *)notification
{
	[self.videoSecondPlayer seekToTime:kCMTimeZero];
    NSLog(@"セカンド停止");
    
    // リピートする場合は再生を実行する
    //[self.videoPlayer play];
}

/**
 * 再生時間の更新ハンドラを削除します。
 */
- (void)removePlayerTimeObserver
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma touch

- (void)selSwipeDownGesture:(UISwipeGestureRecognizer *)sender {
    NSLog(@"Notice Down Gesture");
}

- (void)changeSeg:(UISegmentedControl*)seg{
    if (seg.selectedSegmentIndex == 0) {
        // 並べて再生
        CGRect frame = CGRectMake(90, 25-44, 180, (int)(180*1.4));
        self.videoPlayerView.frame = frame;
        frame = CGRectMake(90, 225-44, 180, (int)(180*1.4));
        self.videoPlayerSecondView.frame = frame;
        // viewを回転
        self.videoPlayerView.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);  // 90度回転
        self.videoPlayerSecondView.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
        
        self.videoPlayerView.alpha = 1.0;
        self.videoPlayerSecondView.alpha = 1.0;
        
        [self.videoPlayer play];
        [self.videoSecondPlayer play];
        
    }else{
        // 重ねて再生
        CGRect frame = CGRectMake(40, 60-44, 240, 360);
        self.videoPlayerView.frame = frame;
        self.videoPlayerSecondView.frame = frame;
        // viewを回転
        self.videoPlayerView.transform = CGAffineTransformMakeRotation(M_PI * 360 / 180.0);  // 270度回転
        self.videoPlayerSecondView.transform = CGAffineTransformMakeRotation(M_PI * 360 / 180.0);
        
        self.videoPlayerView.alpha = 0.5;
        self.videoPlayerSecondView.alpha = 0.5;
        
        [self.videoPlayer play];
        [self.videoSecondPlayer play];
    }
}

- (void)viewDidUnload {
    [self setVideoPlayerView:nil];
    [self setVideoPlayerSecondView:nil];
    [self setMovieSlider_1:nil];
    [self setMovieSlider_2:nil];
    [self setDurationLabel_1:nil];
    [self setDurationLabel_2:nil];
    [self setCurrentTimeLabel_1:nil];
    [self setCurrentTimeLabel_2:nil];
    [super viewDidUnload];
}

/**
 * シークバーを初期化します。
 */
- (void)setupSeekBar
{
	self.movieSlider_1.minimumValue = 0;
	self.movieSlider_1.maximumValue = CMTimeGetSeconds( self.playerItem.duration );
	self.movieSlider_1.value        = 0;
	//[self.movieSlider_1 addTarget:self action:@selector(seekBarValueChanged:) forControlEvents:UIControlEventValueChanged];
    
	// 再生時間とシークバー位置を連動させるためのタイマー
	const double interval = ( 0.5f * self.movieSlider_1.maximumValue ) / self.movieSlider_1.bounds.size.width;
	const CMTime time     = CMTimeMakeWithSeconds( interval, NSEC_PER_SEC );
	self.playTimeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:time
                                                                           queue:NULL
                                                                      usingBlock:^( CMTime time ) { [self syncSeekBar]; }];
    
    self.durationLabel_1.text = [self timeToString:self.movieSlider_1.maximumValue];
    
//------------------------------
    self.movieSlider_2.minimumValue = 0;
	self.movieSlider_2.maximumValue = CMTimeGetSeconds( self.playerSecondItem.duration );
	self.movieSlider_2.value        = 0;
    
	// 再生時間とシークバー位置を連動させるためのタイマー
	const double interval_2 = ( 0.5f * self.movieSlider_2.maximumValue ) / self.movieSlider_2.bounds.size.width;
	const CMTime time_2     = CMTimeMakeWithSeconds( interval_2, NSEC_PER_SEC );
	self.playTimeObserver_2 = [self.videoSecondPlayer addPeriodicTimeObserverForInterval:time_2
                                                                           queue:NULL
                                                                      usingBlock:^( CMTime time_2 ) { [self syncSeekBar]; }];
    
    self.durationLabel_2.text = [self timeToString:self.movieSlider_2.maximumValue];
    
}
- (NSString* )timeToString:(float)value
{
    const NSInteger time = value;
    return [NSString stringWithFormat:@"%d:%02d", ( int )( time / 60 ), ( int )( time % 60 )];
}
/**
 * 再生位置スライダーを同期します。
 */
- (void)syncSeekBar
{
	const double duration = CMTimeGetSeconds( [self.videoPlayer.currentItem duration] );
	const double time     = CMTimeGetSeconds([self.videoPlayer currentTime]);
	const float  value    = ( self.movieSlider_1.maximumValue - self.movieSlider_1.minimumValue ) * time / duration + self.movieSlider_1.minimumValue;
    
	[self.movieSlider_1 setValue:value];
    self.currentTimeLabel_1.text = [self timeToString:self.movieSlider_1.value];
    
//----------------------------------
    const double duration_2 = CMTimeGetSeconds( [self.videoSecondPlayer.currentItem duration] );
	const double time_2     = CMTimeGetSeconds([self.videoSecondPlayer currentTime]);
	const float  value_2    = ( self.movieSlider_2.maximumValue - self.movieSlider_2.minimumValue ) * time_2 / duration_2 + self.movieSlider_2.minimumValue;
    
	[self.movieSlider_2 setValue:value_2];
    self.currentTimeLabel_2.text = [self timeToString:self.movieSlider_2.value];
}

- (IBAction)changeSlider_1:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self.videoPlayer seekToTime:CMTimeMakeWithSeconds( slider.value, NSEC_PER_SEC )];
}

- (IBAction)changeSlider_2:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [self.videoSecondPlayer seekToTime:CMTimeMakeWithSeconds( slider.value, NSEC_PER_SEC )];
}
@end
