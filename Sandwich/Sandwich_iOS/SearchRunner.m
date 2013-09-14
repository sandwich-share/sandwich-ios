//
//  SearchRunner.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/7/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "SearchRunner.h"
#import "SearchResult.h"
#import "MainHandler.h"
#import "DBManager.h"

@implementation SearchRunner {
    NSString* SearchParameters;
    Peer* MyPeer;
}

- (void) main {
    // search the database!
    NSLog(@"SearchRunner: Performing Search");
    DBManager* dbMan = [MainHandler getDBManager];
    NSArray* results = [dbMan searchInPeer:MyPeer searchParam:SearchParameters];
    NSLog(@"Adding %d results", results.count);
    
    SearchManager* sMan = [MainHandler getSearchManager];
    for (SearchResult* res in results) {
        [sMan addResult:res];
    }
}

- (id) initWithPeer:(Peer *)peer searchParams:(NSString *)searchParams {
    self = [super init];
    SearchParameters = searchParams;
    MyPeer = peer;
    return self;
}

@end
