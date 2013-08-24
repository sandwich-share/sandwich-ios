//
//  Search.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/8/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Search.h"
#import "ViewController.h"

@implementation Search{
    BOOL finished;
}

- (void) main {
    NSLog(@"Search->main");
    
    for (Peer* peer in self.peerlist) {
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
    //[self setFinished];
}

-(void) performSearch:(sqlite3 *)indexDB peer:(Peer*)peer {
    // search this bitch
    NSLog(@"Performing Search");

    sqlite3_stmt* searchStatement;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM [%@] WHERE filepath LIKE ?1", peer.ip];
    const char *query_stmt = [querySQL UTF8String];
    int errorCode;
    if ((errorCode = sqlite3_prepare_v2(indexDB, query_stmt, -1, &searchStatement, NULL)) == SQLITE_OK)
    {
        if ((errorCode = sqlite3_bind_text(searchStatement, 1, [self.searchParam UTF8String], -1, SQLITE_STATIC)) == SQLITE_OK) {
            while (sqlite3_step(searchStatement) == SQLITE_ROW)
            {
                                
                NSLog(@"Trying to add: %s", sqlite3_column_text(searchStatement, 0));
            }
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

- (Search*) initWithSearchParam:(NSString*)searchParam peerlist:(NSMutableSet*)peerlist {
    self.searchParam = searchParam;
    self.peerlist = peerlist;
    return [super init];
}

@end
