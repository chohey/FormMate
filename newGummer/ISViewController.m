//
//  ISViewController.m
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/05.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISViewController.h"
#import "SSGentleAlertView.h"
#import <QuartzCore/QuartzCore.h>

@interface ISViewController ()
@property (nonatomic,strong) NSMutableString *caseString;
@property int currentCameraX, currentCameraY, currentDataX, currentDataY, reverse;
@property (nonatomic, strong) UILabel *naviTitleLabel;
@property (strong, nonatomic) NSTimer *shakeTimer;
@property BOOL canMove;
@end

@implementation ISViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self longPressSetup];
    [self uiSetup];
}
- (void)longPressSetup{
    // ボタンの長押し検出設定
    UILongPressGestureRecognizer *gestureRecognizerData = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedHandler:)];
    [self.dataBtn addGestureRecognizer:gestureRecognizerData];
    UILongPressGestureRecognizer *gestureRecognizerCamera = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedHandler:)];
    [self.cameraBtn addGestureRecognizer:gestureRecognizerCamera];
}
- (void)uiSetup{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([ud objectForKey:@"backImage"]) {
        [self.backImageView setImage:[[UIImage alloc] initWithData:[ud objectForKey:@"backImage"]]];
    }else{
        [self.backImageView setImage:[UIImage imageNamed:@"backImage.png"]];
    }
    if ([ud objectForKey:@"buttonImage"]) {
        [self.cameraBtn setBackgroundImage:[[UIImage alloc] initWithData:[ud objectForKey:@"buttonImage"]] forState:UIControlStateNormal];
        [self.dataBtn setBackgroundImage:[[UIImage alloc] initWithData:[ud objectForKey:@"buttonImage"]] forState:UIControlStateNormal];
    }else{
        [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"baseball.png"] forState:UIControlStateNormal];
        [self.dataBtn setBackgroundImage:[UIImage imageNamed:@"baseball.png"] forState:UIControlStateNormal];
    }
    if ([ud objectForKey:@"btnPoint"]) {
        NSDictionary *dict = [ud objectForKey:@"btnPoint"];
        self.cameraBtn.center = CGPointMake([[dict objectForKey:@"cameraX"] integerValue], [[dict objectForKey:@"cameraY"] integerValue]);
        self.dataBtn.center = CGPointMake([[dict objectForKey:@"dataX"] integerValue], [[dict objectForKey:@"dataY"] integerValue]);
    }else{
        self.cameraBtn.center = CGPointMake(103,97);
        self.dataBtn.center = CGPointMake(103,208);
    }
    UIColor *color = [UIColor blackColor];
    UIColor *alphaColor = [color colorWithAlphaComponent:0.0];
    self.hideBtnView.backgroundColor = alphaColor;
    self.currentCameraX = self.cameraBtn.frame.origin.x+self.cameraBtn.frame.size.width/2;
    self.currentCameraY = self.cameraBtn.frame.origin.y+self.cameraBtn.frame.size.height/2;
    self.currentDataX = self.dataBtn.frame.origin.x+self.dataBtn.frame.size.width/2;
    self.currentDataY = self.dataBtn.frame.origin.y+self.dataBtn.frame.size.height/2;
    self.canMove = NO;
}
- (void)viewWillAppear:(BOOL)animated
{
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_top.png"] forBarMetrics:UIBarMetricsDefault];
    }
    self.naviTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.naviTitleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.naviTitleLabel.textColor = [UIColor colorWithRed:0.8f green:0.2f blue:0.2f alpha:1.0]; // 好きな文字色にする
    self.naviTitleLabel.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = self.naviTitleLabel;
    self.naviTitleLabel.text = @"　　　　　　　　"; //好きな文字を入れる
    [self.naviTitleLabel sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushCustomBtn:(id)sender {
    
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleDefault title:@"レイアウトの変更" message:nil delegate:self cancelButtonTitle:@"背景画像変更" otherButtonTitles:@"ボタン画像変更",@"ボタン位置変更",@"初期化",@"キャンセル",nil];
    [alert show];
}
-(void)alertView:(SSGentleAlertView*)alert clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:{
            // 背景画像変更
            self.caseString = [NSMutableString stringWithString:@"backImage"];
            [self imagePickerSetup];
            break;
        }
        case 1:{
            // ボタン画像変更
            self.caseString = [NSMutableString stringWithString:@"buttonImage"];
            [self imagePickerSetup];
            break;
        }
        case 2:{
            // ボタン位置変更
            [self setMoveBtn];
            break;
        }
        case 3:{
            // 初期化
            [self.backImageView setImage:[UIImage imageNamed:@"backImage.png"]];
            [self.cameraBtn setBackgroundImage:[UIImage imageNamed:@"baseball.png"] forState:UIControlStateNormal];
            [self.dataBtn setBackgroundImage:[UIImage imageNamed:@"baseball.png"] forState:UIControlStateNormal];
            self.cameraBtn.center = CGPointMake(103,97);
            self.dataBtn.center = CGPointMake(103,208);
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud removeObjectForKey:@"backImage"];
            [ud removeObjectForKey:@"buttonImage"];
            [ud removeObjectForKey:@"btnPoint"];
            [ud synchronize]; // 一応すぐに反映させる
            break;
        }
        case 4:
            // cancelButtonが押されたときのアクション
            break;
        default:
            break;
    }
}
- (void)imagePickerSetup{
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];  // 生成
    ipc.delegate = self;  // デリゲートを自分自身に設定
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;  // 画像の取得先をカメラに設定
    ipc.allowsEditing = YES;  // 画像取得後編集する
    [self presentViewController:ipc animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo
{
    // UIImagePNGRepresentation関数によりUIImageが保持する画像データをPNG形式で抽出
    NSData* pngData = [[NSData alloc] initWithData:UIImagePNGRepresentation( image )];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([self.caseString isEqualToString:@"backImage"]) {
        [self.backImageView setImage:image];
        [ud setObject:pngData forKey:@"backImage"];
    }else{
        [self.cameraBtn setBackgroundImage:image forState:UIControlStateNormal];
        [self.dataBtn setBackgroundImage:image forState:UIControlStateNormal];
        [ud setObject:pngData forKey:@"buttonImage"];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)longPressedHandler:(UILongPressGestureRecognizer *)gestureRecognizer{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan://長押しを検知開始
        {
            LOG(@"UIGestureRecognizerStateBegan");
            [self setMoveBtn];
        }
            break;
        default:
            break;
    }
}

-(void)setMoveBtn{
    if (!self.canMove) {
        [self.view bringSubviewToFront:self.hideBtnView];
        self.naviTitleLabel.text = @"ボタン移動モード";
        self.shakeTimer = [NSTimer scheduledTimerWithTimeInterval:0.14f target:self selector:@selector(shake) userInfo:nil repeats:YES];
        self.reverse = 1;
        [self.shakeTimer fire];
        self.canMove = YES;
    }
}

-(void)shake{
    [UIView animateWithDuration:0.07f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         //TODO: 揺らす
                         self.cameraBtn.transform = CGAffineTransformMakeRotation(self.reverse * M_PI * 3 / 180.0);
                         self.dataBtn.transform = CGAffineTransformMakeRotation(self.reverse * M_PI * 3 / 180.0);
                         self.reverse *= -1;
                     } completion:^(BOOL finished) {
                         // アニメーションが終わった後実行する処理
                     }];
}

