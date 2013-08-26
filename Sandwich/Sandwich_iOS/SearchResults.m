//
//  SearchResults.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "SearchResults.h"

@implementation SearchResults {
    Peer* Peer;
    NSString* FilePath;
    NSMutableArray* results;
}

- (void)addResult:(Peer *)peer filePath:(NSString *)filePath {
    [results addObject:[[SearchResults alloc] initResult:peer filePath:filePath]];
}

- (id)initResult:(Peer *)peer filePath:(NSString *)filePath {
    self = [super init];
    self->Peer = peer;
    self->FilePath = filePath;
    results = [[NSMutableArray alloc] init];
    return self;
}


@end
