//
//  DownloadController.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/12/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "DownloadController.h"

@implementation DownloadController


- (DownloadController*) initWithFilePath: (NSString*)filePath {
    _filePath = filePath;
    NSLog(@"Download filepath: %@", filePath);
    return [super init];
}

@end
