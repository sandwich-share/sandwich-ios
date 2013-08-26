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

@implementation SearchManager {
    NSArray* PeerList;
}

- (NSArray*)performSearch:(NSString *)searchParams {
    NSMutableArray* allResults = [[NSMutableArray alloc] init];
    PeerList = [MainHandler getPeerList];
    
    for (Peer* p in PeerList) {
        NSLog(@"Searching in peer: %@", [p getIp]);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        NSString* dbFileName = [NSString stringWithFormat:@"%@.db", [p getIp]];
        
        NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
        const char * dbPath = [dataPath UTF8String];
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:dataPath]) {
            sqlite3* indexDB;
            if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
                // search the database!
                
            }
            else {
                // Shits fucked up
                NSLog(@"Cannot reopen the database for searching: %s", dbPath);
            }
        }
    }
    
    
    return allResults;
}

@end
