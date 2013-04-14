//
//  Search.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/8/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Search.h"
#import "Peerlist.h"
#import "PerformSearch.h"

@implementation Search{
    BOOL finished;
}

- (void) main {
    NSLog(@"Search->main");
    
    for (Peer* peer in peerlist) {
        NSLog(@"Searching in peer: %@", peer.ip);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        NSString* dbFileName = [NSString stringWithFormat:@"%@.db", peer.ip];
    
        NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
        const char * dbPath = [dataPath UTF8String];
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:dataPath]) {
            sqlite3* indexDB;
            if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
                // search the database!
                [_searchThreads addOperation:[[PerformSearch alloc]initWithPeer:indexDB peer:peer searchParameter:_searchParam tableview:_tableview]];
            }
            else {
                // Shits fucked up
                NSLog(@"Cannot reopen the database for searching: %s", dbPath);
            }
        }
    }
    [_searchThreads waitUntilAllOperationsAreFinished];
    //_tableview.results = [NSMutableArray arrayWithArray:[_tableview.results sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];

    [self setFinished];
}

- (BOOL) isFinished {
    return finished;
}

- (void) setFinished {
    finished = true;
    NSLog(@"Search Finished");
}

- (Search*) initWithSearchParam:(NSString*)searchParam tableViewController:(ViewController *)tableView {
    self.searchParam = searchParam;
    self.tableview = tableView;
    _searchThreads = [[NSOperationQueue alloc]init];
    [tableView clearResults];
    [self.tableview redraw];
    return [super init];
}

@end
