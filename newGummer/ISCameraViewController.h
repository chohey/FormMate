//
//  ISCameraViewController.h
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/06.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import <AssetsLibrary/AssetsLibrary.h>
#define CAPTURE_FRAMES_PER_SECOND       20

@interface ISCameraViewController : UIViewController <AVCaptureFileOutputDelegate, AVCaptureFileOutputRecordingDelegate>{
    BOOL WeAreRecording;
    BOOL recFlag;
}
@property (strong, nonatomic) IBOutlet UIView *layoutView;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *takeMovieBtn;
@property (strong, nonatomic) IBOutlet UIButton *addBtn;
@property (strong, nonatomic) IBOutlet UILabel *recLabel;

@property (strong, nonatomic) IBOutlet UIView *saveMenuView;
- (IBAction)pushUndoBtn:(id)sender;
- (IBAction)pushSaveBtn:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *undoBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;

- (IBAction)pushCancelBtn:(id)sender;
- (IBAction)pushTakeMoviewBtn:(id)sender;
- (IBAction)pushAddBtn:(id)sender;
@end
