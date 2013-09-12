//
//  ISFullPlayViewController.m
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/09.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//
//  選択されたfile URLを受け取ってMPMoviePlayerにて再生するviewController

#import <AVFoundation/AVFoundation.h>
#import "ISFullPlayViewController.h"


@interface ISFullPlayViewController ()
@property (nonatomic, retain) MPMoviePlayerController* videoPlayer;
@property (nonatomic, retain) MPMoviePlayerController* videoPlayer_2;
@end

@implementation ISFullPlayViewController


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
    
    [self screenLayout:self.url];
}
- (void)viewWillAppear:(BOOL)animated
{
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_top.png"] forBarMetrics:UIBarMetricsDefault];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)urlParser
{
    
    NSLog(@"query:%@",[self.url query]);
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:@"/var/mobile/Media/Photos/DCIM/IMG_0011.MOV"];
//    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:@"file://localhost/private/var/mobile/Applications/7390562D-10B1-48A5-BB89-B1803B793CEC"];
    [self screenLayout:fileURL];
}


- (void)screenLayout:(NSURL *)url
{
    // file://localhost/private/var/mobile/Applications/25FC58E1-4946-46FA-BDF1-C264EA1EC6AC/tmp/output.mov
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    self.videoPlayer.controlStyle             = MPMovieControlStyleDefault;
    self.videoPlayer.scalingMode              = MPMovieScalingModeAspectFit;
    self.videoPlayer.shouldAutoplay           = YES;
    self.videoPlayer.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.videoPlayer.view.autoresizesSubviews = YES;
    self.videoPlayer.view.frame               = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.videoPlayer.view.alpha               = 0.8;
    
    [self.videoPlayer prepareToPlay];
    [self.view addSubview:self.videoPlayer.view];
    
//    self.videoPlayer_2 = [[MPMoviePlayerController alloc] initWithContentURL:[[NSURL alloc] initFileURLWithPath:@"assets-library://asset/asset.mov?id=78939A0A-B120-4977-BC7C-D9FCBB11CAE7&ext=mov"]];
//    self.videoPlayer_2.controlStyle             = MPMovieControlStyleDefault;
//    self.videoPlayer_2.scalingMode              = MPMovieScalingModeAspectFit;
//    self.videoPlayer_2.shouldAutoplay           = YES;
//    self.videoPlayer_2.view.autoresizingMask    = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.videoPlayer_2.view.autoresizesSubviews = YES;
//    self.videoPlayer_2.view.frame               = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
//    self.videoPlayer_2.view.alpha               = 0.5;
//    
//    [self.videoPlayer_2 prepareToPlay];
//    [self.view addSubview:self.videoPlayer_2.view];
    
}

- (void)finishPreload:(NSNotification *)aNotification {
    MPMoviePlayerController *player = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                                  object:player];
    [player play];
}
- (void)finishPlayback:(NSNotification *)aNotification {
    MPMoviePlayerController *player = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
    [player stop];
}








@end
