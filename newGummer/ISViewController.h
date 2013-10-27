//
//  ISViewController.h
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/05.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETutorialController.h"

@interface ISViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    UIImageView *imageView;
}
@property (strong, nonatomic) IBOutlet UIView *hideBtnView;
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;
@property (strong, nonatomic) IBOutlet UIButton *cameraBtn;
@property (strong, nonatomic) IBOutlet UIButton *dataBtn;

@property (nonatomic, strong)ICETutorialController *tc;
- (IBAction)pushCustomBtn:(id)sender;
- (IBAction)pushTutorial:(id)sender;

@end
