//
//  PerformSearch.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/12/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "PerformSearch.h"


@implementation PerformSearch {
    BOOL finished;
}

@synthesize peer;
@synthesize peerDB;
@synthesize tableview;
@synthesize searchParam;

- (void) main {
    NSLog(@"Performing Search");
    
    sqlite3_stmt* searchStatement;
    const char *query_stmt = [[NSString stringWithFormat: @"SELECT * FROM [%@] WHERE filepath LIKE ?1", peer.ip] UTF8String];
    const char *search = [[NSString stringWithFormat:@"%%%@%%",self.searchParam]UTF8String];
    
    int errorCode;
    if ((errorCode = sqlite3_prepare_v2(peerDB, query_stmt, -1, &searchStatement, NULL)) == SQLITE_OK)
    {
        if ((errorCode = sqlite3_bind_text(searchStatement, 1, search, -1, SQLITE_STATIC)) == SQLITE_OK) {
            unsigned int numResults = 0;
            while (sqlite3_step(searchStatement) == SQLITE_ROW) {
                numResults++;
                //NSLog(@"Trying to add: %s", sqlite3_column_text(searchStatement, 0));
                NSString* resultToAdd = [[NSString alloc] initWithUTF8String:(char*)sqlite3_column_text(searchStatement, 0)];
                
                [self.tableview addSearchResults:resultToAdd peer:peer];
                if ([self isCancelled]) {
                    NSLog(@"Search is cancelled");
                    break;
                }
            }
            
            NSLog(@"Number of results: %d", numResults);
            [self.tableview redraw];
        }
        else {
            NSLog(@"Failed to bind search parameter: %d", errorCode);
        }
    }
    else {
        NSLog(@"Failed to prepare statement: %d", errorCode);
    }
    [tableview.tableView setContentOffset:CGPointMake(0, 1) animated:YES];
    [self setFinished];
}

- (BOOL) isFinished {
    return finished;
}

- (void) setFinished {
    finished = true;
}

- (PerformSearch*) initWithPeer: (sqlite3*)indexDB peer:(Peer*)peer_ searchParameter:(NSString *)searchParameter tableview:(ViewController *)tableView {
    peer = peer_;
    peerDB = indexDB;
    searchParam = searchParameter;
    tableview = tableView;
    return [super init];
}

@end
