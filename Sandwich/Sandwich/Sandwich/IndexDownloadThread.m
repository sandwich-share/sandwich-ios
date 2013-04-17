//
//  IndexDownloadThread.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "IndexDownloadThread.h"
#import <sqlite3.h>
#import <CommonCrypto/CommonDigest.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation IndexDownloadThread {
    BOOL finished;
}

- (unsigned short) portForIP: (NSString*)ip {
	in_addr_t address = inet_addr([ip UTF8String]);
	unsigned char addr[16], digest[16];
	unsigned short port;

	memset(addr, 0, 16);
	addr[10] = 0xFF;
	addr[11] = 0xFF;
	memcpy(&addr[12], &address, sizeof(address));
	
	CC_MD5( addr, 16, digest ); // This is the md5 call
	
	port = (digest[0] + digest[3]) << 8;
	port += (digest[1] + digest[2]);
	NSLog(@"%@ -> %d", ip, port);
	return port;
}

+ (unsigned short) portForPeer: (NSString*)ip {
	in_addr_t address = inet_addr([ip UTF8String]);
	unsigned char addr[16], digest[16];
	unsigned short port;
    
	memset(addr, 0, 16);
	addr[10] = 0xFF;
	addr[11] = 0xFF;
	memcpy(&addr[12], &address, sizeof(address));
	
	CC_MD5( addr, 16, digest ); // This is the md5 call
	
	port = (digest[0] + digest[3]) << 8;
	port += (digest[1] + digest[2]);
	NSLog(@"%@ -> %d", ip, port);
	return port;
}

- (BOOL) needToUpdate {
    const char* sqlStatement = "SELECT indexhash FROM peerinfo LIMIT 1";
    sqlite3_stmt* selectStatement;
    int errorCode;
    unsigned int oldHash = -1;
    if ((errorCode = sqlite3_prepare_v2(self.indexDB, sqlStatement, -1, &selectStatement, NULL)) == SQLITE_OK) {
        sqlite3_step(selectStatement);
        oldHash = sqlite3_column_int(selectStatement, 0);
    }
    NSNumber* numberOfHash = [self.index objectForKey:@"IndexHash"];
    unsigned int newHash = [numberOfHash intValue];
    NSLog(@"new hash for: %@, %u", self.peer.ip, newHash);
    NSLog(@"old hash for: %@, %u", self.peer.ip, oldHash);
    return oldHash != newHash;
}

- (NSDictionary*) getIndex {
    //initialize index download
	NSMutableString* url = [[NSMutableString alloc] init];
    self.peer.port = [self portForIP:self.peer.ip];
	[url appendFormat:@"http://%@:%d/fileindex", self.peer.ip, self.peer.port];
	NSURL* peerURL = [NSURL URLWithString:url];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:peerURL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                                       timeoutInterval:10];
    [request setHTTPMethod: @"GET"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData* peerIndex = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];

    if (peerIndex != NULL) {
        return [NSJSONSerialization JSONObjectWithData:peerIndex options:kNilOptions error:nil];
    }
    return NULL;
}

