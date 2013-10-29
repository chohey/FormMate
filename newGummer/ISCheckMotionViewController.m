//
//  ISCheckMotionViewController.m
//  newGummer
//
//  Created by 閑野 伊織 on 13/09/12.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISCheckMotionViewController.h"
#import "SSGentleAlertView.h"
#import <QuartzCore/QuartzCore.h>

//NSString* const kStatusOfCheckKey_1 = @"status_of_check_1";
//NSString* const kStatusOfCheckKey_2 = @"status_of_check_2";
static void* AVPlayerViewControllerStatusObservationContextCheckView = &AVPlayerViewControllerStatusObservationContextCheckView;

@interface ISCheckMotionViewController ()

@end

@implementation ISCheckMotionViewController

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
    
    [self setupLayout];
    
}

- (void)setupLayout
{
    UIColor *color = [UIColor blackColor];
    UIColor *alphaColor = [color colorWithAlphaComponent:0.0];
    self.videoPlayerView.backgroundColor = alphaColor;
    self.videoPlayerSecondView.backgroundColor = alphaColor;
    
    
    NSArray *arr = @[@"並べて再生", @"重ねて再生"];
    UISegmentedControl *seg = [[UISegmentedControl alloc] initWithItems:arr];
    [seg setBackgroundImage:[UIImage imageNamed:@"btn.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    seg.segmentedControlStyle = UISegmentedControlStyleBar;
    seg.selectedSegmentIndex = 0;
    [seg addTarget:self action:@selector(changeSeg:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = seg;
    
    
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                         context:AVPlayerViewControllerStatusObservationContextCheckView];
    
    // 終了通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerItem];
    
    LOG(@"videoPlayer:\n%@",self.videoPlayer);
    AVPlayerLayer* layer = ( AVPlayerLayer* )self.videoPlayerView.layer;
    layer.player       = self.videoPlayer;
    
//-----------------------------------
    [self.playerSecondItem addObserver:self
                            forKeyPath:@"status"
                               options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                               context:AVPlayerViewControllerStatusObservationContextCheckView];
    
    // 終了通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidPlayToEndTime_2:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.playerSecondItem];
    
    AVPlayerLayer* layerSecond = ( AVPlayerLayer* )self.videoPlayerSecondView.layer;
    layerSecond.player       = self.videoSecondPlayer;
}

- (void)viewWillAppear:(BOOL)animated
{
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    // 遷移前に保存した再生位置をセット たぶん向こうで再生すると変わってしまうと思うので
    
    self.isPlaying = NO;
    [self setupSeekBar];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if( context == AVPlayerViewControllerStatusObservationContextCheckView )
    {
        
    }
}
- (void)changeSeg:(UISegmentedControl*)seg{
    if (seg.selectedSegmentIndex == 0) {
        // 並べて再生
        [UIView animateWithDuration:1.2f
                              delay:0.3f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             // アニメーションをする処理
                             self.videoPlayerView.alpha = 1.0;
                             self.videoPlayerSecondView.alpha = 1.0;
                             
                             self.videoPlayerView.transform = CGAffineTransformMakeTranslation(0, 0);
                             self.videoPlayerSecondView.transform = CGAffineTransformMakeTranslation(0, 0);
                         } completion:^(BOOL finished) {
                             // アニメーションが終わった後実行する処理
                             
                         }];
        
    }else{
        // 重ねて再生
        [UIView animateWithDuration:1.2f
                              delay:0.3f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             // アニメーションをする処理
                             self.videoPlayerView.alpha = 0.5;
                             self.videoPlayerSecondView.alpha = 0.5;
                             self.videoPlayerView.transform = CGAffineTransformMakeTranslation(0, 83);
                             self.videoPlayerSecondView.transform = CGAffineTransformMakeTranslation(0, -83);
                         } completion:^(BOOL finished) {
                             // アニメーションが終わった後実行する処理
                             
                         }];
    }
}

#pragma mark - Private

/**
 * 再生・一時停止ボタンが押された時に発生
 *
 * @param sender イベント送信元。
 */
- (void)play:(id)sender
{
    if( self.isPlaying )
    {
        self.isPlaying = NO;
        [self.videoPlayer pause];
        [self.videoSecondPlayer pause];
    }
    else
    {
        self.isPlaying = YES;
        [self.videoPlayer play];
        [self.videoSecondPlayer play];
    }
    
    [self syncPlayButton];
    
}
/**
 * 再生・一時停止ボタンの状態を同期します。
 */
- (void)syncPlayButton
{
    if( self.isPlaying )
    {
        [self.playBtn setImage:[UIImage imageNamed:@"video_pause_48.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.playBtn setImage:[UIImage imageNamed:@"video_play_64.png"] forState:UIControlStateNormal];
    }
}

/**
 * 動画再生が完了した時に発生
 *
 * @param notification 通知情報。
 */
- (void)playerDidPlayToEndTime:(NSNotification *)notification
{
	[self.videoPlayer seekToTime:self.timer_1];
    [self.videoSecondPlayer pause];
    [self.videoSecondPlayer seekToTime:self.timer_2];
    LOG(@"ファースト停止");
    self.isPlaying = NO;
    [self syncPlayButton];
    
    // リピートする場合は再生を実行する
    //[self.videoPlayer play];
}
- (void)playerDidPlayToEndTime_2:(NSNotification *)notification
{
	[self.videoSecondPlayer seekToTime:self.timer_2];
    [self.videoPlayer pause];
    [self.videoPlayer seekToTime:self.timer_1];
    LOG(@"セカンド停止");
    self.isPlaying = NO;
    [self syncPlayButton];
    
    // リピートする場合は再生を実行する
    //[self.videoPlayer play];
}

/**
 * 再生時間の更新ハンドラを削除
 */
- (void)removePlayerTimeObserver
{
    if( self.playTimeObserver == nil ) { return; }
    
    [self.videoPlayer removeTimeObserver:self.playTimeObserver];
    self.playTimeObserver = nil;
}
- (void)removeSecondPlayerTimeObserver
{
    if( self.playTimeObserver_2 == nil ) { return; }
    
    [self.videoSecondPlayer removeTimeObserver:self.playTimeObserver_2];
    self.playTimeObserver_2 = nil;
}

/**
 * シークバーを初期化
 */
- (void)setupSeekBar
{
    double tmp;
    if (CMTimeGetSeconds(self.playerItem.currentTime) > CMTimeGetSeconds(self.playerSecondItem.currentTime)) {
        tmp = CMTimeGetSeconds(self.playerItem.currentTime);
    }else{
        tmp = CMTimeGetSeconds(self.playerSecondItem.currentTime);
    }
    
	self.movieSlider.minimumValue = 0;
	self.movieSlider.maximumValue = CMTimeGetSeconds( self.playerItem.duration ) - tmp;
	self.movieSlider.value        = 0;
    
	// 再生時間とシークバー位置を連動させるためのタイマー
	const double interval = ( 0.5f * self.movieSlider.maximumValue ) / self.movieSlider.bounds.size.width;
	const CMTime time     = CMTimeMakeWithSeconds( interval, NSEC_PER_SEC );
	self.playTimeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:time
                                                                           queue:NULL
                                                                      usingBlock:^( CMTime time ) { [self syncSeekBar]; }];
    
    self.durationLabel.text = [self timeToString:self.movieSlider.maximumValue];
}
- (NSString* )timeToString:(float)value
{
    const NSInteger time = value;
    return [NSString stringWithFormat:@"%d:%02d", ( int )( time / 60 ), ( int )( time % 60 )];
}
/**
 * 再生位置スライダーを同期
 */
- (void)syncSeekBar
{
	const double duration = CMTimeGetSeconds( [self.videoPlayer.currentItem duration] );
	const double time     = CMTimeGetSeconds([self.videoPlayer currentTime]);
	const float  value    = ( self.movieSlider.maximumValue - self.movieSlider.minimumValue ) * time / duration + self.movieSlider.minimumValue;
    
	[self.movieSlider setValue:value];
    self.currentTimeLabel.text = [self timeToString:self.movieSlider.value];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushPlayBtn:(id)sender {
    [self play:nil];
}

- (IBAction)pushSaveBtn:(id)sender {
    //表示メッセージを空けたAlertを作成
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithTitle:@"名前を入力"
                                                    message:@"\n"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    
    //Alertに乗せる入力テキストを作成 TODO:高さを自動調整
    self.text = [[UITextField alloc] initWithFrame:CGRectMake(40.0, 212.0, 235.0, 25.0)];
    self.text.backgroundColor=[UIColor whiteColor];
    [alert addSubview:self.text];

    //Alertを表示
    [alert show];
    alert.transform = CGAffineTransformMakeTranslation(0, -70);
//    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
    
    //Responderをセット
    [self.text becomeFirstResponder];
    self.text.delegate = self;
    
    [self screenshotOfView:self.view];
}

- (IBAction)nextFrame:(id)sender {
    LOG(@"CurrentTime_1: %f",CMTimeGetSeconds([self.videoPlayer currentTime]));
    LOG(@"CurrentTime_2: %f",CMTimeGetSeconds([self.videoSecondPlayer currentTime]));
    int time_1 = CMTimeGetSeconds([self.videoPlayer currentTime]);
    int time_2 = CMTimeGetSeconds([self.videoSecondPlayer currentTime]);
    [self.videoSecondPlayer seekToTime:CMTimeMake((int)((float)time_2+1.0)*600, 600)];
    [self.videoPlayer seekToTime:CMTimeMake((int)((float)time_1+1.0)*600, 600)];
}

- (IBAction)previousFrame:(id)sender {
    int time_1 = CMTimeGetSeconds([self.videoPlayer currentTime]);
    int time_2 = CMTimeGetSeconds([self.videoSecondPlayer currentTime]);
    [self.videoSecondPlayer seekToTime:CMTimeMake((int)((float)time_2-1.0)*600, 600)];
    [self.videoPlayer seekToTime:CMTimeMake((int)((float)time_1-1.0)*600, 600)];
}

//OKボタンが押されたときのメソッド
- (void)alertView:(SSGentleAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //OKボタンの処理（Cancelボタンの処理は標準でAlertを終了する処理が設定されている）
    if (buttonIndex == 1) {
        /*Okボタンの処理*/
        LOG(@"OK !!");
//        self.text.delegate = nil;
        NSTimer *backTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(backRoot) userInfo:nil repeats:NO];
        [backTimer fire];
//        [self setText:nil];
//        [self backRoot];
    }
}
- (void)backRoot
{
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithTitle:@"保存しました！！"
                                                    message:self.titleStr
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
//    self.text.delegate = nil;
//    [self.navigationController popToViewController: [self.navigationController.viewControllers objectAtIndex:1] animated:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.titleStr = [textField.text mutableCopy];
    [self.titleStr replaceCharactersInRange:range withString:string];
    LOG(@"入力：%@",self.titleStr);
    return YES;
}


- (UIImage *)screenshotOfView:(UIView *)view{
    CGSize imageSize = view.bounds.size;
    CGPoint anchorPoint = view.layer.anchorPoint;
    
    if ( NULL != UIGraphicsBeginImageContextWithOptions ) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    }else{
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, [view center].x, [view center].y);
    CGContextConcatCTM(context, [view transform]);
    CGFloat tx = -imageSize.width * anchorPoint.x - view.frame.origin.x;
    CGFloat ty = -imageSize.height * anchorPoint.y - view.frame.origin.y;
    CGContextTranslateCTM(context, tx, ty);
    
    [view.layer renderInContext:context];
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:UIGetScreenImage()], self, nil, NULL);
    return image;
}


@end
