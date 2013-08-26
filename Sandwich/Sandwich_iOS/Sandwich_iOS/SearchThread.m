//
//  SearchThread.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "SearchThread.h"

@implementation SearchThread {
    NSString* SearchParam;
    sqlite3* IndexDB;
    Peer* MyPeer;
}

- (void) main {
    sqlite3_stmt* searchStatement;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT * FROM [%@] WHERE filepath LIKE ?1", [MyPeer getIp]];
    const char *query_stmt = [querySQL UTF8String];
    int errorCode;
    if ((errorCode = sqlite3_prepare_v2(IndexDB, query_stmt, -1, &searchStatement, NULL)) == SQLITE_OK)
    {
        if ((errorCode = sqlite3_bind_text(searchStatement, 1, [SearchParam UTF8String], -1, SQLITE_STATIC)) == SQLITE_OK) {
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

- (id) initWithSearch:(sqlite3*)DB peer:(Peer*)peer searchString:(NSString*)searchString {
    self = [super init];
    self->IndexDB = DB;
    self->MyPeer = peer;
    self->SearchParam = searchString;
    return self;
}

@end
