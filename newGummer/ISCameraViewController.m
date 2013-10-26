//
//  ISCameraViewController.m
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/06.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISCameraViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ISCameraViewController ()
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *videoOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIView *previewView;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSURL *outputURL;
@property (strong, nonatomic) NSTimer *recBlink;
@property (strong, nonatomic) NSTimer *recTime;

@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer_2;


@end

@implementation ISCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WeAreRecording = NO;
    self.recLabel.text = @"　";
    self.recTimeLabel.text = @" ";
    // 撮影開始
    [self setupAVCapture];
    
    [self setLayout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.imageView =nil;
    
    [self setLayout];

}

- (void)setLayout
{
    // プレビュー用のビューを生成
    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                self.view.bounds.size.width,
                                                                self.view.bounds.size.height)];

    [self.view insertSubview:self.previewView belowSubview:self.layoutView];
    
    GapDictionary *dic = [GapDictionary sharedGapDictionary];
    if ([dic.dictionary objectForKey:@"thumbnail"]) {
        [self.imageView removeFromSuperview];
        UIImage *image = [dic.dictionary objectForKey:@"thumbnail"];
        self.imageView = [[UIImageView alloc] initWithImage:image];
        self.imageView.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
        self.imageView.autoresizingMask = 0;
    }
    
    [self.imageView setFrame:CGRectMake(0,
                                        0,
                                        self.view.bounds.size.width,
                                        self.view.bounds.size.height)];
    self.imageView.alpha = 0.5;
    [self.view addSubview:self.imageView];
    
    [self rotateComponent];
}

- (void)rotateComponent
{
    self.cancelBtn.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);  // 90度回転
    self.takeMovieBtn.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
    self.addBtn.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
    self.recLabel.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
    self.recTimeLabel.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
    
    self.undoBtn.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
    self.saveBtn.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);
}

- (void)setupAVCapture
{
    NSError *error = nil;
    
    // 入力と出力からキャプチャーセッションを作成
    self.session = [[AVCaptureSession alloc] init];
    
    // 正面に配置されているカメラを取得
    AVCaptureDevice *camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // カメラからの入力を作成し、セッションに追加
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:camera error:&error];
    [self.session addInput:self.videoInput];
    
    // 動画録画なのでAudioデバイスも取得する
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput)
    {
        // 同じように追加
        // 参考ではこんな感じになってたけど、厳密には上のVideoInputDeviceと同じようにやった方がいいと思う。
        [self.session addInput:audioInput];
    }
    
    // 画像への出力を作成し、セッションに追加
    self.videoOutput = [[AVCaptureMovieFileOutput alloc] init];
    CMTime maxDuration = CMTimeMake(6000, 600); //最大10秒の動画
    self.videoOutput.maxRecordedDuration = maxDuration;
    self.videoOutput.minFreeDiskSpaceLimit = 1024 * 1024; //空き容量が1MB以下では禁止
    
    [self.session addOutput:self.videoOutput];
    
    // キャプチャーセッションから入力のプレビュー表示を作成
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    captureVideoPreviewLayer.frame = self.view.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    // レイヤーをViewに設定
    CALayer *previewLayer = self.previewView.layer;
    previewLayer.masksToBounds = YES;
    [previewLayer addSublayer:captureVideoPreviewLayer];
    
    // セッション開始
    [self.session startRunning];
}

- (void)setRecBlinkTimer
{
    self.recBlink = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(recBlinker) userInfo:nil repeats:YES];
    self.recLabel.text = @"● REC";
    [self.recBlink fire];
}

- (void)recBlinker
{
    if (self.recLabel) {
        if (!recFlag) {
            self.recLabel.text = @"● REC";
        }else{
            self.recLabel.text = @"　";
        }
        recFlag = !recFlag;
    }
}
- (void)setRecTimer
{
    self.recTime = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(recTimer) userInfo:nil repeats:YES];
    [self.recTime fire];
    recCounter = 0;
}
- (void)recTimer
{
    if (self.recTimeLabel) {
        self.recTimeLabel.text = [NSString stringWithFormat:@"00:%02d",recCounter];
    }
    recCounter++;
}

#pragma mark
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue identfier: %@", segue.identifier);
    
    if([segue.identifier isEqualToString:@"modalToCollectionMovieView"]) {
        NSLog(@"%@", [[segue destinationViewController] class]);
    }
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [self.recTime invalidate];
    self.recTimeLabel.text = @" ";
    recCounter = 0;
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // 正常に録画されたか確認するために値を取得
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
        // 以下でチェック
        recordedSuccessfully ? NSLog(@"アプリ内保存成功"):NSLog(@"アプリ内保存失敗");
        self.outputURL = outputFileURL;
        [self play:self.outputURL];
    }
}