- (void)main {
    
    self.index = [self getIndex];
    
    if (self.index == NULL)
	{
		NSLog(@"Failed to get index for peer %@", self.peer.ip);
        [self setFinished];
		return;
	}
	else
	{
		NSLog(@"Fetched index for peer %@", self.peer.ip);
	}
    if ([self needToUpdate]) {
        int errorCode;
        char* errorMsg;
        sqlite3_stmt* statement;
        NSString *sqlStmt = [NSString stringWithFormat:@"DROP TABLE IF EXISTS [%@]", self.peer.ip];
        const char* sqlStatement = [sqlStmt UTF8String];

        if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot drop table: %@", self.peer.ip);
        }
        sqlStmt = @"DROP TABLE IF EXISTS peerinfo";
        sqlStatement = [sqlStmt UTF8String];
        
        if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot drop table: peerinfo");
        }
        sqlStatement = [[NSString stringWithFormat:@"CREATE TABLE [%@] (filepath TEXT PRIMARY KEY NOT NULL)",self.peer.ip] UTF8String];
        if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
            NSLog(@"Cannot create table: %@ Error Code: %d Error Message: %s", self.peer.ip, errorCode, errorMsg);
        }
        else {
            NSLog(@"Successfully created table: %@", self.peer.ip);
        
            sqlStatement = "CREATE TABLE peerinfo (indexhash INTEGER, timestamp TEXT)";
        
            if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
                NSLog(@"Cannot create peerinfo table: Error Code: %d Error Message: %s", errorCode, errorMsg);
            }
            sqlStatement = [[NSString stringWithFormat:@"INSERT INTO peerinfo (indexhash, timestamp) VALUES (%u,'%@')", self.peer.hash, self.peer.timestamp] UTF8String];
            //NSLog(@"%s", sqlStatement);
            if ((errorCode = sqlite3_exec(self.indexDB, sqlStatement, NULL, NULL, &errorMsg)) != SQLITE_OK) {
                NSLog(@"Cannot insert peerinfo: Error Code: %d Error Message: %s", errorCode, errorMsg);
            }
            
            NSString* insertStmt = [NSString stringWithFormat:@"INSERT OR REPLACE INTO [%@] (filepath) VALUES (?1)", self.peer.ip];
            const char* insertStatement = [insertStmt UTF8String];
        
            sqlite3_prepare_v2(self.indexDB, insertStatement, -1, &statement, NULL);
        
            NSLog(@"Inserting index for: %@", self.peer.ip);
            if (sqlite3_exec(self.indexDB, "BEGIN IMMEDIATE", NULL, NULL, NULL) != SQLITE_OK)
            {
                NSLog(@"Failed to begin immediate");
                [self setFinished];
                return;
            }
            NSArray* list = [self.index objectForKey:@"List"];
            for (int i = 0; i < list.count; i++) {
                NSDictionary* files = list[i];
                NSString* filename = [files objectForKey:@"FileName"];
                const char* fileName = [filename UTF8String];
                int errorCode;
                if ((errorCode = sqlite3_bind_text(statement, 1, fileName, -1, SQLITE_STATIC)) != SQLITE_OK) {
                    NSLog(@"Bind Error: %d", errorCode);
                }
                if ((errorCode = sqlite3_step(statement)) != SQLITE_DONE) {
                    NSLog(@"Inserting error: %d", errorCode);
                }
                //NSLog(@"Inserting: %@: %s", self.peer.ip, fileName);
                sqlite3_reset(statement);
            }
            if (sqlite3_exec(self.indexDB, "END TRANSACTION", NULL, NULL, NULL) != SQLITE_OK)
            {
                NSLog(@"Failed to end transaction");
                [self setFinished];
                return;
            }
            NSLog(@"Finished adding index: %@", self.peer.ip);

            }
        }
    else {
        NSLog(@"Do not need to update index");
    }
    [self setFinished];
}

- (void) setFinished {
    finished = true;
}

- (BOOL) isFinished {
    return finished;
}

-(void) initializeDatabase {
    ///// Create path to the database file /////
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString* dbFileName = [NSString stringWithFormat:@"%@.db", self.peer.ip];
    
	NSString *dataPath = [libraryDirectory stringByAppendingPathComponent:dbFileName];
    const char * dbPath = [dataPath UTF8String];
    ////////////////////////////////////////////
    
    //// Create the database /////
    sqlite3* indexDB;
    if (sqlite3_open(dbPath, &indexDB) == SQLITE_OK) {
        self.indexDB = indexDB;
    }
    else {
        NSLog(@"Unable to create database");
    }
}

- (IndexDownloadThread *)initWithPeer:(Peer *)peer {
	self.peer = peer;
    [self initializeDatabase];
	return [super init];
}
@end