// 画面に指を一本以上タッチしたときに実行されるメソッド
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // タッチ点がボタン上でなければ移動モード解除 ポイントを記録する
    CGPoint p = [[touches anyObject] locationInView:self.view];
    if (![self checkInBtn:self.cameraBtn point:p] && ![self checkInBtn:self.dataBtn point:p]) {
        [self.view sendSubviewToBack:self.hideBtnView];
        self.naviTitleLabel.text = @"　　　　　　　　";
        NSDictionary *pointDict = [[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInt:self.currentCameraX], [NSNumber numberWithInt:self.currentCameraY], [NSNumber numberWithInt:self.currentDataX], [NSNumber numberWithInt:self.currentDataY]] forKeys:@[@"cameraX",@"cameraY",@"dataX",@"dataY"]];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:pointDict forKey:@"btnPoint"];
        LOG(@"ポイント保存！！:%@",pointDict);
        [self.shakeTimer invalidate];
        self.cameraBtn.transform = CGAffineTransformMakeRotation(0.0 / 180.0);
        self.dataBtn.transform = CGAffineTransformMakeRotation(0.0 / 180.0);
        self.canMove = NO;
    }
}
// 画面に触れている指が一本以上移動したときに実行されるメソッド
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.canMove) {
        // ボタン上であればボタンを移動させる
        CGPoint p = [[touches anyObject] locationInView:self.view];
        if ([self checkInBtn:self.cameraBtn point:p]) {
            self.currentCameraX = p.x;
            self.currentCameraY = p.y;
            self.cameraBtn.center = CGPointMake(self.currentCameraX, self.currentCameraY);
        }
        if ([self checkInBtn:self.dataBtn point:p]) {
            self.currentDataX = p.x;
            self.currentDataY = p.y;
            self.dataBtn.center = CGPointMake(self.currentDataX, self.currentDataY);
        }
    }
}
- (BOOL)checkInBtn:(UIButton *)btn point:(CGPoint)point
{
    CGPoint b = btn.frame.origin;
    return (((b.x < point.x) && ((b.x+btn.frame.size.width) > point.x)) && ((b.y < point.y) && ((b.y+btn.frame.size.height) > point.y)));
}


