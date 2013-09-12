//
//  GapDictionary.m
//  newGummer
//
//  Created by techcamp on 2013/09/12.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import "GapDictionary.h"

@implementation GapDictionary

static GapDictionary *dic = nil;
+ (id)sharedGapDictionary
{
    @synchronized(self) {
        if (dic==nil) {
            dic = [[GapDictionary alloc] init];
            dic.dictionary = [[NSMutableDictionary alloc] init];
        }
    }
    return dic;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (dic == nil) {
            dic = [super allocWithZone:zone];
            return dic;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone*)zone {
    return self;  // シングルトン状態を保持するため何もせず self を返す
}
    
@end
