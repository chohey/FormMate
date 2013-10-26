//
//  ISViewController.h
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/05.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICETutorialController.h"

@interface ISViewController : UIViewController{
    UIImageView *imageView;
}
@property (strong, nonatomic) IBOutlet UIImageView *backImageView;

@property (nonatomic, strong)ICETutorialController *tc;

- (IBAction)pushTutorial:(id)sender;

@end