- (IBAction)pushTutorial:(id)sender {
    ICETutorialPage *layer1 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"Tuto_1.png"];//@"tutorial_background_00@2x.jpg"];
    ICETutorialPage *layer2 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"Tuto_2.png"];//@"tutorial_background_01@2x.jpg"];
    ICETutorialPage *layer3 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"Tuto_3.png"];//@"tutorial_background_02@2x.jpg"];
    ICETutorialPage *layer4 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"Tuto_4.png"];//@"tutorial_background_03@2x.jpg"];
    ICETutorialPage *layer5 = [[ICETutorialPage alloc] initWithSubTitle:@""
                                                            description:@""
                                                            pictureName:@"Tuto_5.png"];//@"tutorial_background_04@2x.jpg"];
    
    // Set the common style for SubTitles and Description (can be overrided on each page).
    ICETutorialLabelStyle *subStyle = [[ICETutorialLabelStyle alloc] init];
    [subStyle setFont:TUTORIAL_SUB_TITLE_FONT];
    [subStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [subStyle setLinesNumber:TUTORIAL_SUB_TITLE_LINES_NUMBER];
    [subStyle setOffset:TUTORIAL_SUB_TITLE_OFFSET];
    
    ICETutorialLabelStyle *descStyle = [[ICETutorialLabelStyle alloc] init];
    [descStyle setFont:TUTORIAL_DESC_FONT];
    [descStyle setTextColor:TUTORIAL_LABEL_TEXT_COLOR];
    [descStyle setLinesNumber:TUTORIAL_DESC_LINES_NUMBER];
    [descStyle setOffset:TUTORIAL_DESC_OFFSET];
    
    // Load into an array.
    NSArray *tutorialLayers = @[layer1,layer2,layer3,layer4,layer5];
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.tc = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPhone"
                                                          bundle:nil
                                                        andPages:tutorialLayers];
    } else {
        self.tc = [[ICETutorialController alloc] initWithNibName:@"ICETutorialController_iPad"
                                                          bundle:nil
                                                        andPages:tutorialLayers];
    }
    
    // Set the common styles, and start scrolling (auto scroll, and looping enabled by default)
    [self.tc setCommonPageSubTitleStyle:subStyle];
    [self.tc setCommonPageDescriptionStyle:descStyle];
    
    // Set button 1 action.
    __unsafe_unretained typeof(self) weakSelf_1 = self;
    [self.tc setButton1Block:^(UIButton *button){
        LOG(@"Button 1 pressed.");
        [weakSelf_1.tc dismissModalViewControllerAnimated:YES];
    }];
    
    // Set button 2 action, stop the scrolling.
    __unsafe_unretained typeof(self) weakSelf = self;
    [self.tc setButton2Block:^(UIButton *button){
        LOG(@"Button 2 pressed.");
        LOG(@"Auto-scrolling stopped.");
        
        [weakSelf.tc stopScrolling];
    }];
    
    // Run it.
    [self.tc startScrolling];
    
    [self presentModalViewController:self.tc animated:YES];
}
@end
