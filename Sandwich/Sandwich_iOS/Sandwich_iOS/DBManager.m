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

- (NSMutableArray*) getExistingPeers {
    NSMutableArray* peers = NULL;
    int errorCode;
	char* errorMsg;
    sqlite3_stmt* statement;
    //open the peerlist table
    NSString *sqlStmt = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS '%@' (address TEXT PRIMARY KEY NOT NULL, hash INT, lastSeen TEXT)", peerListTable];
	const char* sqlStatement = [sqlStmt UTF8String];
    if ((errorCode = sqlite3_exec(indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
        NSLog(@"Cannot create/open table: %@\n%s", peerListTable,errorMsg);
    } else {
        NSLog(@"Successfully created/opened the table: %@", peerListTable);
        NSString *queryStmnt = [NSString stringWithFormat: @"SELECT * FROM %@", peerListTable];
        const char *query_stmt = [queryStmnt UTF8String];
        peers = [[NSMutableArray alloc] init];
        if ((errorCode = sqlite3_prepare_v2(indexDB, query_stmt, -1, &statement, NULL)) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString* ip = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 0) encoding:NSUTF8StringEncoding];
                NSNumber* indexHash = [NSNumber numberWithLong:sqlite3_column_int(statement, 1)];
                NSString* lastSeen = [NSString stringWithCString:(char*)sqlite3_column_text(statement, 2) encoding:NSUTF8StringEncoding];
                
                Peer* peer = [[Peer alloc] initWithPeerInfo:ip indexhash:indexHash lastSeen:lastSeen];
                [peers addObject:peer];
                NSLog(@"Found peer: %@ in peerlist", ip);
            }
        }
    }
    return peers;
}


- (NSMutableArray*) getPeersForBootstrap {
    ///// Create path to the database file /////
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString* dbFileName = @"peers.db";
    NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
    const char * dbPath = [dataPath UTF8String];
    NSMutableArray* existingPeers;
    //Try to connect to the database
    if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
        existingPeers = [self getExistingPeers];
    }
    else {
        NSLog(@"Unable to create database");
        existingPeers = NULL;
    }
    return existingPeers;
}


- (void) writeIndexToDatabase:(NSArray *)index peer:(Peer *)peer {
    int errorCode;
	char* errorMsg;
    ///// Create path to the database file /////
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString* dbFileName = [NSString stringWithFormat:@"%@.db", [peer getIp]];
    NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
    const char * dbPath = [dataPath UTF8String];
    //Try to connect to the database
    if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
        sqlite3_stmt* statement;
        NSString *sqlStmt = [NSString stringWithFormat:@"DROP TABLE IF EXISTS [%@]", [peer getIp]];
        const char* sqlStatement = [sqlStmt UTF8String];
        
        if ((errorCode = sqlite3_exec(indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot drop table: %@", [peer getIp]);
        }
        sqlStatement = [[NSString stringWithFormat:@"CREATE TABLE [%@] (filepath TEXT PRIMARY KEY NOT NULL)", [peer getIp]] UTF8String];
        if ((errorCode = sqlite3_exec(indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot create table: %@ Error Code: %d Error Message: %s", [peer getIp], errorCode, errorMsg);
        }
        else {
            NSLog(@"Successfully created table: %@", [peer getIp]);
            NSString* insertStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO [%@] (filepath) VALUES (?1)", [peer getIp]];
            const char* insertStatement = [insertStmt UTF8String];
            
            sqlite3_prepare_v2(indexDB, insertStatement, -1, &statement, NULL);
            
            for (NSString* file in index) {
                const char* fileName = [file UTF8String];
                int errorCode;
                if ((errorCode = sqlite3_bind_text(statement, 1, fileName, -1, SQLITE_STATIC)) != SQLITE_OK) {
                    NSLog(@"Bind Error: %d", errorCode);
                }
                if ((errorCode = sqlite3_step(statement)) != SQLITE_DONE) {
                    NSLog(@"Inserting error: %d", errorCode);
                }
                NSLog(@"Inserting: %@: %s", [peer getIp], fileName);
                sqlite3_reset(statement);
            }
            NSLog(@"Finished adding index: %@", [peer getIp]);
        }
        
    }
    else {
        NSLog(@"Unable to create/connect database: %s", dbPath);
    }
    
}

- (void)writePeerListToDatabase:(NSArray *)peerlist {
    sqlite3_stmt* statement;
    int errorCode;
    char* errorMsg;
    ///// Create path to the database file /////
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString* dbFileName = @"peers.db";
    NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
    const char * dbPath = [dataPath UTF8String];
    //Try to connect to the database
    if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
        NSString* connectStmt = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS '%@' (address TEXT PRIMARY KEY NOT NULL, hash INT, lastSeen TEXT)", peerListTable];
        const char* sqlStatement = [connectStmt UTF8String];
        
        if ((errorCode = sqlite3_exec(indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot create/open table: %@\n%s", peerListTable, errorMsg);
            return;
        } else {
            NSLog(@"Successfully created/opened the table: %@", peerListTable);
            
            NSString* insertStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO [%@] (address, hash, lastSeen) VALUES (?1, ?2, ?3)", peerListTable];
            const char* insertStatement = [insertStmt UTF8String];
            
            if ((errorCode = sqlite3_prepare_v2(indexDB, insertStatement, -1, &statement, NULL)) != SQLITE_OK) {
                NSLog(@"Preparing statement failed: %d", errorCode);
                return;
            }
            
            for (Peer* peer in peerlist) {
                if ((errorCode = sqlite3_bind_text(statement, 1, [[peer getIp] UTF8String], -1, SQLITE_STATIC)) != SQLITE_OK) {
                    NSLog(@"Binding %@ Error: %d", [peer getIp], errorCode);
                }
                if ((errorCode = sqlite3_bind_int(statement, 2, [[peer getIndexHash] intValue])) != SQLITE_OK) {
                    NSLog(@"Binding %@ Error: %d", [peer getIndexHash], errorCode);
                }
                if ((errorCode = sqlite3_bind_text(statement, 3, [[peer getLastSeen] UTF8String], -1, SQLITE_STATIC)) != SQLITE_OK) {
                    NSLog(@"Binding %@ Error: %d", [peer getLastSeen], errorCode);
                }
                if ((errorCode = sqlite3_step(statement)) != SQLITE_DONE) {
                    NSLog(@"Inserting error: %d", errorCode);
                }
                NSLog(@"Inserting %@ into peer list", [peer getIp]);
                sqlite3_reset(statement);
            }
        }
    } else {
        NSLog(@"Unable to open database");
    }
}

- (DBManager*) init {
    peerListTable = @"peerlist";
    return [super init];
}


@end