// カメラの向き http://qiita.com/Ushio@github/items/12e031bf0fb253618f7b
// サポートする画面の向き
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIDeviceOrientationPortrait);
//}



- (void)play:(NSURL *)outputFileURL
{
    NSLog(@"fileURL:%@",outputFileURL);
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:outputFileURL];
    self.videoPlayer.controlStyle             = MPMovieControlStyleDefault;
    self.videoPlayer.scalingMode              = MPMovieScalingModeAspectFit;
    self.videoPlayer.shouldAutoplay           = NO;
    self.videoPlayer.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoPlayer.view.autoresizesSubviews = YES;
    self.videoPlayer.view.frame               = CGRectMake(-70, 70, self.view.bounds.size.height, self.view.bounds.size.width);
    self.videoPlayer.view.alpha               = 1.0;
    
    [self.videoPlayer prepareToPlay];
    [self.view addSubview:self.videoPlayer.view];
    
    [self.view insertSubview:self.saveMenuView aboveSubview:self.videoPlayer.view];
    UIColor *color = [UIColor blackColor];
    UIColor *alphaColor = [color colorWithAlphaComponent:0.0];
    self.saveMenuView.backgroundColor = alphaColor;
    self.saveBtn.alpha = 0.5;
    self.undoBtn.alpha = 0.5;
    
    self.videoPlayer.view.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);  // 90度回転
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)removeView
{
    [self.previewView removeFromSuperview];
    [self.imageView removeFromSuperview];
    [self.layoutView removeFromSuperview];
    [self.session stopRunning];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setCancelBtn:nil];
    [self setTakeMovieBtn:nil];
    [self setAddBtn:nil];
    [self setRecLabel:nil];
    [self setRecTimeLabel:nil];
    [self setLayoutView:nil];
    [super viewDidUnload];
}
- (IBAction)pushUndoBtn:(id)sender {
    [self.videoPlayer.view removeFromSuperview];
    // NStimer の停止 本来は録画終了時にやるべきだけど終了がわからない
    [self.recBlink invalidate];
    self.recLabel.text = @"　";
    [self.view insertSubview:self.saveMenuView belowSubview:self.previewView];
    // 撮影開始
    [self setupAVCapture];
    WeAreRecording = NO;
}

- (IBAction)pushSaveBtn:(id)sender {
    //書き込んだのは/tmp以下なのでカメラーロールの下に書き出す
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:self.outputURL])
    {
        [library writeVideoAtPathToSavedPhotosAlbum:self.outputURL
                                    completionBlock:^(NSURL *assetURL, NSError *error)
         {
             if (error)
             {
                 NSLog(@"カメラロール保存失敗");
             }else{
                 NSLog(@"カメラロール保存成功");
                 [self removeView];
                 
             }
         }];
    }
}

- (IBAction)pushCancelBtn:(id)sender {
    [self removeView];
    self.imageView =nil;
    GapDictionary *dic = [GapDictionary sharedGapDictionary];
    
[dic.dictionary removeAllObjects];

}

- (IBAction)pushTakeMoviewBtn:(id)sender {
    NSLog(@"push");
    if (!WeAreRecording)
    {
        WeAreRecording = YES;
        
        AVCaptureConnection *videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
        if (videoConnection == nil) {
            return;
        }
        NSLog(@"videoConnection:%@",self.videoOutput.connections);
        for(AVCaptureConnection *connection in self.videoOutput.connections)
        {
            NSLog(@"connection:%@",connection);
            if(connection.supportsVideoOrientation)
            {
                // ホームボタンが右にくる横向きで固定
                connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            }
        }
        
        //保存する先のパスを作成
        NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:outputPath])
        {
            NSError *error;
            if ([fileManager removeItemAtPath:outputPath error:&error] == NO)
            {
                //上書きは基本できないので、あったら削除しないとダメ
            }
        }
        //録画開始
        NSLog(@"録画開始");
        [self.videoOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
        
        [self setRecBlinkTimer];
        [self setRecTimer];
        
    }else{
        NSLog(@"録画終了");
        [self.videoOutput stopRecording];
        
        [self.recLabel removeFromSuperview];
        [self.recTimeLabel removeFromSuperview];
        
    }
}

- (IBAction)pushAddBtn:(id)sender {
    //[self performSegueWithIdentifier:@"modalToCollectionMovieView" sender:self];
}

@end
