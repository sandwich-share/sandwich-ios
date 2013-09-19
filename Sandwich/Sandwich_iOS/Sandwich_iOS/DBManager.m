//
//  DBManager.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "DBManager.h"
#import "MainHandler.h"
#import "DBHandlerWrapper.h"

@implementation DBManager {
    NSMutableDictionary* dbDic;
    sqlite3* peerListDB;
    NSLock* dicLock;
}

NSString* peerListTable = @"peerlist";

- (NSMutableArray*) getExistingPeers {
    int errorCode;
	char* errorMsg;
    sqlite3_stmt* statement;
    //get the handle for peerlist table
    sqlite3* indexDB = [self getPeerListDB];
    
    
    NSString *sqlStmt = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS '%@' (address TEXT PRIMARY KEY NOT NULL, hash INT, lastSeen TEXT)", peerListTable];
	const char* sqlStatement = [sqlStmt UTF8String];
   
    NSMutableArray* peers = [[NSMutableArray alloc] init];
    if ((errorCode = sqlite3_exec(indexDB, sqlStatement, NULL, NULL, &errorMsg)) == SQLITE_OK) {
        //query the table for peers
        NSString *queryStmnt = [NSString stringWithFormat: @"SELECT * FROM %@", peerListTable];
        const char *query_stmt = [queryStmnt UTF8String];
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
        if ((errorCode = sqlite3_finalize(statement)) != SQLITE_OK) {
            NSLog(@"!!!!!!!!!! MAJOR ERROR: CANNOT RELEASE STATEMENT MEMORY !!!!!!!!!!!!!!!!!!");
        }
    } else {
         NSLog(@"Cannot create/open table: %@\n%s", peerListTable,errorMsg);
    }
    
    return peers;
}


- (NSMutableArray*) getPeersForBootstrap {
    NSMutableArray* existingPeers = [[NSMutableArray alloc] init];
    //Try to connect to the database
    sqlite3* peerlistdb = [self getPeerListDB];
    if (peerlistdb != nil) {
        existingPeers = [self getExistingPeers];
    } else {
        NSLog(@"Unable to open/create peerlist database");
    }
    return existingPeers;
}


