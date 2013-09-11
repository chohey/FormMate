//
//  ISAVPlayerSecondView.m
//  Gummer
//
//  Created by 閑野 伊織 on 13/09/09.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "ISAVPlayerSecondView.h"
#import <AVFoundation/AVFoundation.h>

@implementation ISAVPlayerSecondView


/**
 * レイヤーのクラス情報を取得します。
 *
 * @return レイヤー。
 */
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
