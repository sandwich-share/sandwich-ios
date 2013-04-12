//
//  Search.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/8/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Search.h"
#import "Peerlist.h"

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
                [self performSearch:indexDB peer:peer];
            }
            else {
                // Shits fucked up
                NSLog(@"Cannot reopen the database for searching: %s", dbPath);
            }
        }
    }
    [self setFinished];
}

-(void) performSearch:(sqlite3 *)indexDB peer:(Peer*)peer {
    // search this bitch
    NSLog(@"Performing Search");

    sqlite3_stmt* searchStatement;
    const char *query_stmt = [[NSString stringWithFormat: @"SELECT * FROM [%@] WHERE filepath LIKE ?1", peer.ip] UTF8String];
    const char *search = [[NSString stringWithFormat:@"%%%@%%",self.searchParam]UTF8String];
    
    int errorCode;
    if ((errorCode = sqlite3_prepare_v2(indexDB, query_stmt, -1, &searchStatement, NULL)) == SQLITE_OK)
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
    [self.tableview.results removeAllObjects];
    [self.tableview.peers removeAllObjects];
    [self.tableview redraw];
    return [super init];
}

@end