- (void) writeIndexToDatabase:(NSArray *)index peer:(Peer *)peer {
    int errorCode;
	char* errorMsg;
    //get handle to database
    sqlite3* peerDB = [self getDBForPeer:peer];
    if (peerDB != nil) {
        sqlite3_stmt* statement;
        NSString *sqlStmt = [NSString stringWithFormat:@"DROP TABLE IF EXISTS [%@]", [peer getIp]];
        const char* sqlStatement = [sqlStmt UTF8String];
        
        if ((errorCode = sqlite3_exec(peerDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot drop table: %@", [peer getIp]);
        }
        
        sqlStatement = [[NSString stringWithFormat:@"CREATE TABLE [%@] (filepath TEXT PRIMARY KEY NOT NULL)", [peer getIp]] UTF8String];
        if ((errorCode = sqlite3_exec(peerDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot create table: %@ Error Code: %d Error Message: %s", [peer getIp], errorCode, errorMsg);
        }
        else {
            NSLog(@"Successfully created table: %@", [peer getIp]);
            NSString* insertStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO [%@] (filepath) VALUES (?1)", [peer getIp]];
            const char* insertStatement = [insertStmt UTF8String];
            
            sqlite3_prepare_v2(peerDB, insertStatement, -1, &statement, NULL);
            NSLog(@"Index for: %@ size: %d", [peer getIp], index.count);
            for (NSString* file in index) {
                const char* fileName = [file UTF8String];
                int errorCode;
                //NSLog(@"Inserting into: %@ : %s", [peer getIp], fileName);
                if ((errorCode = sqlite3_bind_text(statement, 1, fileName, -1, SQLITE_STATIC)) != SQLITE_OK) {
                    NSLog(@"Bind Error: %d", errorCode);
                }
                if ((errorCode = sqlite3_step(statement)) != SQLITE_DONE) {
                    NSLog(@"Inserting error: %d", errorCode);
                }
                //NSLog(@"Inserting: %@: %s", [peer getIp], fileName);
                sqlite3_reset(statement);
            }
            if ((errorCode = sqlite3_finalize(statement)) != SQLITE_OK) {
                NSLog(@"!!!!!!!!!! MAJOR ERROR: CANNOT RELEASE STATEMENT MEMORY !!!!!!!!!!!!!!!!!!");
            }
            NSLog(@"Finished adding index: %@", [peer getIp]);
        }
    }
}

- (void)updatePeerlist {
    [self writePeerListToDatabase:[MainHandler getPeerList]];
}

- (void)writePeerListToDatabase:(NSArray *)peerlist {
    sqlite3_stmt* statement;
    int errorCode;
    char* errorMsg;
    //get handle to peerlist db
    sqlite3* pldb = [self getPeerListDB];
    if (pldb != nil) {
        NSString* connectStmt = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS '%@' (address TEXT PRIMARY KEY NOT NULL, hash INT, lastSeen TEXT)", peerListTable];
        const char* sqlStatement = [connectStmt UTF8String];
        
        if ((errorCode = sqlite3_exec(pldb, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot create/open table: %@\n%s", peerListTable, errorMsg);
            return;
        } else {            
            NSString* insertStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO [%@] (address, hash, lastSeen) VALUES (?1, ?2, ?3)", peerListTable];
            const char* insertStatement = [insertStmt UTF8String];
            
            if ((errorCode = sqlite3_prepare_v2(pldb, insertStatement, -1, &statement, NULL)) != SQLITE_OK) {
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
            if ((errorCode = sqlite3_finalize(statement)) != SQLITE_OK) {
                NSLog(@"!!!!!!!!!! MAJOR ERROR: CANNOT RELEASE STATEMENT MEMORY !!!!!!!!!!!!!!!!!!");
            }
        }
    } else {
        NSLog(@"Unable to open database");
    }
    
}

- (NSArray *)searchInPeer:(Peer *)peer searchParam:(NSString *)param {
    sqlite3* peerDb = [self getDBForPeer:peer];
    if (peerDb == nil) {
        NSLog(@"The handle is nil!!!");
    } else {
        sqlite3_stmt* searchStatement;
        NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM [%@] WHERE filepath LIKE ?1", [peer getIp]];
        NSMutableArray* resultsArray = [[NSMutableArray alloc] init];
        
        //NSLog(@"DB handle: 0x%p\n", peerDb);
        
        const char *query_stmt = [querySQL UTF8String];
        //NSLog(@"Search Query Statment: %s", query_stmt);
        int errorCode;
        if ((errorCode = sqlite3_prepare_v2(peerDb, query_stmt, -1, &searchStatement, NULL)) == SQLITE_OK) {
            if ((errorCode = sqlite3_bind_text(searchStatement, 1, [param UTF8String], -1, SQLITE_STATIC)) == SQLITE_OK) {
                // NSLog(@"Bind was successful");
                while (sqlite3_step(searchStatement) == SQLITE_ROW)
                {
                    const unsigned char* text = sqlite3_column_text(searchStatement, 0);
                    SearchResult* result = [[SearchResult alloc] initWithPeer:peer filePath:[NSString stringWithFormat:@"%s", text]];
                    [resultsArray addObject:result];
                    //NSLog(@"Adding: %s", text);
                }
                
                if ((errorCode = sqlite3_finalize(searchStatement)) != SQLITE_OK) {
                    NSLog(@"!!!!!!!!!! MAJOR ERROR: CANNOT RELEASE STATEMENT MEMORY !!!!!!!!!!!!!!!!!!");
                }
            }
            else {
                NSLog(@"Failed to bind search parameter: %d", errorCode);
            }
        }
        else {
            NSLog(@"Failed to prepare statement: %d", errorCode);
        }
        return resultsArray;
    }
    return [[NSArray alloc] init];
    
}

- (sqlite3*) createDBHandleForPeer:(Peer*)p {
    ///// Create path to the database file /////
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:[p getIp]];
    const char * dbPath = [dataPath UTF8String];
    
    sqlite3* sqlDB ;
    if (sqlite3_open(dbPath, &sqlDB) == SQLITE_OK) {
        return sqlDB;
    } else {
        NSLog(@"Unable to open database!");
        return nil;
    }
}

- (sqlite3*) getDBForPeer:(Peer*)p {
    [dicLock lock];
    //NSLog(@"Getting DB handle for 0x%x\n", [p get32BitIp]);
    DBHandlerWrapper* wrapper = (DBHandlerWrapper*) [dbDic valueForKey:[p getIp]];
    sqlite3* db = nil;
    if (wrapper != nil) {
        db = [wrapper unwrap];
    }
    if (db == nil) {
        db = [self createDBHandleForPeer:p];
        if (db != nil) {
            //NSLog(@"Opened 0x%p for peer %@\n", db, [p getIp]);
            [dbDic setValue:[[DBHandlerWrapper alloc] initWithHandler:db] forKey:[p getIp]];
        }
    }
    [dicLock unlock];
    return db;
}

- (sqlite3*) getPeerListDB {
    if (peerListDB == nil) {
        NSString* plist = @"peerlist";
        sqlite3* db = nil;
        ///// Create path to the database file /////
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *libraryDirectory = [paths objectAtIndex:0];
        NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:plist];
        const char * dbPath = [dataPath UTF8String];
        
        if (sqlite3_open(dbPath, &db) == SQLITE_OK) {
            return db;
        } else {
            NSLog(@"Unable to open database!");
            return nil;
        }
        peerListDB = db;
    }
    return peerListDB;
}

- (id) init {
    self = [super init];
    dbDic = [[NSMutableDictionary alloc] init];
    dicLock = [[NSLock alloc] init];
    peerListDB = nil;
    return self;
}
@end
