//
//  SearchManager.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "SearchManager.h"
#import "MainHandler.h"
#import <sqlite3.h>
#import "Peer.h"
#import "SearchRunner.h"
#import "FirstViewController.h"

@implementation SearchManager {
    NSArray* PeerList;
    NSMutableArray* results;
}

- (void) performSearch:(NSString *)searchParams viewController:(FirstViewController*)viewController {
    [self clearResults];
    PeerList = [MainHandler getPeerList];
    NSOperationQueue* searchQueue = [MainHandler getThreadPool];
    for (Peer* p in PeerList) {
        NSLog(@"Searching in peer: %@", [p getIp]);
        SearchRunner* runner = [[SearchRunner alloc]initWithPeer:p searchParams:searchParams];
        //[searchQueue addOperation:runner];
        [runner main];
    }
    [searchQueue waitUntilAllOperationsAreFinished];
    NSLog(@"Setting %d results", results.count);
    [viewController setResults:results];
}


- (void) addResult:(SearchResult*)result {
    @synchronized (results) {
        [results addObject:result];
    }
}

- (void) clearResults {
    @synchronized (results) {
        [results removeAllObjects];
    }
}

- (NSArray*) getResults {
    @synchronized (results) {
        return results;
    }
}

- (id)init {
    self = [super init];
    results = [[NSMutableArray alloc] init];
    return self;
}

@end
