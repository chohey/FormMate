//
//  GapDictionary.h
//  newGummer
//
//  Created by techcamp on 2013/09/12.
//  Copyright (c) 2013年 IPLAB-Kanno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GapDictionary : NSObject
@property (strong, nonatomic) NSMutableDictionary *dictionary;
+ (id)sharedGapDictionary;
@end
