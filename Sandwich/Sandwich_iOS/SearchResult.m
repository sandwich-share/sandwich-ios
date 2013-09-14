//
//  SearchResult.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/7/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "SearchResult.h"

@implementation SearchResult {
    Peer* MyPeer;
    NSString* FilePath;
}

- (NSString*) getFilePath {
    return FilePath;
}

- (id)initWithPeer:(Peer *)peer filePath:(NSString *)filePath {
    self = [super init];
    MyPeer = peer;
    FilePath = filePath;
    return self;
}

@end
