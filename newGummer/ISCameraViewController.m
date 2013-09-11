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
//@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) UIView *previewView;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer_2;

//@property (strong, nonatomic) UIButton *dismissBtn, *saveBtn;

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
    // 撮影開始
    [self setupAVCapture];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    [self testPlay];

    [self setLayout];

}

- (void)setLayout
{
    // 撮影ボタンを配置したツールバーを生成
//    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-44, self.view.bounds.size.width, 44)];
//    
//    UIBarButtonItem *takePhotoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
//                                                                                     target:self
//                                                                                     action:@selector(takePhoto:)];
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
//                                                                                  target:self
//                                                                                  action:@selector(cancel:)];
//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                                                                               target:self
//                                                                               action:@selector(addMovie:)];
//    
//    // スペーサを生成する
//    UIBarButtonItem *spacer = [[UIBarButtonItem alloc]
//                               initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                               target:nil action:nil];
//    
//    toolbar.items = @[cancelButton,spacer,takePhotoButton, spacer, addButton];
//    toolbar.translucent = YES;
//    [self.view addSubview:toolbar];
    
    // プレビュー用のビューを生成
    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                0,
                                                                self.view.bounds.size.width,
                                                                self.view.bounds.size.height)];

    [self.view insertSubview:self.previewView belowSubview:self.layoutView];
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ichiro.png"]];
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
}

- (void)setupAVCapture
{
    NSLog(@"キャプチャ");
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

- (void)takePhoto:(id)sender
{
    NSLog(@"push");
    if (!WeAreRecording)
    {
        WeAreRecording = YES;
        // ビデオ入力のAVCaptureConnectionを取得
//        AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
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
    
        // ビデオ入力から画像を非同期で取得。ブロックで定義されている処理が呼び出され、画像データを引数から取得する
//        [self.stillImageOutput
//         captureStillImageAsynchronouslyFromConnection:videoConnection
//         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
//             if (imageDataSampleBuffer == NULL) {
//                 return;
//             }
        
         // 入力された画像データからJPEGフォーマットとしてデータを取得
//         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         
         // JPEGデータからUIImageを作成
//         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         // アルバムに画像を保存
//         UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
        
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
        
        [self recBlinker];
        
    }else{
        WeAreRecording = NO;
        NSLog(@"録画終了");
        [self.videoOutput stopRecording];
        
        [self.recLabel removeFromSuperview];
        
    }
}
- (void)setRecBlinkTimer
{
    NSTimer *recBlink = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(recBlinker) userInfo:nil repeats:YES];
    [recBlink fire];
}

- (void)recBlinker
{
    if (self.recLabel) {
        if (recFlag) {
            self.recLabel.text = @"● REC";
        }else{
            self.recLabel.text = @"　";
        }
        recFlag = !recFlag;
    }
//    else{
//        self.recLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 60, 40)];
//        self.recLabel.text = @"● REC";
//        self.recLabel.backgroundColor = [UIColor clearColor];
//        self.recLabel.textColor = [UIColor redColor];
//        [self.view addSubview:self.recLabel];
//        
//        recFlag = YES;
//    
//        NSTimer *recBlink = [NSTimer scheduledTimerWithTimeInterval:0.8f target:self selector:@selector(recBlinker) userInfo:nil repeats:YES];
//        [recBlink fire];
//    }
}

//- (void)addMovie:(id)sender
//{
//    [self performSegueWithIdentifier:@"modalToCollectionMovieView" sender:self];
//}
#pragma mark
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"modalToCollectionMovieView"]) {
        
    }
}


- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // 正常に録画されたか確認するために値を取得
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
        // 以下でチェック
        recordedSuccessfully ? NSLog(@"アプリ内保存成功"):NSLog(@"アプリ内保存失敗");
        //書き込んだのは/tmp以下なのでカメラーロールの下に書き出す
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"カメラロール保存失敗");
                 }else{
                     NSLog(@"カメラロール保存成功");
//                     [self.previewView removeFromSuperview];
                     [self.imageView removeFromSuperview];
                     [self.recLabel removeFromSuperview];
                     
                     [self play:outputFileURL];
                     
                 }
             }];
        }
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
    
    // ボタン作成
//    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(270-150, 0, 50+150, self.view.bounds.size.height)];
//    UIColor *color = [UIColor blackColor];
//    UIColor *alphaColor = [color colorWithAlphaComponent:0.0];
//    buttonView.backgroundColor = [UIColor redColor];//alphaColor;
//    [self.view addSubview:buttonView];
//    UIButton *dismissBtn, *saveBtn;
//    dismissBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    dismissBtn.frame = CGRectMake(280, 50, 73, 44);
//    [dismissBtn setTitle:@"撮り直す" forState:UIControlStateNormal];
//    dismissBtn.titleLabel.textColor = [UIColor whiteColor];
//    
//    saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    saveBtn.frame = CGRectMake(80, 30, 73, 44);
//    saveBtn.titleLabel.text = @"保存";
//    saveBtn.titleLabel.textColor = [UIColor whiteColor];
//    
//    [buttonView addSubview:dismissBtn];
//    [buttonView addSubview:saveBtn];
//    NSLog(@"dismissButton%@",dismissBtn);
//    NSLog(@"saveButton:%@",saveBtn);
//    [self.view bringSubviewToFront:self.dismissBtn];    // frontView を最前面に移動
//    [self.view bringSubviewToFront:self.saveBtn];
    
    self.videoPlayer.view.transform = CGAffineTransformMakeRotation(M_PI * 90 / 180.0);  // 90度回転
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCancelBtn:nil];
    [self setTakeMovieBtn:nil];
    [self setAddBtn:nil];
    [self setRecLabel:nil];
    [self setLayoutView:nil];
    [super viewDidUnload];
}
- (IBAction)pushCancelBtn:(id)sender {
    [self.previewView removeFromSuperview];
    [self.imageView removeFromSuperview];
    [self.layoutView removeFromSuperview];
    [self.session stopRunning];
    [self dismissModalViewControllerAnimated:YES];
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
        
    }else{
        NSLog(@"録画終了");
        [self.videoOutput stopRecording];
        
        [self.recLabel removeFromSuperview];
        
    }
}

- (IBAction)pushAddBtn:(id)sender {
    [self performSegueWithIdentifier:@"modalToCollectionMovieView" sender:self];
}
@end
