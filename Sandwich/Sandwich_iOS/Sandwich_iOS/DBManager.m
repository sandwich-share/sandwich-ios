//
//  DBManager.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "DBManager.h"


@implementation DBManager {
    sqlite3* indexDB;
    NSString* peerListTable;
}

- (NSArray*) getExistingPeers {
    NSMutableArray* peers = [NSMutableArray alloc];
    int errorCode;
	char* errorMsg;
    sqlite3_stmt* statement;
    //open the peerlist table
    NSString *sqlStmt = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@", peerListTable];
	const char* sqlStatement = [sqlStmt UTF8String];
    if ((errorCode = sqlite3_exec(indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
        NSLog(@"Cannot create/open table: %@", peerListTable);
    } else {
        NSLog(@"Successfully created/opend the table: %@", peerListTable);
        NSString *queryStmnt = [NSString stringWithFormat: @"SELECT * FROM %@", peerListTable];
        const char *query_stmt = [queryStmnt UTF8String];
        if ((errorCode = sqlite3_prepare_v2(indexDB, query_stmt, -1, &statement, NULL)) == SQLITE_OK)
        {
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString* ip = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                NSString* indexHash = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 1) encoding:NSUTF8StringEncoding];
                NSString* lastSeen = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
                
                Peer* peer = [[Peer alloc] initWithPeerInfo:ip indexhash:indexHash lastSeen:lastSeen];
                [peers addObject:peer];
                NSLog(@"Found peer: %@ in peerlist", ip);
            }
        }
    }
    return peers;
}


- (NSArray*) getPeersForBootstrap {
    ///// Create path to the database file /////
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString* dbFileName = @"peers.db";
    NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
    const char * dbPath = [dataPath UTF8String];
    NSArray* existingPeers;
    //Try to connect to the database
    if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
        existingPeers = [self getExistingPeers];
    }
    else {
        NSLog(@"Unable to create database");
    }
    if (existingPeers != NULL) {
        return existingPeers;
    }
    return NULL;
}


- (DBManager*) init {
    peerListTable = @"peerlist";
    return [super init];
}


@end
